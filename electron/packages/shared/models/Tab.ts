import {TabType} from './enums/TabType.js';

export default class Tab {
  id: string;
  initialUrl: string;
  url: string;
  customTitle: string;
  type: string = TabType.Standard;
  folderId?: string;
  historyIndex: number = -1;
  archived: boolean = false;
  unloaded: boolean = false;
  isMediaPlaying: boolean = false;
  title: string;
  favicon: string;
  hasBeenLoaded: boolean = false;
  wasRestoredFromDatabase: boolean = false;
  lastInteractedAt: number = Date.now();

  constructor(id: string, title: string, initialUrl: string, url: string, customTitle = '', favicon = '', type = TabType.Standard, folderId?: string, archived = false, unloaded = false, isMediaPlaying = false, hasBeenLoaded = false, wasRestoredFromDatabase = false) {
    this.id = id;
    this.initialUrl = initialUrl;
    this.customTitle = customTitle;
    this.type = type;
    this.folderId = folderId;
    this.archived = archived;
    this.unloaded = unloaded;
    this.isMediaPlaying = isMediaPlaying;
    this.title = title;
    this.favicon = favicon;
    this.url = url;
    this.hasBeenLoaded = hasBeenLoaded;
    this.wasRestoredFromDatabase = wasRestoredFromDatabase;
  }

  setLastInteractedAt(timestamp: number): void {
    this.lastInteractedAt = timestamp;
  }

  setHasBeenLoaded(loaded: boolean): void {
    this.hasBeenLoaded = loaded;
  }

  setTitle(newTitle: string): void {
    this.title = newTitle;
  }

  setUrl(newUrl: string): void {
    this.url = newUrl;
  }

  setFavicon(newFavicon: string): void {
    this.favicon = newFavicon;
  }

  setCustomTitle(newCustomTitle: string): void {
    this.customTitle = newCustomTitle;
  }

  hasCustomTitle(): boolean {
    return this.customTitle.trim() !== '';
  }

  setIsMediaPlaying(isPlaying: boolean): void {
    this.isMediaPlaying = isPlaying;
  }

  setFolderId(folderId: string): void {
    this.folderId = folderId;
  }

  setType(type: string): void {
    this.type = type;
  }

  archive() {
    this.archived = true;
  }

  unload() {
    this.unloaded = true;
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      initialUrl: this.initialUrl,
      url: this.url,
      customTitle: this.customTitle,
      favicon: this.favicon,
      type: this.type,
      folderId: this.folderId,
      archived: this.archived,
      unloaded: this.unloaded,
      isMediaPlaying: this.isMediaPlaying,
      hasBeenLoaded: this.hasBeenLoaded,
      wasRestoredFromDatabase: this.wasRestoredFromDatabase
    }
  }

}
