export {};

declare global {
  interface Window {
    drift?: {
      webviewPreloadPath: string;
      userDataPath: string; // Path to the user data file
      // add more stuff if you're exposing other config
    },
    electronAPI?: {
      [key: string]: any; // This allows dynamic access to any exposed API
    }
  }
}
