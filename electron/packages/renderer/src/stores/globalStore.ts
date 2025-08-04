import { defineStore } from 'pinia';

export const useGlobalStore = defineStore('global', {
  state: () => ({
    toolbarVisible: false,
    controlBarOpen: false,
    controlBarMode: 'edit', // edit or new-tab
    sidebarWidth: 250,
    sidebarVisible: true,
    slideSidebarIntoView: false,
    fullscreen: false,
  }),
  actions: {
    setToolbarVisible(visible: boolean) {
      this.toolbarVisible = visible;
    },
    toggleToolbar() {
      this.toolbarVisible = !this.toolbarVisible;
    },
    setControlBarMode(mode: 'edit' | 'new-tab') {
      this.controlBarMode = mode;
    },
    toggleControlBar() {
      this.controlBarOpen = !this.controlBarOpen;
    },
    openControlBarInEditMode() {
      this.setControlBarMode('edit');
      this.controlBarOpen = true;
    },
    openControlBarInNewTabMode() {
      this.setControlBarMode('new-tab');
      this.controlBarOpen = true;
    },
    openControlBar() {
      this.controlBarOpen = true;
    },
    closeControlBar() {
      this.controlBarOpen = false;
    },
    setSidebarWidth(width: number) {
      this.sidebarWidth = width;
    },
    showSidebar() {
      this.sidebarVisible = true;
    },
    hideSidebar() {
      this.sidebarVisible = false;
    },
    toggleSidebar() {
      this.sidebarVisible = !this.sidebarVisible;
    },
    setSlideSidebarIntoView(value: boolean) {
      this.slideSidebarIntoView = value;
    },
    setFullscreen(value: boolean) {
      this.fullscreen = value;
    }
  },
  getters: {
    isSidebarVisible: (state) => state.sidebarVisible,
  },
});
