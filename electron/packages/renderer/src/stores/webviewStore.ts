import { defineStore } from 'pinia';
import type { IWebviewState } from '../../../shared/models/interfaces/IWebviewState';
import type { WebviewTag } from 'electron';

export const useWebviewStore = defineStore('webview', {
  state: () => ({
    webviews: [] as Array<IWebviewState>,
  }),
  actions: {
    registerWebview(tabId: string, webview: WebviewTag) {
      const existing = this.webviews.find((w: IWebviewState) => w.tabId === tabId);
      if (existing) {
        existing.webview = webview;
        existing.ready = false;
        existing.loading = true;
      } else {
        this.webviews.push({
          id: webview.getWebContentsId(),
          webview,
          ready: false,
          loading: true,
          crashed: false,
          tabId
        });
      }
    },

    deregisterWebview(tabId: string) {
      this.webviews = this.webviews.filter((w: IWebviewState) => w.tabId !== tabId);
    },

    setWebviewReady(tabId: string, ready: boolean) {
      const webviewState = this.webviews.find((w: IWebviewState) => w.tabId === tabId);
      if (webviewState) webviewState.ready = ready;
    },

    setWebviewLoading(tabId: string, loading: boolean) {
      const webviewState = this.webviews.find((w: IWebviewState) => w.tabId === tabId);
      if (webviewState) webviewState.loading = loading;
    },

    getWebviewForTab(tabId: string): WebviewTag | null {
      return this.webviews.find((w: IWebviewState) => w.tabId === tabId)?.webview || null;
    },

    getWebviewState(tabId: string): IWebviewState | null {
      return this.webviews.find((w: IWebviewState) => w.tabId === tabId) || null;
    },

    getTabIdByWebviewId(webviewId: number): string | null {
      const webviewState = this.webviews.find((w: IWebviewState) => w.id === webviewId);
      return webviewState ? webviewState.tabId : null;
    },
  },
  getters: {
  },
});
