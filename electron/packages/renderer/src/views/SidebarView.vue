<template>
  <div class="sidebar" :class="{ 'sidebar--hidden': !sidebarVisible, 'sidebar--fullscreen': fullscreen }" @mouseleave="onMouseLeave">
    <WebViewControlsComponent :toolbarMode="false" :show-web-view-controls="!toolbarVisible" showSidebarToggle />
    <AddressBarComponent @click="openControlBarComponent" v-if="!toolbarVisible" />
    <ul class="tabs tabs--standard">
      <draggable
        :list="tabStore.standardTabs.filter((tab: Tab) => !tab.archived)"
        item-key="id"
        class="tabs__list"
        :class="{ 'drag-shield': resizing }"
        :disabled="!sidebarVisible || resizing"
        animation="300">
        <template #item="{ element: tab }">
          <TabComponent
            class="tabs__item"
            :class="{ 'tabs__item--active': tab.id === activeTabId }"
            :tab="tab"
            @click="switchTab(tab.id)" />
        </template>
      </draggable>
      <!-- <TabComponent class="tabs__item" :class="{'tabs__item--active': tab.id === activeTabId}" :tab="tab" v-for="tab in allStandardAndPinnedLoadedTabs" :key="tab.id" @click="switchTab(tab.id)" /> -->
    </ul>
    <NewTabComponent></NewTabComponent>
  </div>
</template>

<style lang="scss" scoped>
.sidebar {
  height: 100%;
  user-select: none;
  position: relative;
  z-index: 1000;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
  }

  &.sidebar--hidden {
    height: calc(100% - 41px);
    padding: 10px;
    position: absolute;
    top: 36px;
    bottom: 5px;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
    transition: left 0.3s ease;
    border-style: solid;
    background: #111111;
    border-radius: 10px;
    border-width: 1px;
    border-color: #868686;

    &::before {
      content: '';
      position: absolute;
      top: 0;
      bottom: 0;
      width: 10px;
      left: -10px;
    }

    &.sidebar--fullscreen {
      top: 5px;
      height: calc(100% - 10px);
    }
  }
}
</style>

<script setup lang="ts">
import { computed, ref } from 'vue';
import AddressBarComponent from '../components/AddressBarComponent.vue';
import { useGlobalStore } from '../stores/globalStore';
import { useTabStore } from '../stores/tabStore';
import { storeToRefs } from 'pinia';
import TabComponent from '../components/tabs/TabComponent.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useWebviewStore } from '../stores/webviewStore';
import NewTabComponent from '../components/tabs/NewTabComponent.vue';
import WebViewControlsComponent from '../components/WebViewControlsComponent.vue';
import draggable from 'vuedraggable';
import type Tab from '../../../shared/models/Tab';

// Register draggable as a component
defineProps();
defineEmits();
const components = { draggable, AddressBarComponent, TabComponent, NewTabComponent, WebViewControlsComponent };

const globalStore = useGlobalStore();
const tabStore = useTabStore();
const webviewStore = useWebviewStore();

const openControlBarComponent = () => {
  if(tabStore.activeTabId) {
    globalStore.openControlBarInEditMode();
  } else {
    globalStore.openControlBarInNewTabMode();
  }
}

const { activeTabId } = storeToRefs(tabStore);
const { sidebarVisible, slideSidebarIntoView, fullscreen, toolbarVisible } = storeToRefs(globalStore);
const pipTabId = ref<string | null>(null);

async function switchTab(tabId: string) {
  const tabStore = useTabStore();
  const currentActiveTabId = tabStore.activeTabId;

  if(currentActiveTabId) {
    // If the current active webview is playing a video and we switch tabs, we will request picture-in-picture mode
    const currentWebview = webviewStore.getWebviewState(currentActiveTabId)?.webview;
    if (currentWebview && currentActiveTabId !== tabId) {
      currentWebview?.executeJavaScript(`
        (async () => {
          const videos = Array.from(document.querySelectorAll('video'));

          const playingVideo = videos.find(video => {
            return (
              !video.paused &&
              !video.ended &&
              video.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA
            );
          });

          if (playingVideo && !document.pictureInPictureElement) {
            try {
              await playingVideo.requestPictureInPicture();
              return true;
            } catch (e) {
              console.warn('PiP request failed:', e);
              return false;
            }
          }

          return false;
        })();
      `).then((didActivate: boolean) => {
        if(didActivate) {
          pipTabId.value = tabId;
        }
      }).catch(err => {
        console.error('Error requesting Picture-in-Picture:', err);
      });
    }

    console.log('Switching to tab:', tabId);
    console.log('Pip Tab ID:', pipTabId.value);

    if(tabId === pipTabId.value) {
      const newWebview = webviewStore.getWebviewState(tabId)?.webview;
      if (newWebview) {
        newWebview.executeJavaScript(`
          if (document.pictureInPictureElement) {
            console.log('Exiting Picture-in-Picture for tab:', '${tabId}');
            document.exitPictureInPicture().catch(console.warn);
          }
        `).then(() => {
          pipTabId.value = null;
        });
      }
    }
  }

  tabStore.switchTab(tabId);

    // const newlyActiveWebviewState = webviewStore.getWebviewState(tabId);
    // if (newlyActiveWebviewState?.webview?.getWebContentsId() !== undefined) {
    //   console.log('Requesting Picture-in-Picture for webview:', newlyActiveWebviewState.webview.getURL());
    //   console.log(newlyActiveWebviewState?.webview);
    //   newlyActiveWebviewState?.webview.executeJavaScript(`
    //     setTimeout(() => {
    //       if(typeof videoCollection === 'undefined') {
    //           console.log('No videoCollection defined, creating it.');
    //           var videoCollection = document.getElementsByTagName('video');
    //       }
    //       if (videoCollection.length > 0) {
    //         console.log('Resetting media controller for video:', videoCollection[0]);
    //           // Fake a user interaction
    //         const event = new MouseEvent('click', {
    //           bubbles: true,
    //           cancelable: true,
    //           view: window
    //         });
    //         videoCollection[0].dispatchEvent(event);
    //         videoCollection[0].dispatchEvent(event);
    //       }
    //     }, 500);
    //   `).catch(err => {
    //     console.error('Error resetting media controller', JSON.stringify(err));
    //   });
    // }else{
    //   console.log('No active webview found or no web contents ID available.');
    // }
}

const onMouseLeave = () => {
  if (!sidebarVisible.value && slideSidebarIntoView.value) {
    globalStore.setSlideSidebarIntoView(false);
  }
}
</script>
