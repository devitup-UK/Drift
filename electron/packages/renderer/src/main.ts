import { createApp, reactive } from 'vue'
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
  faPlus,
  faVolumeHigh
} from '@fortawesome/free-solid-svg-icons';
import { useTabStore } from './stores/tabStore';
import { useHistoryStore } from './stores/historyStore';
import { getTabsFromDatabase } from '@app/preload';
import Tab from '../../shared/models/Tab';
import { TabType } from '../../shared/models/enums/TabType';


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
  faPlus,
  faVolumeHigh
)

const app = createApp(App)
app.use(createPinia())

const tabsFromDatabase = await getTabsFromDatabase();
const tabStore = useTabStore();
tabStore.$patch({
  standardTabs: tabsFromDatabase
    .filter(tab => !tab.archived && tab.type === TabType.Standard)
    .map(tab => new Tab(tab.id, tab.title, tab.url, tab.url, tab.customTitle, tab.favicon, tab.type, tab.folderId, tab.archived, tab.unloaded, tab.isMediaPlaying, tab.hasBeenLoaded, true)),

  pinnedTabsAndFolders: tabsFromDatabase
    .filter(tab => !tab.archived && (tab.type === TabType.Pinned || tab.type === TabType.Folder))
    .map(tab => new Tab(tab.id, tab.title, tab.url, tab.url, tab.customTitle, tab.favicon, tab.type, tab.folderId, tab.archived, tab.unloaded, tab.isMediaPlaying, tab.hasBeenLoaded, true)),
});

app.mount('#app')
