import {TabType} from './enums/TabType';
import type {ITabHistoryEntry} from './interfaces/ITabHistoryEntry';

export default class Tab {
  id: string;
  customTitle: string;
  type: TabType;
  folderId?: string;
  history: ITabHistoryEntry[] = [];
  historyIndex: number = -1;
  archived: boolean = false;
  unloaded: boolean = false;

  constructor(id: string, title: string, url: string, customTitle = '', favicon = '', type = TabType.Standard, folderId?: string, archived = false, unloaded = false) {
    this.id = id;
    this.customTitle = customTitle;
    this.type = type;
    this.folderId = folderId;
    this.archived = archived;
    this.unloaded = unloaded;
    this.addHistoryEntry(url, title, favicon);
  }

  setTitle(newTitle: string): void {
    const activePage = this.getActiveHistoryEntry();
    if (activePage) {
      activePage.title = newTitle;
    }
  }

  setCustomTitle(newCustomTitle: string): void {
    this.customTitle = newCustomTitle;
  }

  hasCustomTitle(): boolean {
    return this.customTitle.trim() !== '';
  }

  setFavicon(faviconUrl: string): void {
    const activePage = this.getActiveHistoryEntry();
    if (activePage) {
      activePage.favicon = faviconUrl;
    }
  }

  setFolderId(folderId: string): void {
    this.folderId = folderId;
  }

  setType(type: TabType): void {
    this.type = type;
  }

  goBack(): void {
    if (this.canGoBack()) {
      console.log(`Tab ${this.id} can go back`);
      this.historyIndex--;
    }
  }

  goForward(): void {
    if (this.canGoForward()) {
      this.historyIndex++;
    }
  }

  canGoBack(): boolean {
    return this.historyIndex > 0
  }

  canGoForward(): boolean {
    return this.historyIndex < this.history.length - 1
  }

  addHistoryEntry(url: string, title: string = '', favicon: string = ''): void {
    if (this.history[this.historyIndex]?.url === url) return;

    const timestamp = Date.now();
    const entry: ITabHistoryEntry = { url, timestamp, favicon, title };

    // If we're not at the end of history, truncate the future entries
    if (this.historyIndex < this.history.length - 1) {
      this.history = this.history.slice(0, this.historyIndex + 1);
    }

    // Add the new entry and update the index
    this.history.push(entry);
    this.historyIndex++;
  }

  removeHistoryEntry(index: number): void {
    if (index < 0 || index >= this.history.length) {
      throw new Error('Invalid history index');
    }

    this.history.splice(index, 1);

    // Adjust the history index if necessary
    if (this.historyIndex >= this.history.length) {
      this.historyIndex = this.history.length - 1;
    }
  }

  getActiveHistoryEntry(): ITabHistoryEntry {
    return this.history[this.historyIndex];
  }

  archive() {
    this.archived = true;
  }

  unload() {
    this.unloaded = true;
  }

}
