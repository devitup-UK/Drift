import type { WebviewTag } from 'electron';

export interface IWebviewState {
  id: number;
  webview: WebviewTag | null;
  ready: boolean;
  loading: boolean;
  crashed: boolean;
  tabId: string;
}
