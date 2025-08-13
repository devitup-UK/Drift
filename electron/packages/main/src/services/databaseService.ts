// modules/database.ts

import path from 'path';
import fs from 'fs';
import { Low } from 'lowdb';
import { JSONFile } from 'lowdb/node';
import { DriftDatabase } from '../../../shared/models/database/DriftDatabase.js';
import { IHistoryEntry } from '../../../shared/models/interfaces/IHistoryEntry.js';
import Tab from '../../../shared/models/Tab.js';

let db: Low<DriftDatabase>;

export async function initDatabase(app: Electron.App) {
  const dbPath = path.resolve(app.getPath('userData'), 'drift-db.json');
  const folderPath = path.dirname(dbPath);

  if (!fs.existsSync(folderPath)) {
    fs.mkdirSync(folderPath, { recursive: true });
  }

  const adapter = new JSONFile<DriftDatabase>(dbPath);
  db = new Low(adapter, { tabs: [], history: [] });
  await db.read();
  db.data ||= { tabs: [], history: [] };
  await db.write();
}

export function getTabs(): Tab[] {
  return db.data?.tabs ?? [];
}

export async function addTab(tab: Tab) {
  db.data?.tabs.push(tab);
  await db.write();
}

export async function updateTab(tab: Tab) {
  const index = db.data?.tabs.findIndex(t => t.id === tab.id);
  if (index !== undefined && index !== -1) {
    db.data!.tabs[index] = tab;
    await db.write();
  }
}

export async function updateTabs(tabs: Tab[]) {
  db.data!.tabs = tabs;
  await db.write();
}

export async function addHistory(entry: IHistoryEntry) {
  db.data?.history.push(entry);
  await db.write();
}

// and so on...
