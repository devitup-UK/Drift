<template>
  <div class="address-bar" :class="{ 'address-bar--toolbar': toolbar }">
    <FontAwesomeIcon class="address-bar__search" icon="search" v-if="!activeTab && !toolbar" />
    <div class="address-bar__url" :class="{'address-bar__url--filled': activeUrl}">{{ activeUrl }}</div>
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
import { computed } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { displayUrl } from '../helpers/stringHelper';
import { storeToRefs } from 'pinia';
const actions: Array<{ name: string, icon: string }> = [];

const { activeTab } = storeToRefs(useTabStore());
const activeUrl = computed(() => displayUrl(useTabStore().activePage?.url));

defineProps<{
  toolbar?: boolean;
}>();
</script>
