<template>
  <div class="new-tab" @click="openControlBar">
    <div class="new-tab__icon">
      <FontAwesomeIcon icon="plus" />
    </div>
    <label class="new-tab__label">New Tab</label>
  </div>
</template>

<style lang="scss" scoped>
.new-tab {
  margin: 4px 0 0;
  display: flex;
  align-items: center;
  padding: 10px 14px;
  border-radius: 10px;
  color: #bebebe;
  font-size: 13px;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  .new-tab__icon {
    margin-right: 8px;
  }
}
</style>

<script setup lang="ts">
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalStore } from '../../stores/globalStore';

const globalStore = useGlobalStore();

function openControlBar() {
  globalStore.openControlBarInNewTabMode();
}
</script>
