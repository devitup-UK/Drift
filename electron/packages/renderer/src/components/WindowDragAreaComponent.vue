<template>
  <div class="window-drag-area">
    <slot></slot>
  </div>
</template>

<style lang="scss" scoped>
.window-drag-area {
  -webkit-app-region: drag;
  width: 100%;
  height: 10px;
  position: absolute;
  top: 0;
  right: 0;
  left: 0;
}
</style>

<script setup lang="ts">
// This component is used to create a draggable area for the window.
</script>
