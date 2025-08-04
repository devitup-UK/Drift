//
//  PIPScriptHandler.swift
//  Drift
//
//  Created by Tom Alderson on 27/06/2025.
//

import WebKit


// MARK: - 1.  Tiny helper objects
// =================================

/// Handles the "pip" message and launches your floating PiP window.
final class PIPScriptHandler: NSObject, WKScriptMessageHandler {
    weak var tabManager: TabManager?          // or whatever owns your PiP window

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    /// Called whenever JS posts:  window.webkit.messageHandlers.pip.postMessage(...)
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {

        guard
            let dict = message.body as? [String: Any],
            let src  = dict["src"] as? String,
            let url  = URL(string: src)
        else { return }

        let startTime = dict["time"]   as? Double ?? 0
        let paused    = dict["paused"] as? Bool   ?? false

        // 🔥  Kick off your floating PiP window:
        let pipWC = PiPWindowController(url: url,
                                        startTime: startTime,
                                        paused: paused)
        pipWC.showWindow(nil)

        // Keep a strong reference somewhere (e.g. on TabManager)
        tabManager?.currentPip = pipWC
    }
}

/// Handles "nopip" (optional) – maybe show a tooltip saying “no video found”.
final class NoPIPScriptHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        print("No video element found – cannot start PiP")
    }
}
