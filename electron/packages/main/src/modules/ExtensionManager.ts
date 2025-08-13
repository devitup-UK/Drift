import { app, session, BrowserWindow } from 'electron';
import {AppModule} from '../AppModule.js';
import {ModuleContext} from '../ModuleContext.js';
import installer from 'electron-devtools-installer';
import { installChromeWebStore, installExtension, updateExtensions } from 'electron-chrome-web-store';
import path from 'path';
import chokidar from 'chokidar';
import { ElectronChromeExtensions } from 'electron-chrome-extensions';
import { watch } from 'fs';
import { Browser } from 'happy-dom';
import ChromeExtension from '../../../shared/models/ChromeExtension.js';
import { getExtensionInfo } from '../services/extensionService.js';

const {
  REDUX_DEVTOOLS,
  VUEJS_DEVTOOLS,
  EMBER_INSPECTOR,
  BACKBONE_DEBUGGER,
  REACT_DEVELOPER_TOOLS,
  JQUERY_DEBUGGER,
  MOBX_DEVTOOLS,
  default: installDevToolsExtension,
} = installer;

// const extensionsDictionary = {
//   REDUX_DEVTOOLS,
//   VUEJS_DEVTOOLS,
//   EMBER_INSPECTOR,
//   BACKBONE_DEBUGGER,
//   REACT_DEVELOPER_TOOLS,
//   JQUERY_DEBUGGER,
//   MOBX_DEVTOOLS,
// } as const;

export class ExtensionManager implements AppModule {
  // readonly #extension: keyof typeof extensionsDictionary;

  // constructor({extension}: {readonly extension: keyof typeof extensionsDictionary}) {
  //   this.#extension = extension;
  // }

  extensionsDir = path.join(app.getPath('userData'), 'Extensions');

  async enable({app}: ModuleContext): Promise<void> {
    await app.whenReady();
    await installChromeWebStore({ session: session.fromPartition('persist:drift-session') })

    // Vue DevTools
    await installDevToolsExtension('nhdogjmejiglipccpnnnanhbledajbpd', {
      session: session.fromPartition('persist:drift-session'),
      loadExtensionOptions: {
        allowFileAccess: true,
      }
    });

    console.log('[ExtensionManager] Installed Vue DevTools');

    // Ublock Origin Lite
    await installExtension('ddkjiahejlhfcafbddmgiahcphecmpfh', {
      session: session.fromPartition('persist:drift-session'),
    });

    console.log('[ExtensionManager] Installed Ublock Origin Lite');

    // Setup extensions.
    const extensions = new ElectronChromeExtensions({
      license: 'GPL-3.0',
      session: session.fromPartition('persist:drift-session'),
      requestPermissions: async function(extension, permissions) {
        console.log('[ExtensionManager] Requesting permissions for extension:', extension);
        console.log('[ExtensionManager] Permissions requested:', permissions);

        return true;
      }
    });

    // for (const browserWindow of BrowserWindow.getAllWindows()) {
    //   extensions.addTab(browserWindow.webContents, browserWindow);
    // }

    await updateExtensions();
    this.watchExtensions(app);
  }

  watchExtensions(app: Electron.App): void {
    console.log('[ExtensionManager] Watching for extension changes in:', this.extensionsDir);
    const watcher = chokidar.watch(this.extensionsDir, { depth: 0, ignoreInitial: true });

    watcher.on('addDir', dirPath => {
      console.log('[ExtensionManager] New extension added:', dirPath);
      const extId = path.basename(dirPath);
      BrowserWindow.getAllWindows().forEach(win => {
        setTimeout(() => {
          win.webContents.send('extension-installed', getExtensionInfo(extId, dirPath));
        }, 1000);
      });
    });

    watcher.on('unlinkDir', dirPath => {
      console.log('[ExtensionManager] Extension removed:', dirPath);
      const extId = path.basename(dirPath);
      BrowserWindow.getAllWindows().forEach(win => {
        win.webContents.send('extension-removed', { id: extId });
      });
    });
  }

}

export function initialiseExtensionsManager(...args: ConstructorParameters<typeof ExtensionManager>) {
  return new ExtensionManager(...args);
}
