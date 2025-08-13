import {AppModule} from '../AppModule.js';
import { addHistory, addTab, updateTab, initDatabase, getTabs } from '../services/databaseService.js';
import { ipcMain, webContents, BrowserWindow } from 'electron';
import Tab from '../../../shared/models/Tab.js';
import { IHistoryEntry } from '../../../shared/models/interfaces/IHistoryEntry.js';

class Database implements AppModule {
  enable({app}: {app: Electron.App}): void {
    // Instantiate the database
    initDatabase(app);

    ipcMain.handle('db:get-tabs', async () => {
      const tabs = await getTabs();
      return tabs;
    });

    // Setup the listeners for database operations
    ipcMain.handle('db:add-tab', (event, tab: Tab) => {
      console.log('Adding tab to database:', tab);
      addTab(tab);
    });

    ipcMain.handle('db:update-tab', (event, tab: Tab) => {
      console.log('Updating tab in database:', tab);
      updateTab(tab);
    });

    ipcMain.on('db:addHistory', (event, historyEntry: IHistoryEntry) => {
      addHistory(historyEntry);
    });
  }
}


export function setupDatabase(...args: ConstructorParameters<typeof Database>) {
  return new Database(...args);
}
