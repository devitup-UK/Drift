import contextMenu from 'electron-context-menu';
import {AppModule} from '../AppModule.js';

class ContextMenu implements AppModule {
  enable({app}: {app: Electron.App}): void {
    contextMenu({
      showInspectElement: true,
      showSaveImageAs: true,
      showCopyImage: true,
      showCopyLink: true,
      showCopyImageAddress: true,
    });
  }
}


export function setupContextMenu(...args: ConstructorParameters<typeof ContextMenu>) {
  return new ContextMenu(...args);
}
