import { useTabStore } from "../stores/tabStore";

// TabManager.ts
export class TabManager {
  private idleCleanupInterval: number = 60000; // 1 minute

  init() {
    this.startIdleCleanup();
  }
  updateLastInteractedAt(tabId: string) {
    const tabStore = useTabStore();
    const tab = tabStore.getTabById(tabId);
    if (!tab) {
      console.warn(`Tab with ID ${tabId} not found.`);
      return;
    }
    tabStore.setTabLastInteractedAt(tabId, Date.now());
  }

  archiveTab(tabId: string) {
    // If we archive a tab, we need to either switch to the previously active tab or set the active tab to null.

    const tabStore = useTabStore();
    const tab = tabStore.getTabById(tabId);
    if (!tab) {
      console.warn(`Tab with ID ${tabId} not found.`);
      return;
    }
    tabStore.archiveTab(tabId);
  }

  private startIdleCleanup() {
    const tabStore = useTabStore();

    setInterval(() => {
      const now = Date.now();
      // If the tab has not been interacted with for 5 minutes and is not playing media, archive it
      const cutoff = 5 * 60 * 1000;

      for (const tab of tabStore.standardTabs) {
        if (!tab.isMediaPlaying && now - tab.lastInteractedAt > cutoff) {
          this.archiveTab(tab.id);
        }
      }
    }, this.idleCleanupInterval);
  }
}

export const tabManager = new TabManager();
