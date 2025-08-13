<template>
  <OverlayComponent class="overlay--control-bar">
    <div class="control-bar">
      <div class="control-bar__input">
        <FontAwesomeIcon icon="search" class="search-icon" />
        <input ref="urlInput" type="text" v-model="url" @keydown="createNewTab" placeholder="Search or Enter URL..." />
      </div>
      <div class="suggestions-border" v-if="suggestions.length"></div>
      <ul class="control-bar__suggestions" v-if="suggestions.length">
        <li v-for="suggestion in suggestions" :key="suggestion" @click="createNewTabWithSuggestion(suggestion)" :class="{ selected: selectedSuggestion === suggestion }">
          <FontAwesomeIcon icon="search" fixed-width/>
          <span>{{ suggestion }}</span>
        </li>
      </ul>
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
  position: absolute;
  top: 30%;

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

  .suggestions-border {
    width: calc(100% - 16px);
    margin: 0 auto;
    height: 1px;
    background: #868686;
  }

  .control-bar__suggestions {
    list-style: none;
    padding: 0;
    margin: 0;

    li {
      padding: 12px 18px;
      text-align: left;
      font-size: 14px;
      color: #868686;
      list-style: none;
      margin: 5px;
      border-radius: 6px;
      cursor: default;
      display: flex;
      align-items: center;

      span {
        margin-left: 6px;
        font-size: 12px;
      }

      &:hover {
        background-color: rgba(255, 255, 255, 0.1);
        color: #FFF;
      }

      &.selected {
        background-color: rgba(255, 255, 255, 0.1);
        color: #FFF;
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
import { useWebviewStore } from '../stores/webviewStore';
import { getSuggestions } from '../services/googleSuggestionsService';
import { debounce } from 'vue-debounce';
import { useHistoryStore } from '../stores/historyStore';
import { resolveUrl } from '../helpers/stringHelper';

const suggestions = ref<string[]>([]);
const url = ref('');
const urlInput = ref<HTMLInputElement | null>(null);
const { controlBarMode } = storeToRefs(useGlobalStore());
const tabStore = useTabStore();
const webViewStore = useWebviewStore();
const selectedSuggestion = ref<string | null>(null);

onMounted(() => {
  if (controlBarMode.value === 'edit') {
    if (tabStore.activeTab) {
      url.value = webViewStore.getWebviewForTab(tabStore.activeTab.id)?.getURL() || '';
    }
  }

  nextTick(() => {
    if (urlInput.value) {
      urlInput.value.focus();
      urlInput.value.select();
    }
  });
});

const getSuggestionsDebounced = debounce(async (val: string) => {
  if (val.trim() === '') {
    suggestions.value = [];
    return;
  }
  suggestions.value = await getSuggestions(val);
}, 200);

async function createNewTab(event: KeyboardEvent) {
  const isArrowKey = ['ArrowUp', 'ArrowDown'].includes(event.key);
  const isEnterKey = event.key === 'Enter';

  if(isArrowKey) {
    if (suggestions.value.length > 0) {
      const currentIndex = suggestions.value.indexOf(selectedSuggestion.value ?? '') ?? -1;
      if (event.key === 'ArrowDown') {
        selectedSuggestion.value = suggestions.value[(currentIndex + 1) % suggestions.value.length];
        url.value = selectedSuggestion.value || url.value;
      } else if (event.key === 'ArrowUp') {
        selectedSuggestion.value = suggestions.value[(currentIndex - 1 + suggestions.value.length) % suggestions.value.length];
        url.value = selectedSuggestion.value || url.value;
      }
    }
    event.preventDefault();
    return;
  }

  if (!isArrowKey && !isEnterKey) {
    getSuggestionsDebounced(url.value);
    return;
  }

  if (isEnterKey) {
    const tabStore = useTabStore();
    if (controlBarMode.value === 'edit') {
      if (tabStore.activeTabId) {
        // tabStore.addHistoryEntryToTab(tabStore.activeTabId, resolveUrl(url.value));
        console.log("Loading new URL from edit")
        webViewStore.getWebviewForTab(tabStore.activeTabId)?.loadURL(resolveUrl(url.value));
      }
    } else {
      tabStore.addTab(url.value);
    }

    const globalStore = useGlobalStore();
    globalStore.closeControlBar();
    event.preventDefault();
  }
}

async function createNewTabWithSuggestion(suggestion: string) {
  const tabStore = useTabStore();
  if (controlBarMode.value === 'edit') {
    if (tabStore.activeTabId) {
      // tabStore.addHistoryEntryToTab(tabStore.activeTabId, resolveUrl(url.value));
    }
  } else {
    tabStore.addTab(suggestion);
  }

  const globalStore = useGlobalStore();
  globalStore.closeControlBar();
}
</script>
