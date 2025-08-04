import { createApp } from 'vue'
import App from './App.vue'
import { createPinia } from 'pinia'

import { library } from '@fortawesome/fontawesome-svg-core'
import {
  faArrowLeft,
  faArrowRight,
  faSearch,
  faGlobe,
  faRotateRight,
  faExclamationCircle,
  faCircleNotch,
  faTimes,
  faRectangleList,
  faPlus
} from '@fortawesome/free-solid-svg-icons';


library.add(
  faArrowLeft,
  faArrowRight,
  faSearch,
  faGlobe,
  faRotateRight,
  faExclamationCircle,
  faCircleNotch,
  faTimes,
  faRectangleList,
  faPlus
)

const app = createApp(App)
app.use(createPinia())
app.mount('#app')
