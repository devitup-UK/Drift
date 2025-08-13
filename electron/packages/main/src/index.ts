import type {AppInitConfig} from './AppInitConfig.js';
import {createModuleRunner} from './ModuleRunner.js';
import {disallowMultipleAppInstance} from './modules/SingleInstanceApp.js';
import {createWindowManagerModule} from './modules/WindowManager.js';
import {terminateAppOnLastWindowClose} from './modules/ApplicationTerminatorOnLastWindowClose.js';
import {hardwareAccelerationMode} from './modules/HardwareAccelerationModule.js';
import {autoUpdater} from './modules/AutoUpdater.js';
import {allowInternalOrigins} from './modules/BlockNotAllowdOrigins.js';
import {allowExternalUrls} from './modules/ExternalUrls.js';
import { setupContextMenu } from './modules/ContextMenu.js';
import {createTabManagerModule} from './modules/TabManagerModule.js';
import { initialiseExtensionsManager } from './modules/ExtensionManager.js';
import { setupAdblocking } from './modules/AdblockModule.js';
import path from 'path';
import { setupDatabase } from './modules/Database.js';


export async function initApp(initConfig: AppInitConfig) {
  const moduleRunner = createModuleRunner()
    .init(setupContextMenu())
    .init(createWindowManagerModule({initConfig, openDevTools: false}))
    .init(setupDatabase())
    // .init(disallowMultipleAppInstance())
    .init(terminateAppOnLastWindowClose())
    .init(hardwareAccelerationMode({enable: true}))
    .init(initialiseExtensionsManager())
    .init(autoUpdater());

    // Security
    // .init(allowInternalOrigins(
    //   new Set(['*']),
    // ))
    // .init(allowExternalUrls(
    //   new Set(['*'])),
    // );

  await moduleRunner;
}
