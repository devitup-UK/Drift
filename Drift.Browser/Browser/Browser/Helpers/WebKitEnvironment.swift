//
//  WebKitEnvironment.swift
//  Drift
//
//  Created by Tom Alderson on 27/06/2025.
//

import WebKit


final class WebKitEnvironment {
    static let shared = WebKitEnvironment()

    /// One pool ➜ one WebContent process ➜ shared cookies/localStorage.
    let processPool: WKProcessPool = WKProcessPool()

    /// Use the system default store so Safari-style persistence “just works”.
    let websiteDataStore: WKWebsiteDataStore = .default()

    private init() { }
}
