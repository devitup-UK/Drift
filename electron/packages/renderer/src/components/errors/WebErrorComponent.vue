<template>
  <div class="web-error">
    <FontAwesomeIcon icon="exclamation-circle" size="6x" class="web-error__icon" fixed-width />
    <div class="web-error__description" v-html="content" />
    <button class="web-error__reload">Reload</button>
  </div>
</template>

<style lang="scss" scoped>
.web-error {
  display: flex;
  align-items: center;
  flex-direction: column;
  color: #FFF;

  .web-error__description {
    text-align: left;
  }

  .web-error__icon {
    margin: 0 0 20px;
  }

  .web-error__reload {
    padding: 10px;
    background: #FFF;
    border-width: 0;
    border-radius: 8px;
    margin: 20px 0 0;
  }
}
</style>

<script setup lang="ts">
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { computed } from 'vue';

const props = defineProps<{
  code: number;
  description: string;
}>();

const content = computed(() => {
  switch(props.code) {
    case -105:
    case -106:
    case -2:
      return `<strong style="display: block; text-align: center;">Connection error!</strong><br><p>Try one of these options: -</p><ul><li>Checking the network cables, modem and router</li><li>Reconnecting to Wi-Fi</li></ul><br><small>${props.description}</small>`
      break;
  }
})
</script>
