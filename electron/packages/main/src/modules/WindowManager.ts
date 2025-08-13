import type {AppModule} from '../AppModule.js';
import {ModuleContext} from '../ModuleContext.js';
import {BaseWindow, BrowserWindow, MenuItem, WebContentsView, app, contextBridge, ipcMain, session, webContents} from 'electron';
import type {AppInitConfig} from '../AppInitConfig.js';
import { ElectronChromeExtensions } from 'electron-chrome-extensions';
import path from 'path';
import {buildChromeContextMenu} from 'electron-chrome-context-menu';
import { download } from 'electron-dl';

class WindowManager implements AppModule {
  readonly #preload: {path: string};
  readonly #renderer: {path: string} | URL;
  readonly #openDevTools;

  constructor({initConfig, openDevTools = false}: {initConfig: AppInitConfig, openDevTools?: boolean}) {
    this.#preload = initConfig.preload;
    this.#renderer = initConfig.renderer;
    this.#openDevTools = openDevTools;
  }

  async enable({app}: ModuleContext): Promise<void> {
    await app.whenReady();
    await this.restoreOrCreateWindow(true);

    // Intercept new webview contents to handle them
    app.on('web-contents-created', (event, contents) => {
      if (contents.getType() === 'webview') {
        console.log('[webview] Intercepted new webview contents');

        // Handle new window requests and convert them to new tabs.
        contents.setWindowOpenHandler(({ url }) => {
          console.log('[webview] Tried to open new window with URL:', url);

          // Send URL to your renderer to open a new tab
          for (const window of BrowserWindow.getAllWindows()) {
            window.webContents.send('open-in-new-tab', url);
          }

          return { action: 'deny' };
        });

        // Handle audio state changes
        contents.on('audio-state-changed', (event) => {
          console.log('[webview] Audio state changed');

          // Send URL to your renderer to open a new tab
          for (const window of BrowserWindow.getAllWindows()) {
            window.webContents.send(event.audible ? 'media-playing' : 'media-paused', contents.id);
          }
        });

        // Handle interaction to update last interacted time
        contents.on('input-event', (event, inputEvent) => {
          if(['mouseDown', 'keyUp'].includes(inputEvent.type)) {
            console.log('[webview] User interacted with webview');
            for (const window of BrowserWindow.getAllWindows()) {
              window.webContents.send('tab-interaction', contents.id);
            }
          }
        });

        contents.on('context-menu', (e, params) => {
          const menu = buildChromeContextMenu({
            params,
            webContents: contents,
            openLink: (url, disposition) => {
              for (const window of BrowserWindow.getAllWindows()) {
                window.webContents.send('open-in-new-tab', url);
              }
            },
            labels: {
              openInNewTab: (type) => `Open in New Tab`,
              openInNewWindow: (type) => `Open in New Window`,
              copyAddress: (type) => `Copy Address`,
              undo: 'Undo',
              redo: 'Redo',
              cut: 'Cut',
              copy: 'Copy',
              delete: 'Delete',
              paste: 'Paste',
              selectAll: 'Select All',
              back: 'Back',
              forward: 'Forward',
              reload: 'Reload',
              inspect: 'Inspect Element',
              addToDictionary: 'Add to Dictionary',
              exitFullScreen: 'Exit Full Screen',
              emoji: 'Emoji & Symbols',
            }
          })

          // Find the "Copy Address" menu item and insert a "Save Link As..." option before it
          console.log('Before', menu.items);
          const copyAddressIndex = menu.items.findIndex(item => item.label === 'Copy Address');
          if (copyAddressIndex !== -1) {
            menu.insert(copyAddressIndex, new MenuItem({
              label: 'Save Link As...',
              click: async () => {
                // Option 1: Use electron-dl
                for (const window of BrowserWindow.getAllWindows()) {
                  try {
                    const downloadResult = await download(window, params.linkURL, {
                      saveAs: true,
                      directory: app.getPath('downloads'),
                      filename: `download-${Date.now()}.${path.extname(params.linkURL).length ? path.extname(params.linkURL) : 'html'}`,
                    });

                    downloadResult.on('done', () => {
                      console.log('Download completed:', downloadResult.getSavePath());
                    });
                  } catch (error) {
                    // This usually happens if the download was cancelled or failed
                    console.error('Download failed:', error);
                  }
                }
              }
            }))
          }

          console.log('After', menu.items);

          menu.popup()
        })
      }
    });

    app.on('second-instance', () => this.restoreOrCreateWindow(true));
    app.on('activate', () => this.restoreOrCreateWindow(true));
  }

  async createWindow(): Promise<BrowserWindow> {
    const browserSession = session.fromPartition('persist:drift-session');
    console.log(path.join(app.getAppPath(), 'buildResources', 'icon.icns'));
    const browserWindow = new BrowserWindow({
      title: 'Drift',
      icon: path.join(app.getAppPath(), 'buildResources', 'icon.icns'),
      width: 1400,
      height: 1000,
      show: false, // Use the 'ready-to-show' event to show the instantiated BrowserWindow.
      webPreferences: {
        disableBlinkFeatures: 'ShadowDOMV0', // Disable Shadow DOM v0 for compatibility
        backgroundThrottling: true,
        nodeIntegration: false,
        contextIsolation: true,
        sandbox: false, // Sandbox disabled because the demo of preload script depend on the Node.js api
        webviewTag: true, // The webview tag is not recommended. Consider alternatives like an iframe or Electron's BrowserView. @see https://www.electronjs.org/docs/latest/api/webview-tag#warning
        preload: this.#preload.path,
        webSecurity: false, // Disable web security for local development
        session: browserSession
      },
      frame: false, // Disable frame to create a custom title bar
      titleBarStyle: 'hiddenInset', // Hide the default title bar
      // vibrancy: 'fullscreen-ui',    // on MacOS
      backgroundMaterial: 'acrylic', // Path to your app icon
      backgroundColor: '#00000000', // Transparent background
    });

    if (this.#renderer instanceof URL) {
      await browserWindow.webContents.session.clearCache();
      await browserWindow.loadURL(this.#renderer.href);
    } else {
      await browserWindow.webContents.session.clearCache();
      await browserWindow.loadFile(this.#renderer.path);
    }

    browserWindow.on('enter-full-screen', () => {
      browserWindow.webContents.send('fullscreen-changed', true);
    });

    browserWindow.on('leave-full-screen', () => {
      browserWindow.webContents.send('fullscreen-changed', false);
    });

    return browserWindow;
  }

  async restoreOrCreateWindow(show = false) {
    let window = BrowserWindow.getAllWindows().find(w => !w.isDestroyed());

    if (window === undefined) {
      window = await this.createWindow();
    }

    if (!show) {
      return window;
    }

    if (window.isMinimized()) {
      window.restore();
    }

    window?.show();

    if (this.#openDevTools) {
      window?.webContents.openDevTools();
    }

    window.focus();

    return window;
  }

}

export function createWindowManagerModule(...args: ConstructorParameters<typeof WindowManager>) {
  return new WindowManager(...args);
}
