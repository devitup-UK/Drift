//
//  WebViewDelegate.swift
//  Drift
//
//  Created by Tom Alderson on 07/07/2025.
//

import Foundation
import WebKit

final class WebViewDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
    private weak var tabManager: TabManager?
    private var webViewManager: WebViewManager
    // Keep a map so you can look up which TabModel belongs to each web-view.
    private var canGoBackObservation: NSKeyValueObservation?
    private var canGoForwardObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    private var urlObservation: NSKeyValueObservation?
    
    init(tabManager: TabManager, webViewManager: WebViewManager) {
        self.tabManager = tabManager
        self.webViewManager = webViewManager
        super.init()
    }
    
    deinit {
        canGoBackObservation?.invalidate()
        canGoForwardObservation?.invalidate()
        titleObservation?.invalidate()
        urlObservation?.invalidate()
    }
    
    func attachObservers(to webView: WKWebView) {
        observeNavigationState(webView)
        observeTitle(webView)
        observeUrl(webView)
    }
    
    private func observeNavigationState(_ webView: WKWebView) {
//        canGoBackObservation = webView.observe(\.canGoBack, options: [.new]) { _, change in
//            DispatchQueue.main.async {
//                self.tabManager?.setCanGoBack(change.newValue ?? false)
//                self.tabManager?.saveTabs()
//            }
//        }
//
//        canGoForwardObservation = webView.observe(\.canGoForward, options: [.new]) { _, change in
//            DispatchQueue.main.async {
//                self.tabManager?.setCanGoForward(change.newValue ?? false)
//                self.tabManager?.saveTabs()
//            }
//        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            
        guard navigationAction.targetFrame == nil || !(navigationAction.targetFrame?.isMainFrame ?? false) else {
            return nil
        }
        
        if let url = navigationAction.request.url {
            tabManager?.createNewTab(url: url, configuration: configuration)
        }

        
        if let focusedTabId = self.tabManager?.focusedTabId, let newWebView = self.webViewManager.webView(for: focusedTabId) {
            return newWebView
        }
        
        return nil
    }
    
    func observeTitle(_ webView: WKWebView) {
        titleObservation = webView.observe(\.title, options: [.new]) { _, change in
            if let title = change.newValue as? String {
                DispatchQueue.main.async {
                    self.webViewManager.tab(for: webView)?.setTitle(title: title)
                    self.tabManager?.saveTabs()
                }
            }
        }
    }
    
    func observeUrl(_ webView: WKWebView) {
        urlObservation = webView.observe(\.url, options: [.new]) { _, change in
            if let url = change.newValue as? URL {
                DispatchQueue.main.async {
                    if let targetTab = self.webViewManager.tab(for: webView) {
                        self.tabManager?.addToHistory(targetTab.id, url: url)
                        self.tabManager?.saveTabs()
                    }
                }
            }
        }
    }
    
    func isKnownRedirectURL(_ url: URL) -> Bool {
        // Google redirect links start with /url and contain a "q=" query param
        return url.host?.contains("google") == true && url.path == "/url" && url.query?.contains("q=") == true
    }
    
    func preprocessNavigation(url: URL) -> URL {
        // Extract real destination from the "q" query param
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        if let queryItems = components?.queryItems,
           let realURLString = queryItems.first(where: { $0.name == "q" })?.value,
           let realURL = URL(string: realURLString) {
            return realURL
        }

        return url // fallback in case something goes wrong
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url

        if let url = url, isKnownRedirectURL(url) {
            let cleanURL = preprocessNavigation(url: url)
            decisionHandler(.cancel)
            webView.load(URLRequest(url: cleanURL))
            return
        }

        decisionHandler(.allow)
    }

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ WebView navigation failed: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("❌ Provisional navigation failed: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let newURL = webView.url else { return }

        // Don't record redirect URLs in history
        if isKnownRedirectURL(newURL) { return }

        DispatchQueue.main.async {
            if let targetTab = self.webViewManager.tab(for: webView) {
                self.tabManager?.addToHistory(targetTab.id, url: newURL)
                self.tabManager?.saveTabs()
            }
        }

        webView.evaluateJavaScript("document.title") { result, error in
            if let title = result as? String {
                DispatchQueue.main.async {
                    if let targetTab = self.webViewManager.tab(for: webView) {
                        self.tabManager?.setTabTitle(tabId: targetTab.id, title: title)
                        self.tabManager?.saveTabs()
                    }
                }
            }
        }

        tryFetchFavicon(from: webView)
    }
    
    
    func webView(_ webView: WKWebView,
                 enterFullScreenForFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        print("🌕 Entering fullscreen")
        completionHandler()
    }

    func webView(_ webView: WKWebView,
                 exitFullScreenForFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        print("🌑 Exiting fullscreen")
        completionHandler()
    }
    
    func tryFetchFavicon(from webView: WKWebView, retries: Int = 5) {
        guard retries > 0 else { return }

        webView.evaluateJavaScript("""
            Array.from(document.querySelectorAll('link[rel~="icon"]'))
                 .map(link => link.href)[0]
        """) { result, _ in
            if let faviconURLString = result as? String,
               let faviconURL = URL(string: faviconURLString) {
                self.loadFavicon(webView: webView, url: faviconURL)
            } else if let host = webView.url?.host {
                // 🛟 Fallback to root favicon.ico
                let fallbackURL = URL(string: "https://\(host)/favicon.ico")!
                self.loadFavicon(webView: webView, url: fallbackURL)
            } else {
                // Retry after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tryFetchFavicon(from: webView, retries: retries - 1)
                    self.tabManager?.saveTabs()
                }
            }
        }
    }
    
    func loadFavicon(webView: WKWebView, url: URL) {
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let image = NSImage(data: data) {
                    DispatchQueue.main.async {
//                        self.favicon = image
                        if let targetTab = self.webViewManager.tab(for: webView) {
                            self.tabManager?.setTabFavicon(tabId: targetTab.id, favicon: image)
                            self.tabManager?.saveTabs()
                        }
                    }
                }
            } catch {
                print("🧯 Failed to load favicon from \(url): \(error)")
            }
        }
    }
}
