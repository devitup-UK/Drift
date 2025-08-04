<template>
  <div class="web-content">
    <ToolbarComponent v-if="toolbarVisible" />
    <WebViewComponent
      v-for="tab in allStandardAndPinnedLoadedTabs"
      :key="tab.id"
      :tab="tab"></WebViewComponent>
  </div>
</template>

<style lang="scss" scoped>
.web-content {
  flex: 1;
  box-shadow: 0px 0px 3px 1px rgba(27, 27, 27, 0.75);
  border-radius: 8px;
}
</style>

<script setup lang="ts">
import { useGlobalStore } from '../stores/globalStore';
import { useTabStore } from '../stores/tabStore';
import { storeToRefs } from 'pinia';
import WebViewComponent from '../components/WebViewComponent.vue';
import ToolbarComponent from '../components/ToolbarComponent.vue';

const { allStandardAndPinnedLoadedTabs, activeTabId } = storeToRefs(useTabStore());
const {toolbarVisible} = storeToRefs(useGlobalStore());

</script>
