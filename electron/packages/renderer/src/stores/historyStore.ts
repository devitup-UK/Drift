import { defineStore } from 'pinia';
import type { IHistoryEntry } from '../../../shared/models/interfaces/IHistoryEntry'

export const useHistoryStore = defineStore('history', {
  state: () => ({
    history: [] as Array<IHistoryEntry>,
  }),
  getters: {
    activeHistoryEntries: (state) => {
      return state.history.filter(entry => entry.isActive);
    },
    historyByTabId: (state) => {
      return (tabId: string) => state.history.filter(entry => entry.tabId === tabId);
    },
    activeHistoryEntryForTab: (state) => {
      return (tabId: string) => state.history.find(entry => entry.tabId === tabId && entry.isActive) || null;
    },
    recentHistoryByTab: (state) => {
      return (tabId: string, url: string, withinMs: number = 1000) => {
        const now = Date.now();
        const tabHistory = state.history.filter(entry => entry.tabId === tabId);

        for (let i = tabHistory.length - 1; i >= 0; i--) {
          const entry = tabHistory[i];
          if (entry.url === url && now - entry.timestamp <= withinMs) {
            return entry;
          }
        }

        return null;
      }
    }
  },
  actions: {
    addHistoryEntry(tabId: string, url: string, title: string = '', favicon: string = '') {
      if (!url || url === 'about:blank' || url.startsWith('chrome-error://')) return;

      const recent = this.recentHistoryByTab(tabId, url);
      if (recent) return;

      const newEntry: IHistoryEntry = {
        id: crypto.randomUUID(),
        timestamp: Date.now(),
        url,
        title,
        favicon,
        tabId,
        isActive: true
      };
      this.history.push(newEntry);
    },
    removeHistoryEntry(entryId: string) {
      this.history = this.history.filter(entry => entry.id !== entryId);
    },
    clearHistoryForTab(tabId: string) {
      this.history = this.history.filter(entry => entry.tabId !== tabId);
    },
    clearAllHistory() {
      this.history = [];
    },
    setHistoryEntryActive(entryId: string, isActive: boolean) {
      const entry = this.history.find(e => e.id === entryId);
      if (entry) {
        entry.isActive = isActive;
      }
    }
  },
});
