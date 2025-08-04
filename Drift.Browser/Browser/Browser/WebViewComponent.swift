//
//  WebViewWrapper.swift
//  Browser
//
//  Created by Tom Alderson on 04/06/2025.
//

import SwiftUI
import WebKit

struct WebViewComponent: NSViewRepresentable {
    @Environment(WebViewManager.self) private var webViewManager
    let tab: TabModel
    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
//        webViewManager.register(webView: webView, for: tab)
        
        // 🔥 Round those corners
        webView.wantsLayer = true
        webView.layer?.cornerRadius = 10
        webView.layer?.masksToBounds = true

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}
