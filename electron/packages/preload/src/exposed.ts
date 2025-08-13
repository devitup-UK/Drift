import path from 'path';
import * as exports from './index.js';
import {contextBridge} from 'electron';
import { pathToFileURL, fileURLToPath } from 'url';
import fs from 'fs'

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const preloadAbsolutePath = path.resolve(__dirname, '../../renderer/public/preload.js');
const preloadUrl = pathToFileURL(preloadAbsolutePath).href;
const dbPath = path.resolve(process.env.HOME || process.env.USERPROFILE || '.', '.drift', 'drift-db.json');


const folderPath = path.dirname(dbPath)
if (!fs.existsSync(folderPath)) {
  fs.mkdirSync(folderPath, { recursive: true })
}

contextBridge.exposeInMainWorld('drift', {
  webviewPreloadPath: preloadUrl,
  userDataPath: dbPath
});

const isExport = (key: string): key is keyof typeof exports => Object.hasOwn(exports, key);

for (const exportsKey in exports) {
  if (isExport(exportsKey)) {
    contextBridge.exposeInMainWorld(btoa(exportsKey), exports[exportsKey]);
  }
}

// Re-export for tests
export * from './index.js';
