// modules/TabManager.ts
import { BrowserView, BrowserWindow, ipcMain } from 'electron';
import type { AppModule } from '../AppModule.js';

interface Tab {
  id: string;
  view: BrowserView;
  url: string;
}

const tabs = new Map<string, Tab>();

let activeTabId: string | null = null;

function getMainWindow(): BrowserWindow {
  const win = BrowserWindow.getAllWindows()[0];
  if (!win) throw new Error('Main window not found');
  return win;
}

function createBrowserView(url: string): Tab {
  const id = crypto.randomUUID();

  const view = new BrowserView({
    webPreferences: {
      contextIsolation: true,
      preload: '', // if needed
    },
  });

  view.webContents.loadURL(url);

  tabs.set(id, { id, view, url });

  return { id, view, url };
}

export function createTabManagerModule(): AppModule {
  return {
    enable() {
      ipcMain.handle('tabs:create', (_event, url: string) => {
        const { id, view } = createBrowserView(url);

        const win = getMainWindow();
        win.setBrowserView(view);

        // Set bounds — you can improve this later
        view.setBounds({ x: 0, y: 100, width: 1200, height: 800 });

        activeTabId = id;

        return { id, url };
      });

      ipcMain.handle('tabs:switch', (_event, id: string) => {
        const tab = tabs.get(id);
        if (!tab) return;

        const win = getMainWindow();
        win.setBrowserView(tab.view);
        tab.view.setBounds({ x: 0, y: 100, width: 1200, height: 800 });

        activeTabId = id;
      });

      ipcMain.handle('tabs:getAll', () => {
        return Array.from(tabs.values()).map(({ id, url }) => ({ id, url }));
      });
    },
  };
}
