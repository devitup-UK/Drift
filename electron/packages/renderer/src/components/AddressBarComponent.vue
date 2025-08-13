<template>
  <div class="address-bar" :class="{ 'address-bar--toolbar': toolbar }">
    <FontAwesomeIcon class="address-bar__search" icon="search" v-if="!activeTab && !toolbar" />
    <div class="address-bar__url" :class="{'address-bar__url--filled': activeUrl}">{{ activeUrl }}</div>
    <ul class="address-bar__extensions">
      <li class="address-bar-extension" v-for="extension in extensions" :key="extension.name">
        <img :src="extension.icon" :alt="extension.name" :title="extension.name" />
      </li>
    </ul>
    <ul class="address-bar__actions">
      <li class="address-bar-action" v-for="action in actions" :key="action.name">{{ action.icon }}</li>
    </ul>
  </div>
</template>

<style lang="scss" scoped>
@use '../assets/styles/global.scss';

.address-bar {
  @extend .truncate;
  display: flex;
  font-size: 12px;
  font-weight: 500;
  align-items: center;
  background: rgba(255, 255, 255, 0.125);
  padding: 10px 16px;
  border-radius: 12px;
  color: rgba(255, 255, 255, 0.125);

  .address-bar__search {
    margin-right: 8px;
  }

  .address-bar__url {

    &.address-bar__url--filled {
      color: rgb(182, 182, 182);
    }
  }

  .address-bar__extensions {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    align-items: center;
    margin-left: auto;

    .address-bar-extension {
      display: flex;
      align-items: center;
      margin-right: 8px;
    }
  }

  .address-bar__actions {
    display: none;
  }

  &.address-bar--toolbar {
    background: transparent;

    &:hover {
      background: transparent;
      transition: unset;
    }

    .address-bar__url {
      padding: 3px 10px;

      &:hover {
        background: rgb(151 151 151 / 26%);
        border-radius: 6px;
      }
    }
  }

  &:hover {
    background: rgba(255, 255, 255, 0.2);
    transition: background 0.3s ease-in-out;
    cursor: default;

    .address-bar__actions {
      opacity: 1;
    }
  }
}
</style>

<script setup lang="ts">
import { useTabStore } from '../stores/tabStore';
import { computed, ref, watch } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { displayUrl } from '../helpers/stringHelper';
import { storeToRefs } from 'pinia';
import { useWebviewStore } from '../stores/webviewStore';
import { useExtensionStore } from '../stores/extensionStore';
const actions: Array<{ name: string, icon: string }> = [];

const webviewStore = useWebviewStore();
const { activeTab, activeTabId } = storeToRefs(useTabStore());

const extensionStore = useExtensionStore();
const extensions = computed(() => extensionStore.getExtensions);

const activeWebviewState = computed(() => {
  if(!activeTabId.value) return null;
  return webviewStore.getWebviewState(activeTabId.value)
});

const activeUrl = ref('');

function updateUrl() {
  try {
    const webview = activeWebviewState.value?.webview;
    if (!webview) {
      activeUrl.value = 'Search or Enter URL';
    } else {
      activeUrl.value = displayUrl(webview.getURL());
    }
  } catch (e) {
    activeUrl.value = 'Search or Enter URL';
  }
}

// Watch for tab change or webview change
watch(activeWebviewState, (newVal, oldVal) => {
  const webview = newVal?.webview;
  if (!webview) {
    activeUrl.value = 'Search or Enter URL';
    return;
  }

  // Wait a tick in case webview isn't attached yet
  setTimeout(() => updateUrl(), 200);

  // Attach listeners for when nav state might change
  webview.addEventListener('did-navigate', updateUrl);
  webview.addEventListener('did-navigate-in-page', updateUrl);
  webview.addEventListener('did-finish-load', updateUrl);
}, { immediate: true });

defineProps<{
  toolbar?: boolean;
}>();
</script>
