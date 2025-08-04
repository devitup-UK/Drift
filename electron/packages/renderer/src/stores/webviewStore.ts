import { defineStore } from 'pinia';
import type { IWebviewState } from '../models/interfaces/IWebviewState';
import type { WebviewTag } from 'electron';

export const useWebviewStore = defineStore('webview', {
  state: () => ({
    webviews: [] as Array<IWebviewState>,
  }),
  actions: {
    registerWebview(tabId: string, webview: WebviewTag) {
      const existing = this.webviews.find(w => w.id === tabId);
      if (existing) {
        existing.webview = webview;
        existing.ready = false;
        existing.loading = true;
      } else {
        this.webviews.push({
          id: tabId,
          webview,
          ready: false,
          loading: true,
          crashed: false,
        });
      }
    },

    deregisterWebview(tabId: string) {
      this.webviews = this.webviews.filter(w => w.id !== tabId);
    },

    setWebviewReady(tabId: string, ready: boolean) {
      const webviewState = this.webviews.find(w => w.id === tabId);
      if (webviewState) webviewState.ready = ready;
    },

    setWebviewLoading(tabId: string, loading: boolean) {
      const webviewState = this.webviews.find(w => w.id === tabId);
      if (webviewState) webviewState.loading = loading;
    },

    getWebview(tabId: string): WebviewTag | null {
      return this.webviews.find(w => w.id === tabId)?.webview || null;
    },

    getWebviewState(tabId: string): IWebviewState | null {
      return this.webviews.find(w => w.id === tabId) || null;
    }
  },
  getters: {
  },
});
