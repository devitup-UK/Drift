//
//  WebViewHelper.swift
//  Drift
//
//  Created by Tom Alderson on 27/06/2025.
//

import Foundation
import WebKit

    // MARK: - 2.  Build the WKWebView with those handlers
    // =================================

    func makeConfiguredWebView(tab: TabModel, tabManager: TabManager, webViewManager: WebViewManager) -> WKWebView {
        
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = true
        config.suppressesIncrementalRendering = false
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.setValue(true, forKey: "fullScreenEnabled")
        config.applicationNameForUserAgent = "Version/17.4 Safari/605.1.15"
        config.websiteDataStore = WebKitEnvironment.shared.websiteDataStore
        config.processPool = WebKitEnvironment.shared.processPool

        //  Inject the helper JS that posts to "pip" / "nopip"
        let pipJsSource = """
        (function () {
            if (window.__driftPIPInstalled) return;
            window.__driftPIPInstalled = true;

            function requestPiP() {
                const v = document.querySelector('video');
                if (!v) { window.webkit.messageHandlers.nopip.postMessage(null); return; }
                
                // Pass URL, currentTime, paused to native layer
                window.webkit.messageHandlers.pip.postMessage({
                    src:  v.currentSrc || v.src,
                    time: v.currentTime,
                    paused: v.paused
                });
        
        
                v.pause();
            }

            // Listen for message from Swift to start PiP
            window.addEventListener('message', e => {
                if (e.data === 'DRIFT_START_PIP') requestPiP();
                if (e.data === 'DRIFT_STOP_PIP')  v?.pause();
            });
        })();
        """
        
        let pipUserScript = WKUserScript(source: pipJsSource,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let localStorageSyncJS = """
        (function () {
          if (window.__localStorageSyncInstalled) return;
          window.__localStorageSyncInstalled = true;

          // Hook setItem to notify native on changes
          const originalSetItem = localStorage.setItem;
          localStorage.setItem = function (key, value) {
            originalSetItem.apply(this, arguments);
            window.webkit.messageHandlers.localStorageDidChange.postMessage({ key: key, value: value });
          };

          // Hook removeItem
          const originalRemoveItem = localStorage.removeItem;
          localStorage.removeItem = function(key) {
            originalRemoveItem.apply(this, arguments);
            window.webkit.messageHandlers.localStorageDidChange.postMessage({ key: key, value: null });
          };

          // Hook clear
          const originalClear = localStorage.clear;
          localStorage.clear = function() {
            originalClear.apply(this, arguments);
            window.webkit.messageHandlers.localStorageDidChange.postMessage({ clear: true });
          };

          // On page load, send full localStorage to native
          window.webkit.messageHandlers.localStorageDidChange.postMessage({ fullSync: true, data: {...localStorage} });

          // Listen for native sync messages and update localStorage accordingly
          window.addEventListener('message', function(e) {
            if (e.data.type === 'syncLocalStorage') {
              const data = e.data.data;
              if (data.clear) {
                localStorage.clear();
              }
              if (data.set) {
                Object.entries(data.set).forEach(([key, value]) => {
                  localStorage.setItem(key, value);
                });
              }
              if (data.remove) {
                data.remove.forEach(key => {
                  localStorage.removeItem(key);
                });
              }
            }
          });
        })();
        """

        // Then create the WKUserScript and add it to your WKUserContentController
        let localStorageUserScript = WKUserScript(source: localStorageSyncJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)

        let uc = WKUserContentController()
        uc.addUserScript(pipUserScript)
        uc.addUserScript(localStorageUserScript)

        //  Create handlers and register them
        uc.add(PIPScriptHandler(tabManager: tabManager), name: "pip")
        uc.add(NoPIPScriptHandler(),                     name: "nopip")
        uc.add(LocalStorageScriptHandler(tabManager: tabManager), name: "localStorageDidChange")

        config.userContentController = uc

        
//        let store  = config.websiteDataStore.httpCookieStore
//        
//        // 2️⃣ Mirror dot-domain cookies ➜ apex
//        let nativeCookies = HTTPCookieStorage.shared.cookies ?? []
//        nativeCookies.forEach { CookieDomainMirror.shared.mirrorIfNeeded($0, via: store) }
//
//        // 2️⃣ push cookies to WK first
//        let group = DispatchGroup()
//        for c in HTTPCookieStorage.shared.cookies ?? [] {
//            group.enter()
//            store.setCookie(c) { group.leave() }
//        }

//        group.notify(queue: .main) {
            let wv = WKWebView(frame: .zero, configuration: config)
            wv.customUserAgent = config.applicationNameForUserAgent
            wv.navigationDelegate = webViewManager.delegate
            wv.uiDelegate = webViewManager.delegate
            webViewManager.delegate.attachObservers(to: wv)
//
//            CookieDomainMirror.shared.attach(to: wv)
//            CookieSyncManager.shared.register(webView: wv)
        
        return wv
//            completion(wv)                                   // safe to call load() now
        }


