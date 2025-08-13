// utils/watchAndSync.ts
import { watch } from 'vue'
import { debounce } from 'vue-debounce'

export function watchAndSync(source: any, saveFn: () => void, delay = 500) {
  const debounced = debounce(saveFn, delay)
  watch(source, () => debounced(), { deep: true })
}
