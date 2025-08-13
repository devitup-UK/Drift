import { defineStore } from 'pinia';
import Tab from '../../../shared/models/Tab';
import { resolveUrl } from '../helpers/stringHelper';
import { TabType } from '../../../shared/models/enums/TabType';
import { addTabToDatabase, updateTabInDatabase } from '@app/preload';

export const useTabStore = defineStore('tab', {
  state: () => ({
    pinnedTabsAndFolders: [] as Array<Tab>,
    standardTabs: [] as Array<Tab>,
    activeTabIdHistory: [] as Array<string | null>,
    reloadSignals: {} as Record<string, number>
  }),
  getters: {
    activeTab: (state) => {
      const activeTabId = state.activeTabIdHistory[state.activeTabIdHistory.length - 1];
      if (!activeTabId) return null;
      // Look for the active tab by ID in pinnedTabsAndFolders and standardTabs
      if (activeTabId === null) return null;
      return state.pinnedTabsAndFolders.find(tab => tab.id === activeTabId) ||
             state.standardTabs.find(tab => tab.id === activeTabId) || null;
    },
    activeTabId: (state) => state.activeTabIdHistory[state.activeTabIdHistory.length - 1] || null,
    allTabs: (state) => {
      return state.standardTabs.concat(state.pinnedTabsAndFolders);
    },
    archivedTabs: (state) => {
      return state.standardTabs.filter(tab => tab.archived).concat(
        state.pinnedTabsAndFolders.filter(tab => tab.archived)
      );
    },
    unloadedTabs: (state) => {
      return state.standardTabs.filter(tab => tab.unloaded).concat(
        state.pinnedTabsAndFolders.filter(tab => tab.unloaded)
      );
    },
    allLoadedTabs: (state) => {
      return state.standardTabs.filter(tab => !tab.unloaded && !tab.archived).concat(
        state.pinnedTabsAndFolders.filter(tab => !tab.unloaded && !tab.archived)
      );
    },
    allTabsShouldRestoreWebview: (state) => {
      return state.standardTabs.filter(tab => !tab.unloaded && !tab.archived && !tab.wasRestoredFromDatabase
      );
    },
    allActivePinnedTabs: (state) => {
      return state.pinnedTabsAndFolders.filter(tab => !tab.archived && tab.type === TabType.Pinned);
    },
    allActiveStandardTabs: (state) => {
      return state.standardTabs.filter(tab => !tab.archived && tab.type === TabType.Standard);
    }
  },
  actions: {
    addTab(url: string) {
      url = resolveUrl(url);
      const id = crypto.randomUUID();
      const newTab = new Tab(id, url, url, url);
      this.standardTabs.push(newTab);
      this.activeTabIdHistory.push(id);
      addTabToDatabase(newTab);
    },

    switchTab(id: string) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        this.activeTabIdHistory.push(id);
        this.setTabWasRestoredFromDatabase(id, false);
      }
    },

    setTabWasRestoredFromDatabase(id: string, restored: boolean) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.wasRestoredFromDatabase = restored;
        updateTabInDatabase(tab.toJSON());
      }
    },

    setTabTitle(id: string, title: string) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.setTitle(title);
        updateTabInDatabase(tab.toJSON());
      }
    },

    setHasBeenLoaded(id: string, loaded: boolean) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.setHasBeenLoaded(loaded);
        updateTabInDatabase(tab.toJSON());
      }
    },

    setTabUrl(id: string, url: string) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.setUrl(url);
        updateTabInDatabase(tab.toJSON());
      }
    },

    setTabFavicon(id: string, favicon: string) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.setFavicon(favicon);
        updateTabInDatabase(tab.toJSON());
      }
    },

    setTabLastInteractedAt(id: string, timestamp: number) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.setLastInteractedAt(timestamp);
      }
    },

    setTabMediaPlaying(id: string, isPlaying: boolean) {
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.setIsMediaPlaying(isPlaying);
        updateTabInDatabase(tab.toJSON());
      }
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
      const tab = this.allTabs.find(t => t.id === id);
      if (tab) {
        tab.archive();
        this.updateTab(id, tab);
        if (this.activeTabId == id) {
          this.clearActiveTab();
        }
        updateTabInDatabase(tab.toJSON());
      }
    },

    getPreviousTab(id: string, type: string): Tab | null {
      if (type === TabType.Pinned || type === TabType.Folder) {
        const index = this.allActivePinnedTabs.findIndex(t => t.id === id);
        if (index > 0) {
          return this.allActivePinnedTabs[index - 1];
        }
        return null;
      }
      // For standard tabs, find the index in standardTabs
      const index = this.standardTabs.findIndex(t => t.id === id);
      if (index > 0) {
        return this.allActiveStandardTabs[index - 1];
      }

      return null;
    },

    updateTab(id: string, tab: Tab) {
      const pinnedTabsAndFoldersIndex = this.pinnedTabsAndFolders.findIndex(t => t.id === id);
      const standardTabsIndex = this.standardTabs.findIndex(t => t.id === id);
      if (pinnedTabsAndFoldersIndex !== -1) {
        this.pinnedTabsAndFolders[pinnedTabsAndFoldersIndex] = tab;
      } else if (standardTabsIndex !== -1) {
        this.standardTabs[standardTabsIndex] = tab;
      } else {
        console.warn(`Tab with id ${id} not found for update.`);
      }
      updateTabInDatabase(tab.toJSON());
    },

    clearActiveTab() {
      this.activeTabIdHistory.pop();
    },

    getTabById(id: string): Tab | null {
      return this.allTabs.find(t => t.id === id) || null;
    }
  },
});
