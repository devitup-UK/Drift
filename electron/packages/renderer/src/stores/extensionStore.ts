import { defineStore } from 'pinia';
import type ChromeExtension from '../../../shared/models/ChromeExtension';

export const useExtensionStore = defineStore('extensions', {
  state: () => ({
    extensions: [] as Array<ChromeExtension>,
  }),
  getters: {
    getExtensions: (state) => state.extensions,
    getExtensionById: (state) => (id: string) => state.extensions.find(ext => ext.id === id),
  },
  actions: {
    addExtension(extension: ChromeExtension) {
      this.extensions.push(extension);
    },
    removeExtension(extensionId: string) {
      this.extensions = this.extensions.filter(ext => ext.id !== extensionId);
    },
    clearExtensions() {
      this.extensions = [];
    },
  },
});
