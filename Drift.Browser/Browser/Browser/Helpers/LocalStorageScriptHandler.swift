//
//  PIPScriptHandler.swift
//  Drift
//
//  Created by Tom Alderson on 27/06/2025.
//

import WebKit


final class LocalStorageScriptHandler: NSObject, WKScriptMessageHandler {
    weak var tabManager: TabManager?          // or whatever owns your PiP window

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    /// Called whenever JS posts:  window.webkit.messageHandlers.pip.postMessage(...)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "localStorageDidChange",
              let body = message.body as? [String: Any] else { return }
        
        if let fullSync = body["fullSync"] as? Bool, fullSync,
           let data = body["data"] as? [String: String] {
            // Merge incoming full storage - overwrite local copy
            tabManager?.localStorageStore = data
            tabManager?.broadcastLocalStorageUpdate()
            return
        }
        
        if let clear = body["clear"] as? Bool, clear {
            tabManager?.localStorageStore.removeAll()
            tabManager?.broadcastLocalStorageUpdate()
            return
        }
        
        if let key = body["key"] as? String {
            if let value = body["value"] as? String {
                // Set or update key
                tabManager?.localStorageStore[key] = value
            } else {
                // Value is null = remove key
                tabManager?.localStorageStore.removeValue(forKey: key)
            }
            tabManager?.broadcastLocalStorageUpdate()
        }
    }
}
