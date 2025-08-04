import { defineStore } from 'pinia';
import Tab from '../models/Tab';
import { resolveUrl } from '../helpers/stringHelper';
import { TabType } from '../models/enums/TabType';

export const useTabStore = defineStore('tab', {
  state: () => ({
    tabs: [] as Array<Tab>,
    activeTabId: null as string | null,
    reloadSignals: {} as Record<string, number>
  }),
  getters: {
    activePage: (state) => {
      const activeTab = state.tabs.find(tab => tab.id === state.activeTabId);
      return activeTab ? activeTab.getActiveHistoryEntry() : null;
    },
    activeTab: (state) => {
      return state.tabs.find(tab => tab.id === state.activeTabId) || null;
    },
    standardTabs: (state) => {
      return state.tabs.filter(tab => tab.type == TabType.Standard && !tab.archived);
    },
    pinnedOrFolderTabs: (state) => {
      return state.tabs.filter(tab => (tab.type == TabType.Pinned || tab.type == TabType.Folder) && !tab.archived);
    },
    archivedTabs: (state) => {
      return state.tabs.filter(tab => tab.archived);
    },
    unloadedTabs: (state) => {
      return state.tabs.filter(tab => tab.unloaded);
    },
    allStandardAndPinnedLoadedTabs: (state) => {
      return state.tabs.filter(tab => !tab.unloaded && (tab.type === TabType.Standard || tab.type === TabType.Pinned) && !tab.archived);
    }
  },
  actions: {
    addTab(url: string) {
      url = resolveUrl(url);
      const id = crypto.randomUUID();
      const newTab = new Tab(id, url, url);
      this.tabs.push(newTab);
      this.activeTabId = id;
    },

    switchTab(id: string) {
      const tab = this.tabs.find(t => t.id === id);
      if (tab) {
        this.activeTabId = id;
      }
    },

    setTabTitle(id: string, title: string) {
      const tab = this.tabs.find(t => t.id === id);
      const activePage = tab?.getActiveHistoryEntry();
      if (activePage && activePage.title != title) activePage.title = title;
    },

    addHistoryEntryToTab(id: string, url: string) {
      const tab = this.tabs.find(t => t.id === id);
      if (tab) tab.addHistoryEntry(url);
    },

    setTabFavicon(id: string, faviconUrl: string) {
      const tab = this.tabs.find(t => t.id === id);
      if (tab) tab.setFavicon(faviconUrl);
    },

    requestReload(tabId: string) {
      this.reloadSignals[tabId] = Date.now(); // new timestamp = reload requested
    },

    stopLoading(tabId: string) {
      const webview = document.querySelector(`webview[data-tab-id="${tabId}"]`) as Electron.WebviewTag | null;
      if (webview) {
        webview.stop();
      }
    },

    archiveTab(id: string) {
      const tab = this.tabs.find(t => t.id === id);
      if (tab) {
        tab.archive();
        this.updateTab(id, tab);
        if (this.activeTabId == id) {
          this.clearActiveTab();
        }
      }
    },

    updateTab(id: string, tab: Tab) {
      const index = this.tabs.findIndex(t => t.id === id);
      if (index !== -1) {
        this.tabs[index] = tab;
      } else {
        console.warn(`Tab with id ${id} not found for update.`);
      }
    },

    clearActiveTab() {
      this.activeTabId = null;
    },
  },
});
