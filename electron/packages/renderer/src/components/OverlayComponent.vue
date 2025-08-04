<template>
  <div class="overlay">
    <!-- <div class="overlay__content"> -->
      <slot></slot>
    <!-- </div> -->
  </div>
</template>

<style lang="scss" scoped>
.overlay {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 1000;
}
</style>
