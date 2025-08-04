<template>
  <div class="toolbar">
    <WebViewControlsComponent :toolbarMode="true" show-web-view-controls />
    <AddressBarComponent @click="openControlBarComponent" toolbar />
    <div class="toolbar__extensions"></div>
  </div>
</template>

<style scoped lang="scss">
.toolbar {
  height: 30px;
  background: #FFF;
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>

<script setup lang="ts">
import AddressBarComponent from './AddressBarComponent.vue';
import { useTabStore } from '../stores/tabStore';
import { useGlobalStore } from '../stores/globalStore';
import WebViewControlsComponent from './WebViewControlsComponent.vue';

const tabStore = useTabStore();
const globalStore = useGlobalStore();

const openControlBarComponent = () => {
  if(tabStore.activeTabId) {
    globalStore.openControlBarInEditMode();
  } else {
    globalStore.openControlBarInNewTabMode();
  }
}
</script>
