<template>
  <div class="layout-control" :class="{ 'layout-control--sidebar-hidden': !isSidebarVisible }" @mousedown="onMouseDown" @mouseover="onMouseOver">
    <slot></slot>
  </div>
</template>

<style lang="scss" scoped>
.layout-control {
  height: 100%;
  width: 4px;
  margin: 0 2px 0 4px;
  cursor: col-resize;
  border-radius: 100px;

  &:hover {
    background-color: #ccc;
    transition: background-color 0.3s ease;
  }

  &.layout-control--sidebar-hidden {
    cursor: default;
    margin: 0;
    &:hover {
      background-color: transparent;
      transition: unset;
    }
  }
}
</style>

<script setup lang="ts">
import { defineEmits } from 'vue';
import { storeToRefs } from 'pinia';
import { useGlobalStore } from '../stores/globalStore';


const { sidebarWidth, isSidebarVisible } = storeToRefs(useGlobalStore());
const globalStore = useGlobalStore();

const emit = defineEmits<{
  (e: 'resize', newWidth: number): void;
  (e: 'resize-start'): void;
  (e: 'resize-end'): void;
}>();

let startX: number;
let startWidth: number;

const onMouseMove = (e: MouseEvent) => {
  const dx = e.clientX - startX;
  const newWidth = Math.max(160, startWidth + dx); // min width of 100px
  emit('resize', newWidth);
};

const onMouseUp = () => {
  window.removeEventListener('mousemove', onMouseMove);
  window.removeEventListener('mouseup', onMouseUp);
  emit('resize-end');
};

const onMouseDown = (e: MouseEvent) => {
  if(!isSidebarVisible.value) {
    return;
  };

  startX = e.clientX;
  startWidth = sidebarWidth.value;

  window.addEventListener('mousemove', onMouseMove);
  window.addEventListener('mouseup', onMouseUp);
  emit('resize-start');
};

const onMouseOver = () => {
  if(!isSidebarVisible.value) {
    globalStore.setSlideSidebarIntoView(true);
  }
};
</script>
