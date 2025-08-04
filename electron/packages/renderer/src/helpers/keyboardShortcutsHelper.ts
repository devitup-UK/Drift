import { onMounted, onUnmounted } from 'vue';
import { useGlobalStore } from '../stores/globalStore';
import { getPlatform } from '@app/preload';
import { useTabStore } from '../stores/tabStore';

export function useKeyboardShortcuts() {
  const handleKeydown = (e: KeyboardEvent) => {
    const isMac = getPlatform() === 'darwin';
    const isCmdL = (isMac && e.metaKey && e.key === 'l') || (!isMac && e.ctrlKey && e.key === 'l');
    const isCmdT = (isMac && e.metaKey && e.key === 't') || (!isMac && e.ctrlKey && e.key === 't');
    const isCmdS = (isMac && e.metaKey && e.key === 's') || (!isMac && e.ctrlKey && e.key === 's');
    const isShiftCmdD = (isMac && e.metaKey && e.shiftKey && e.key === 'd') || (!isMac && e.ctrlKey && e.shiftKey && e.key === 'd');
    const isEscape = e.key === 'Escape';

    if(isShiftCmdD) {
      e.preventDefault();
      const globalStore = useGlobalStore();
      globalStore.toggleToolbar();
    }

    if (isCmdS) {
      e.preventDefault();
      const globalStore = useGlobalStore();
      globalStore.toggleSidebar();
    }

    if (isCmdT) {
      e.preventDefault();
      const globalStore = useGlobalStore();
      globalStore.openControlBarInNewTabMode();
    }

    if (isCmdL) {
      e.preventDefault();
      const tabStore = useTabStore();
      if (tabStore.activeTabId) {
        const globalStore = useGlobalStore();
        globalStore.openControlBarInEditMode();
      }
    }

    if (isEscape) {
      e.preventDefault();
      const globalStore = useGlobalStore();
      globalStore.closeControlBar();
    }
  };

  onMounted(() => {
    window.addEventListener('keydown', handleKeydown);
  });

  onUnmounted(() => {
    window.removeEventListener('keydown', handleKeydown);
  });
}
