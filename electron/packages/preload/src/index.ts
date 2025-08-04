import {sha256sum} from './nodeCrypto.js';
import {versions} from './versions.js';
import {ipcRenderer} from 'electron';

function send(channel: string, message: string) {
  return ipcRenderer.invoke(channel, message);
}

function getPlatform(): string {
  return process.platform;
}

function onFullscreenChange(callback: (isFullscreen: boolean) => void) {
  ipcRenderer.on('fullscreen-changed', (_event, isFullscreen) => {
    callback(isFullscreen);
  });
}

function registerExtensionTab(tabId: number | undefined) {
  if (tabId === undefined) {
    console.warn('registerExtensionTab called with undefined tabId');
    return;
  }
  ipcRenderer.send('register-extension-tab', tabId);
}

export {sha256sum, versions, send, getPlatform, onFullscreenChange, registerExtensionTab};
