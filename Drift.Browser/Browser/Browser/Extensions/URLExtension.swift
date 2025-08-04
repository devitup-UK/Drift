//
//  URLExtension.swift
//  Drift
//
//  Created by Tom Alderson on 07/07/2025.
//

import Foundation

extension URL {
    var canonicalYouTube: URL {
        guard host?.lowercased() == "youtube.com" else { return self }
        var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        comps.host = "www.youtube.com"
        return comps.url!
    }
}
