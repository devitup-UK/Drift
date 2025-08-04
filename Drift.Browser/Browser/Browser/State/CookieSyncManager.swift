//
//  CookieSyncManager.swift
//  Drift
//
//  Created by Tom Alderson on 06/07/2025.
//


//
//  CookieSyncManager.swift
//  Drift
//
//  Created by ChatGPT on 6 Jul 2025.
//

import WebKit

final class CookieSyncManager: NSObject, WKHTTPCookieStoreObserver {
    static let shared = CookieSyncManager()

    func register(webView: WKWebView) {
        let store = webView.configuration.websiteDataStore.httpCookieStore
        store.add(self)

        // kick off an initial sync
        pushNativeCookies(to: store)
        pullWkCookies(from: store)
    }

    func pushNativeCookies(to store: WKHTTPCookieStore) {
        HTTPCookieStorage.shared.cookies?.forEach { store.setCookie($0) }
    }

    func pullWkCookies(from store: WKHTTPCookieStore) {
        store.getAllCookies { $0.forEach { HTTPCookieStorage.shared.setCookie($0) } }
    }

    // WKHTTPCookieStoreObserver
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        pullWkCookies(from: cookieStore)
    }
}
