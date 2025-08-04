import type { WebviewTag } from 'electron';

export interface IWebviewState {
  id: string;
  webview: WebviewTag | null;
  ready: boolean;
  loading: boolean;
  crashed: boolean;
}
