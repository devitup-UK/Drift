<template>
  <li>
    <template v-if="!webviewState?.loading">
      <img v-if="tab.getActiveHistoryEntry()?.favicon.length" :src="tab.getActiveHistoryEntry()?.favicon" alt="Favicon" class="tab-favicon" />
      <FontAwesomeIcon icon="globe" class="tab-favicon" v-if="!tab.getActiveHistoryEntry()?.favicon.length" />
    </template>
    <FontAwesomeIcon icon="circle-notch" class="tab-favicon" spin v-if="webviewState?.loading" />
    <span class="tab-title" @dblclick.stop="editingTitle = true" v-if="!editingTitle">{{ tab.hasCustomTitle() ? tab.customTitle : tab.getActiveHistoryEntry().title }}</span>
    <input ref="titleInput" class="tab-title-input" v-model="customTitle" @blur="editingTitle = false" @keydown.enter="setCustomTitle(customTitle)" @keydown.escape="editingTitle = false" v-else />
    <div class="tab-controls">
      <div class="tab-controls__item" @click.stop="archiveTab(tab.id)">
        <FontAwesomeIcon icon="times" />
      </div>
    </div>
  </li>
</template>

<style lang="scss" scoped>
@use '../../assets/styles/global.scss';
.tab-title {
  @extend .truncate;
}

.tab-title-input {
  background: transparent;
  border-width: 0;
  color: inherit;
  font-size: inherit;
  margin: 0;
  padding: 0;

  &:focus {
    outline: none;
  }
}

.tab-controls {
  margin: 0 0 0 auto;
  align-items: center;
  justify-content: center;
  display: none;

  .tab-controls__item {
    display: flex;
    height: 20px;
    width: 20px;
    min-width: 20px;
    min-height: 20px;
    align-items: center;
    justify-content: center;
    border-radius: 6px;
    overflow: hidden;

    &:hover {
      background: rgba(255, 255, 255, 0.1);
    }
  }
}
</style>

<script setup lang="ts">
import { defineProps, ref, watch, nextTick, computed } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import Tab from '../../models/Tab';
import { useWebviewStore } from '../../stores/webviewStore';
import { useTabStore } from '../../stores/tabStore';

const props = defineProps<{
  tab: Tab;
}>();

const webviewStore = useWebviewStore();

const editingTitle = ref(false);
const customTitle = ref(props.tab.getActiveHistoryEntry().title ?? '');
const titleInput = ref<HTMLInputElement | null>(null);
const webviewState = computed(() => webviewStore.getWebviewState(props.tab.id));

watch(editingTitle, (newValue) => {
  if (newValue) {
    nextTick(() => {
      titleInput.value?.focus();
      titleInput.value?.select();
    });
  }
});

function setCustomTitle(newTitle: string) {
  if(newTitle.trim() === '') {
    customTitle.value = props.tab.getActiveHistoryEntry().title ?? ''; // Reset to original title if empty
  }
  props.tab.setCustomTitle(newTitle);
  editingTitle.value = false;
}

function archiveTab(tabId: string) {
  useTabStore().archiveTab(tabId);
  webviewStore.deregisterWebview(tabId);
}
</script>
