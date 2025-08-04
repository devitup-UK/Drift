<template>
  <div class="sidebar" :class="{ 'sidebar--hidden': !sidebarVisible, 'sidebar--fullscreen': fullscreen }" @mouseleave="onMouseLeave">
    <WebViewControlsComponent :toolbarMode="false" :show-web-view-controls="!toolbarVisible" showSidebarToggle />
    <AddressBarComponent @click="openControlBarComponent" v-if="!toolbarVisible" />
    <ul class="tabs tabs--standard">
      <TabComponent class="tabs__item" :class="{'tabs__item--active': tab.id === activeTabId}" :tab="tab" v-for="tab in allStandardAndPinnedLoadedTabs" :key="tab.id" @click="switchTab(tab.id)" />
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
import { computed } from 'vue';
import AddressBarComponent from '../components/AddressBarComponent.vue';
import { useGlobalStore } from '../stores/globalStore';
import { useTabStore } from '../stores/tabStore';
import { storeToRefs } from 'pinia';
import TabComponent from '../components/tabs/TabComponent.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useWebviewStore } from '../stores/webviewStore';
import NewTabComponent from '../components/tabs/NewTabComponent.vue';
import WebViewControlsComponent from '../components/WebViewControlsComponent.vue';

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

const { allStandardAndPinnedLoadedTabs, activeTabId } = storeToRefs(tabStore);
const { sidebarVisible, slideSidebarIntoView, fullscreen, toolbarVisible } = storeToRefs(globalStore);

function switchTab(tabId: string) {
  const tabStore = useTabStore();
  tabStore.switchTab(tabId);
}

const onMouseLeave = () => {
  if (!sidebarVisible.value && slideSidebarIntoView.value) {
    globalStore.setSlideSidebarIntoView(false);
  }
}
</script>
