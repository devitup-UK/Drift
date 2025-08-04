//
//  WebViewManager.swift
//  Drift
//
//  Created by Tom Alderson on 20/07/2025.
//

import Foundation
import WebKit

@Observable
class WebViewManager {
    var webViewMap: [UUID: WKWebView] = [:]
    private var tabMap: [WKWebView: TabModel] = [:]
    private let tabManager: TabManager
    private(set) var delegate: WebViewDelegate!

    init(tabManager: TabManager) {
        self.tabManager = tabManager
        self.delegate = nil
        self.delegate = WebViewDelegate(tabManager: tabManager, webViewManager: self)
    }
    
    func createWebView(for tab: TabModel) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = true
        config.suppressesIncrementalRendering = false
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.setValue(true, forKey: "fullScreenEnabled")
        config.applicationNameForUserAgent = "Version/17.4 Safari/605.1.15"
        config.websiteDataStore = WebKitEnvironment.shared.websiteDataStore
        config.processPool = WebKitEnvironment.shared.processPool
        
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
        
        let localStorageUserScript = WKUserScript(source: localStorageSyncJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)

        let uc = WKUserContentController()
        uc.add(LocalStorageScriptHandler(tabManager: tabManager), name: "localStorageDidChange")

        config.userContentController = uc
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = config.applicationNameForUserAgent
        
        register(webView: webView, for: tab)
        return webView;
    }
    
    func createWebViewWithConfiguration(for tab: TabModel, configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        register(webView: webView, for: tab)
        return webView;
    }

    func register(webView: WKWebView, for tab: TabModel) {
        delegate.attachObservers(to: webView)
        webView.navigationDelegate = delegate
        webView.uiDelegate = delegate
        webViewMap[tab.id] = webView
        tabMap[webView] = tab
    }

    func webView(for tabId: UUID) -> WKWebView? {
        webViewMap[tabId]
    }

    func tab(for webView: WKWebView) -> TabModel? {
        tabMap[webView]
    }

    func removeTab(tabId: UUID) {
        if let webView = webViewMap[tabId] {
            tabMap.removeValue(forKey: webView)
        }
        webViewMap.removeValue(forKey: tabId)
    }
    
    func destroyWebView(_ webView: WKWebView) {
        // 1. Stop playback / loading
        webView.stopLoading()
        webView.evaluateJavaScript("document.querySelectorAll('video,audio').forEach(v => v.pause())")

        // 2. Break delegate cycles
        webView.navigationDelegate = nil
        webView.uiDelegate         = nil

        // 3. Remove from view hierarchy
        webView.removeFromSuperview()
    }
}
