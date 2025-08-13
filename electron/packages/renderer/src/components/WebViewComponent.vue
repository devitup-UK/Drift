<template>
  <div class="webview" :class="{'webview--toolbar': toolbarVisible}" v-show="tab.id === activeTabId">
    <webview
          class="webview__webpage"
          :data-tab-id="tab.id"
          ref="webview"
          :src="tab.initialUrl"
          allowpopups
          allowfullscreen
          contextmenu
          webpreferences="javascript=yes, nodeIntegration=no, contextIsolation=no, webSecurity=yes"
          partition="persist:drift-session"
          plugins
          :preload="preloadUrl"
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
import Tab from '../../../shared/models/Tab';
import WebErrorComponent from './errors/WebErrorComponent.vue';
import { useGlobalStore } from '../stores/globalStore';
import { useHistoryStore } from '../stores/historyStore';

const preloadUrl = window.drift?.webviewPreloadPath || '';
console.log("Preload URL:", preloadUrl);

const webview = ref<WebviewTag | null>(null);
const error: { display: boolean, code: number, description: string } = reactive({
  display: false,
  code: 0,
  description: ''
});
const tabStore = useTabStore();
const webviewStore = useWebviewStore();
const historyStore = useHistoryStore();

const { activeTabId, reloadSignals } = storeToRefs(tabStore);
const { toolbarVisible } = storeToRefs(useGlobalStore());

const props = defineProps<{
  tab: Tab;
}>();

const tabId = props.tab.id;

const isAuthUrl = (url: string) =>
  url.includes('login.microsoftonline.com') ||
  url.includes('device.login.microsoftonline.com') ||
  url.includes('accounts.google.com');

onMounted(() => {
  if (!webview.value) return;

  const view = webview.value;

  view.addEventListener('did-attach', () => {
    webviewStore.registerWebview(tabId, view);
  });

  view.addEventListener('dom-ready', () => {
    webviewStore.setWebviewReady(tabId, true);
  });

  // Set title on initial load
  view.addEventListener('page-title-updated', (e: Electron.PageTitleUpdatedEvent) => {
    if(isAuthUrl(view.getURL())) return;
    e.preventDefault();
    tabStore.setTabTitle(tabId, view.getTitle());
  });

  view.addEventListener('did-navigate', (event) => {
    console.log("We are navigating to:", event.url);
    webviewStore.setWebviewLoading(tabId, true);
    tabStore.setTabFavicon(tabId, "");
    historyStore.addHistoryEntry(tabId, event.url);
    tabStore.setTabUrl(tabId, event.url);
  });

  view.addEventListener('did-navigate-in-page', (event) => {
    console.log("We are navigating to:", event.url);
    historyStore.addHistoryEntry(tabId, event.url);
    tabStore.setTabUrl(tabId, event.url);
  });

  view.addEventListener('ipc-message', (event) => {
    if (event.channel === 'pip-closed') {
      console.log('Picture-in-Picture closed for tab:', event.args[0]);
    }
  });

  view.addEventListener('did-finish-load', () => {
    const url = new URL(view.getURL());
    if (isAuthUrl(url.href)) return;
    // Wait a bit just in case the favicon is still loading
    setTimeout(() => {
      // Use the host url to try and get the favicon by appending it to the base URL
      const host = url.host;
      let faviconUrl = `https://${host}/favicon.ico`;

      // Check if the favicon exists
      fetch(`https://www.google.com/s2/favicons?domain=${host}`, { method: 'HEAD' })
        .then(response => {
          if (response.ok) {
            tabStore.setTabFavicon(tabId, `https://www.google.com/s2/favicons?domain=${host}`);
          } else {
            // If the favicon doesn't exist, try the original URL
            return fetch(faviconUrl, { method: 'HEAD' });
          }
        })
        .catch(() => {
          view.executeJavaScript(`
            (() => {
              const links = document.querySelectorAll('link[rel~="icon"]');
              const href = Array.from(links).map(link => link.href).find(Boolean);
              return href || '';
            })()
          `).then((faviconUrl: string) => {
            console.log(faviconUrl);
            if (faviconUrl) {
              if(!props.tab) return;
              tabStore.setTabFavicon(tabId, faviconUrl);
            }
          });
        });


      // Also grab title here if needed
      const title = view.getTitle();
      if (title) {
        if(!props.tab) return;
        tabStore.setTabTitle(tabId, title);
      }

      webviewStore.setWebviewLoading(tabId, false);
      tabStore.setHasBeenLoaded(tabId, true);
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
