<template>
  <div class="browser">
    <NewTabComponent v-if="controlBarOpen"></NewTabComponent>
    <WindowDragAreaComponent></WindowDragAreaComponent>
      <div class="browser__controls">
        <SidebarView :class="{'drag-shield' : resizing }" :style="`width: ${sidebarWidth}px;` + (!isSidebarVisible ? `left: ${(!slideSidebarIntoView ? (0 - sidebarWidth) : 10)}px;` : '')"></SidebarView>
        <LayoutControlComponent @resize="sidebarWidth = $event" @resize-start="resizing = true" @resize-end="resizing = false"></LayoutControlComponent>
        <WebContentView :class="{'drag-shield' : resizing, 'sidebar-hidden': !isSidebarVisible, 'fullscreen': fullscreen }"></WebContentView>
      </div>
  </div>
</template>

<style lang="scss">

* {
  box-sizing: border-box;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
}

html, body, #app {
  height: 100%;
  padding: 0;
  margin: 0;
}

.browser, .browser__controls {
  width: 100%;
  height: 100%;
}

.sidebar-hidden {
  margin: 26px 0 0;
}

.browser {
  position: relative;
  padding: 10px;

  .browser__controls {
    display: flex;
  }
}

.truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tabs {
  list-style: none;
  padding: 0;
  margin: 0;

  .tabs__item {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    border-radius: 12px;
    color: #bebebe;
    font-size: 13px;
    margin: 4px 0 0;
    height: 36px;
    max-height: 36px;
    cursor: default;

    &.tabs__item--active {
      background: rgba(255, 255, 255, 0.125);

      &:hover {
        background: rgba(255, 255, 255, 0.125);
      }
    }

    &:hover {
      background: rgba(255, 255, 255, 0.1);

      .tab-controls {
        display: flex;
      }
    }
  }
}

.tab-favicon {
  width: 16px;
  height: 16px;
  margin: 0 6px 0 0;
  vertical-align: middle;
  color: #fff;
}

.drag-shield {
  position: relative;
  pointer-events: none;

  &::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 9999;
    cursor: col-resize;
  }
}

.fullscreen {
  margin: 0;
}
</style>


<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { useGlobalStore } from './stores/globalStore';
import { useTabStore } from './stores/tabStore';
import { useHistoryStore } from './stores/historyStore';
import SidebarView from './views/SidebarView.vue';
import LayoutControlComponent from './components/LayoutControlComponent.vue';
import WebContentView from './views/WebContentView.vue';
import WindowDragAreaComponent from './components/WindowDragAreaComponent.vue';
import NewTabComponent from './components/ControlBarComponent.vue';
import { useKeyboardShortcuts } from './helpers/keyboardShortcutsHelper';
import { ref, onMounted, onBeforeUnmount } from 'vue';
import { onFullscreenChange, onOpenInNewTab, onMediaPlaying, onMediaPaused, onTabInteraction, onExtensionInstalled, onExtensionRemoved } from '@app/preload';
import { useWebviewStore } from './stores/webviewStore';
import { watchAndSync } from './utils/watchAndSync';
import { tabManager } from './managers/TabManager';
import type ChromeExtension from '../../shared/models/ChromeExtension';
import { useExtensionStore } from './stores/extensionStore';


const globalStore = useGlobalStore();
const tabStore = useTabStore();
const historyStore = useHistoryStore();

const { controlBarOpen, sidebarWidth, isSidebarVisible, slideSidebarIntoView, fullscreen } = storeToRefs(globalStore);

const resizing = ref(false);

useKeyboardShortcuts();

// watchAndSync(() => tabStore.tabs, tabStore.saveToDisk)
// watchAndSync(() => historyStore.history, historyStore.saveToDisk)

onMounted(() => {
  tabManager.init()

  onFullscreenChange((isFullscreen: boolean) => {
    globalStore.setFullscreen(isFullscreen);
  });

  onOpenInNewTab((url: string) => {
    tabStore.addTab(url);
  });

  onMediaPlaying((webContentsId: number) => {
    console.log('Media playing on webContents:', webContentsId);
    const webviewStore = useWebviewStore();
    const tabId = webviewStore.getTabIdByWebviewId(webContentsId);
    if (tabId) {
      tabStore.setTabMediaPlaying(tabId, true);
    }
    else {
      console.warn('No tab found for webContentsId:', webContentsId);
    }
  });

  onMediaPaused((webContentsId: number) => {
    console.log('Media paused on webContents:', webContentsId);
    const webviewStore = useWebviewStore();
    const tabId = webviewStore.getTabIdByWebviewId(webContentsId);
    if (tabId) {
      tabStore.setTabMediaPlaying(tabId, false);
    }
    else {
      console.warn('No tab found for webContentsId:', webContentsId);
    }
  });

  onTabInteraction((webContentsId: number) => {
    console.log('Tab interaction detected on webContents:', webContentsId);
    const webviewStore = useWebviewStore();
    const tabId = webviewStore.getTabIdByWebviewId(webContentsId);
    if (tabId) {
      tabStore.setTabLastInteractedAt(tabId, Date.now());
    }
    else {
      console.warn('No tab found for webContentsId:', webContentsId);
    }
  });

  onExtensionInstalled((extensionDetails: ChromeExtension) => {
    console.log('Extension installed:', extensionDetails);
    const extensionStore = useExtensionStore();
    extensionStore.addExtension(extensionDetails);
  });

  onExtensionRemoved((extensionDetails: ChromeExtension) => {
    console.log('Extension removed:', extensionDetails);
    const extensionStore = useExtensionStore();
    extensionStore.removeExtension(extensionDetails.id);
  });
});

onBeforeUnmount(() => {
  // tabStore.saveToDisk()
  // historyStore.saveToDisk()
})
</script>
