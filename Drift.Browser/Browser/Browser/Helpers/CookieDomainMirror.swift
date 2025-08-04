//
//  CookieDomainMirror.swift
//  Drift
//
//  Created by Tom Alderson on 07/07/2025.
//


//  CookieDomainMirror.swift
//  Drift
//
//  Mirrors ".example.com" cookies onto "example.com"
//  so first-hop apex requests get the goods.

import Foundation
import WebKit

final class CookieDomainMirror: NSObject, WKHTTPCookieStoreObserver {

    static let shared = CookieDomainMirror()

    /// Call once for every WKWebView you spin up
    func attach(to webView: WKWebView) {
        let store = webView.configuration.websiteDataStore.httpCookieStore
        store.add(self)                 // listen for new cookies
        mirrorExistingCookies(in: store)
    }

    // MARK: - WKHTTPCookieStoreObserver
    func cookiesDidChange(in store: WKHTTPCookieStore) {
        store.getAllCookies { [weak self] in
            $0.forEach { self?.mirrorIfNeeded($0, via: store) }
        }
    }

    // MARK: - Private
    private func mirrorExistingCookies(in store: WKHTTPCookieStore) {
        store.getAllCookies { [weak self] in
            $0.forEach { self?.mirrorIfNeeded($0, via: store) }
        }
    }

    func mirrorIfNeeded(_ cookie: HTTPCookie, via store: WKHTTPCookieStore) {
        // Step 1: is it a ".domain.com" style cookie?
        guard cookie.domain.hasPrefix(".") else { return }

        let apex = String(cookie.domain.dropFirst())      // "example.com"
        // If we already have the apex twin, bail.
        if HTTPCookieStorage.shared.cookies?.contains(where: {
            $0.name   == cookie.name &&
            $0.domain == apex &&
            $0.path   == cookie.path
        }) == true { return }

        // Step 2: build the twin
        var props          = cookie.properties!
        props[.domain]     = apex            // remove leading dot
        props[.discard]    = nil             // keep it persistent
        guard let twin = HTTPCookie(properties: props) else { return }

        // Step 3: write twin → native jar
        HTTPCookieStorage.shared.setCookie(twin)

        // Step 4: write twin → every WKHTTPCookieStore we know about
        store.setCookie(twin)
        // If you track multiple webViews, loop over their stores here.
    }
}
