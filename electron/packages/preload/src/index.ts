import {sha256sum} from './nodeCrypto.js';
import {versions} from './versions.js';
import {app, ipcRenderer} from 'electron';
import path from 'path';
import Tab from '@app/shared/models/Tab.js';
import ChromeExtension from '@app/shared/models/ChromeExtension.js';

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

function onOpenInNewTab(callback: (url: string) => void) {
  ipcRenderer.on('open-in-new-tab', (_event, url) => {
    console.log('Open in new tab:', url);
    callback(url);
  });
}

function onMediaPlaying(callback: (webContentsId: number) => void) {
  ipcRenderer.on('media-playing', (_event, webContentsId) => {
    console.log('Web contents media started playing:', webContentsId);
    callback(webContentsId);
  });
}

function onMediaPaused(callback: (webContentsId: number) => void) {
  ipcRenderer.on('media-paused', (_event, webContentsId) => {
    console.log('Web contents media paused:', webContentsId);
    callback(webContentsId);
  });
}

function onExtensionInstalled(callback: (extension: ChromeExtension) => void) {
  ipcRenderer.on('extension-installed', (_event, extensionDetails) => {
    console.log('Extension installed:', extensionDetails);
    callback(extensionDetails);
  });
}

function onExtensionRemoved(callback: (extension: ChromeExtension) => void) {
  ipcRenderer.on('extension-removed', (_event, extensionDetails) => {
    console.log('Extension removed:', extensionDetails);
    callback(extensionDetails);
  });
}

function onTabInteraction(callback: (webContentsId: number) => void) {
  ipcRenderer.on('tab-interaction', (_event, webContentsId) => {
    console.log('Tab interacted:', webContentsId);
    callback(webContentsId);
  });
}

function registerExtensionTab(tabId: number | undefined) {
  if (tabId === undefined) {
    console.warn('registerExtensionTab called with undefined tabId');
    return;
  }
  ipcRenderer.send('register-extension-tab', tabId);
}

function addTabToDatabase(tab: Tab) {
  ipcRenderer.invoke('db:add-tab', tab).then(() => {
    console.log('Tab added:', tab);
  }).catch((error) => {
    console.error('Failed to add tab:', error);
  });
}

function updateTabInDatabase(tab: Tab) {
  ipcRenderer.invoke('db:update-tab', tab).then(() => {
    console.log('Tab updated:', tab);
  }).catch((error) => {
    console.error('Failed to update tab:', error);
  });
}

function getTabsFromDatabase(): Promise<Tab[]> {
  return ipcRenderer.invoke('db:get-tabs');
}

export {sha256sum, versions, send, getPlatform, onFullscreenChange, onOpenInNewTab, onMediaPlaying, onMediaPaused, registerExtensionTab, addTabToDatabase, getTabsFromDatabase, updateTabInDatabase, onTabInteraction, onExtensionInstalled, onExtensionRemoved};
