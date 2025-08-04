<template>
  <OverlayComponent class="overlay--control-bar">
    <div class="control-bar">
      <div class="control-bar__input">
        <FontAwesomeIcon icon="search" class="search-icon" />
        <input ref="urlInput" type="text" v-model="url" @keydown="createNewTab" placeholder="Search or Enter URL..." />
      </div>
      <!-- <div class="new-tab__suggestions">
        <p>Suggestions will go here...</p>
      </div> -->
    </div>
  </OverlayComponent>
</template>

<style lang="scss" scoped>
.overlay--control-bar {
  background: transparent;
}

.search-icon {
  margin-right: 10px;
}

.control-bar {
  width: 766px;
  text-align: center;
  border-style: solid;
  background: #111111;
  border-radius: 10px;
  border-width: 1px;
  border-color: #868686;
  color: #FFF;
  font-family: system-ui;
  font-weight: 300;
  margin: -10% 0 0;

  .control-bar__input {
    padding: 20px;
    text-align: left;
    display: flex;
    align-items: center;

    input {
      width: 100%;
      background: transparent;
      border-width: 0;
      font-size: 20px;
      color: #FFF;

      &::placeholder {
        color: #868686;
      }

      &::focus {
        outline: none;
      }

      &::selection {
        background: #868686;
        color: #FFF;
      }

      &:focus-visible {
        outline: none;
      }
    }
  }
}
</style>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue';
import OverlayComponent from './OverlayComponent.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useTabStore } from '../stores/tabStore';
import { useGlobalStore } from '../stores/globalStore';
import { storeToRefs } from 'pinia';
import { resolveUrl } from '../helpers/stringHelper';

const url = ref('');
const urlInput = ref<HTMLInputElement | null>(null);
const { controlBarMode } = storeToRefs(useGlobalStore());
const tabStore = useTabStore();

onMounted(() => {
  if (controlBarMode.value === 'edit') {
    url.value = tabStore.activePage?.url || '';
  }

  nextTick(() => {
    if (urlInput.value) {
      urlInput.value.focus();
      urlInput.value.select();
    }
  });
});

function createNewTab(event: KeyboardEvent) {
  if (event.key === 'Enter') {
    const tabStore = useTabStore();
    if (controlBarMode.value === 'edit') {
      if (tabStore.activeTabId) {
        tabStore.addHistoryEntryToTab(tabStore.activeTabId, resolveUrl(url.value));
      }
    } else {
      tabStore.addTab(url.value);
    }

    const globalStore = useGlobalStore();
    globalStore.closeControlBar();
    event.preventDefault();
  }
}
</script>
