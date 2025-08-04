import type {AppModule} from '../AppModule.js';
import {ModuleContext} from '../ModuleContext.js';
import {BaseWindow, BrowserWindow, WebContentsView, ipcMain, session, webContents} from 'electron';
import type {AppInitConfig} from '../AppInitConfig.js';
import { ElectronChromeExtensions } from 'electron-chrome-extensions';

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
    app.on('second-instance', () => this.restoreOrCreateWindow(true));
    app.on('activate', () => this.restoreOrCreateWindow(true));

  }

  async createWindow(): Promise<BrowserWindow> {
    const browserSession = session.fromPartition('persist:drift-session');
    const browserWindow = new BrowserWindow({
      width: 1200,
      height: 800,
      show: false, // Use the 'ready-to-show' event to show the instantiated BrowserWindow.
      webPreferences: {
        disableBlinkFeatures: 'ShadowDOMV0', // Disable Shadow DOM v0 for compatibility
        backgroundThrottling: true,
        nodeIntegration: false,
        contextIsolation: true,
        sandbox: false, // Sandbox disabled because the demo of preload script depend on the Node.js api
        webviewTag: true, // The webview tag is not recommended. Consider alternatives like an iframe or Electron's BrowserView. @see https://www.electronjs.org/docs/latest/api/webview-tag#warning
        preload: this.#preload.path,
        webSecurity: true, // Disable web security for local development
        session: browserSession
      },
      frame: false, // Disable frame to create a custom title bar
      titleBarStyle: 'hiddenInset', // Hide the default title bar
      // vibrancy: 'fullscreen-ui',    // on MacOS
      backgroundMaterial: 'acrylic', // Path to your app icon
      backgroundColor: '#00000000', // Transparent background
    });

    if (this.#renderer instanceof URL) {
      await browserWindow.loadURL(this.#renderer.href);
    } else {
      await browserWindow.loadFile(this.#renderer.path);
    }

    browserWindow.on('enter-full-screen', () => {
      browserWindow.webContents.send('fullscreen-changed', true);
    });

    browserWindow.on('leave-full-screen', () => {
      browserWindow.webContents.send('fullscreen-changed', false);
    });

    const extensions = new ElectronChromeExtensions({
      license: 'GPL-3.0',
      session: browserSession
    });

    ipcMain.on('register-extension-tab', (event, tabId: string) => {
      const webContentsFromId = webContents.fromId(Number(tabId));
      if (webContentsFromId) {
        extensions.addTab(webContentsFromId, BrowserWindow.getFocusedWindow() as BaseWindow);
      }
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
