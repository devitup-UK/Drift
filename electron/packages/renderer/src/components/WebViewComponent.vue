<template>
  <div class="webview" :class="{'webview--toolbar': toolbarVisible}" v-show="tab.id === activeTabId">
    <webview
          class="webview__webpage"
          :data-tab-id="tab.id"
          ref="webview"
          :src="tab.getActiveHistoryEntry()?.url"
          allowpopups
          allowfullscreen
          contextmenu
          webpreferences="javascript=yes, nodeIntegration=no, contextIsolation=no, webSecurity=no"
          partition="persist:drift-session"
          disablewebsecurity
          v-if="!error.display"
        />
        <WebErrorComponent :code="error.code" :description="error.description" v-else></WebErrorComponent>
    </div>
</template>

<style lang="scss" scoped>
.webview {
  width: 100%;
  height: 100%;
  justify-content: center;
  align-items: center;
  background: #FFF;
  border-radius: 8px;

  .webview__webpage {
    width: 100%;
    height: 100%;
    border-radius: 8px;
    overflow: hidden;
    // Forces priority for GPU rendering
    opacity: 0.99;
  }

  &.webview--toolbar {
    height: calc(100% - 30px);
    border-top-left-radius: 0;
    border-top-right-radius: 0;

    .webview__webpage {
      border-top-left-radius: 0;
      border-top-right-radius: 0;
    }
  }
}
</style>

<script setup lang="ts">
import { ref, onMounted, watch, reactive } from 'vue';
import { useTabStore } from '../stores/tabStore';
import { useWebviewStore } from '../stores/webviewStore';
import { storeToRefs } from 'pinia';
import type { WebviewTag } from 'electron';
import Tab from '../models/Tab';
import WebErrorComponent from './errors/WebErrorComponent.vue';
import { useGlobalStore } from '../stores/globalStore';
import adblockCSS from '../assets/styles/adblock.css?raw'; // Adjust path as needed
import { registerExtensionTab } from '@app/preload';

const webview = ref<WebviewTag | null>(null);
const error: { display: boolean, code: number, description: string } = reactive({
  display: false,
  code: 0,
  description: ''
});
const tabStore = useTabStore();
const webviewStore = useWebviewStore();

const { activeTabId, reloadSignals } = storeToRefs(tabStore);
const { toolbarVisible } = storeToRefs(useGlobalStore());

const props = defineProps<{
  tab: Tab;
}>();

const tabId = props.tab.id;

onMounted(() => {
  if (!webview.value) return;

  const view = webview.value;

  webviewStore.registerWebview(tabId, webview.value);

  webview.value.addEventListener('dom-ready', () => {
    webviewStore.setWebviewReady(tabId, true);
    const wcId = webview.value?.getWebContentsId(); // This gets the webContents ID
    registerExtensionTab(wcId);
    try {
    webview.value?.insertCSS(adblockCSS);
    } catch (error) {
      console.error('Error inserting CSS:', error);
    }
  });

  // Set title on initial load
  view.addEventListener('page-title-updated', (e: Electron.PageTitleUpdatedEvent) => {
    e.preventDefault(); // prevent Electron from updating the BrowserWindow title
    if(!props.tab) return;
    tabStore.setTabTitle(tabId, view.getTitle());
  });

  view.addEventListener('did-start-navigation', (e) => {
    if(!props.tab) return;
    if (e.isMainFrame) {
      console.log('Navigation started for tab:', tabId, 'to URL:', e.url);
      webviewStore.setWebviewLoading(tabId, true);
    }
  });

  view.addEventListener('did-start-loading', () => {
    console.log('Loading started for tab:', tabId);
      webviewStore.setWebviewLoading(tabId, true);
  });

  view.addEventListener('did-stop-loading', () => {
    console.log('Loading stopped for tab:', tabId);
      webviewStore.setWebviewLoading(tabId, false);
  });

  // Fallback: In case title updates on navigation
  view.addEventListener('did-navigate', () => {
    setTimeout(() => {
      if(!props.tab) return;
      console.log('Navigated to:', view.getURL());
      tabStore.setTabTitle(tabId, view.getTitle());
      tabStore.addHistoryEntryToTab(tabId, view.getURL());
    }, 300); // slight delay to ensure title is available
  });

  view.addEventListener('did-finish-load', () => {
    // Wait a bit just in case the favicon is still loading
    setTimeout(() => {
      tabStore.addHistoryEntryToTab(tabId, view.getURL());

      // This script grabs any icon from the page
      view.executeJavaScript(`
        (() => {
          const links = document.querySelectorAll('link[rel~="icon"]');
          const href = Array.from(links).map(link => link.href).find(Boolean);
          return href || '';
        })()
      `).then((faviconUrl: string) => {
        if (faviconUrl) {
          if(!props.tab) return;
          tabStore.setTabFavicon(tabId, faviconUrl);
        }
      });

      // Also grab title here if needed
      const title = view.getTitle();
      if (title) {
        if(!props.tab) return;
        tabStore.setTabTitle(tabId, title);
      }

      webviewStore.setWebviewLoading(tabId, false);
    }, 200);
  });

  view.addEventListener('did-fail-load', (event) => {
    if(event.errorCode === -105 || event.errorCode === -106 || event.errorCode === -2) {
      console.log(event);
      error.display = true;
      error.code = event.errorCode;
      error.description = event.errorDescription;

    }
  })
});

watch(() => reloadSignals.value[tabId], (newVal) => {
  if (newVal && webview.value) {
    try {
      webview.value.reload();
    } catch (error) {
      // console.error('Error reloading webview:', error);
    }
  }
});
</script>
