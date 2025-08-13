<template>
  <div class="webview-controls" :class="{ 'webview-controls--toolbar': toolbarMode }">
    <div class="webview-controls__button" @click="toggleSidebar()" v-if="showSidebarToggle">
      <FontAwesomeIcon icon="rectangle-list" />
    </div>
    <template v-if="showWebViewControls">
      <div class="webview-controls__button" :class="{ 'webview-controls__button--disabled': !canGoBack }" @click="activeWebviewState?.webview?.goBack()">
        <FontAwesomeIcon icon="arrow-left" />
      </div>
      <div class="webview-controls__button" :class="{ 'webview-controls__button--disabled': !canGoForward }" @click="activeWebviewState?.webview?.goForward()">
        <FontAwesomeIcon icon="arrow-right" />
      </div>
      <div class="webview-controls__button webview-controls__button--reload" :class="{ 'webview-controls__button--disabled': activeTab == null }" @click="reloadOrStopActiveTab()">
        <FontAwesomeIcon :icon="activeWebviewState?.loading ? 'times' : 'rotate-right'" />
      </div>
    </template>
  </div>
</template>

<style lang="scss" scoped>
.webview-controls {
  text-align: right;
  margin: 0 0 6px;

  &.webview-controls--toolbar {
    margin: 0;
    font-size: 14px;

    .webview-controls__button {
      padding: 4px;
      margin: 0 0 0 4px;

      &:hover {
        background: rgba(0, 0, 0, 0.3);
      }
    }
  }

  .webview-controls__button {
    display: inline-block;
    padding: 8px;
    color: #8c8c8c;
    text-align: center;

    &.webview-controls__button--reload {
      min-width: 32px;
    }

    &:hover {
      border-radius: 6px;
      background: rgba(255, 255, 255, 0.1);
    }

    &.webview-controls__button--disabled {
      opacity: 0.3;

      &:hover {
        background: unset;
      }
    }
  }
}
</style>

<script setup lang="ts">
import { ref, computed, defineProps, watch } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { storeToRefs } from 'pinia';

import { useGlobalStore } from '../stores/globalStore';
import { useTabStore } from '../stores/tabStore';
import { useWebviewStore } from '../stores/webviewStore';

const globalStore = useGlobalStore();
const tabStore = useTabStore();
const webviewStore = useWebviewStore();

defineProps<{
  showSidebarToggle?: boolean;
  toolbarMode?: boolean;
  showWebViewControls?: boolean;
}>();

const { activeTabId } = storeToRefs(tabStore);
const { toolbarVisible } = storeToRefs(globalStore);
const activeTab = computed(() => tabStore.activeTab);
const activeWebviewState = computed(() => {
  if(!activeTabId.value) return null;
  return webviewStore.getWebviewState(activeTabId.value)
});
const canGoBack = ref(false);
const canGoForward = ref(false);

function updateNavState() {
  try {
    const webview = activeWebviewState.value?.webview;
    if (!webview) return;

    canGoBack.value = webview.canGoBack();
    canGoForward.value = webview.canGoForward();
  } catch (e) {
    canGoBack.value = false;
    canGoForward.value = false;
  }
}

// Watch for tab change or webview change
watch(activeWebviewState, (newVal, oldVal) => {
  const webview = newVal?.webview;
  if (!webview) return;

  // Wait a tick in case webview isn't attached yet
  setTimeout(() => updateNavState(), 200);

  // Attach listeners for when nav state might change
  webview.addEventListener('did-navigate', updateNavState);
  webview.addEventListener('did-navigate-in-page', updateNavState);
  webview.addEventListener('did-finish-load', updateNavState);
}, { immediate: true });

function toggleSidebar() {
  globalStore.toggleSidebar();
}

function reloadOrStopActiveTab() {
  if (!activeTab.value) return;

  if (activeWebviewState?.value?.loading) {
    tabStore.stopLoading(activeTab.value.id);
  } else {
    tabStore.requestReload(activeTab.value.id);
  }
}
</script>
