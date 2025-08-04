//
//  TabHistoryModel.swift
//  Drift
//
//  Created by Tom Alderson on 27/07/2025.
//

import Foundation
import AppKit

struct TabWebPageModel: Identifiable {
    var id: UUID
    var timestamp: Date
    var url: URL
    var title: String?
    var favicon: NSImage?
    
    init(timestamp: Date, url: URL, title: String? = nil, favicon: NSImage? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        if(favicon != nil) {
            self.favicon = favicon
        }else{
            self.favicon = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
        }
        self.title = title ?? url.absoluteString
        self.url = url
    }
    
    func toCodable() -> CodableTabWebPageModel {
        return CodableTabWebPageModel(
            id: id,
            timestamp: timestamp,
            url: url,
            title: title,
            faviconData: favicon?.tiffRepresentation
        )
    }

    static func fromCodable(_ codable: CodableTabWebPageModel) -> TabWebPageModel {
        let favicon = codable.faviconData.flatMap { NSImage(data: $0) }
        var tabWebPage = TabWebPageModel(timestamp: codable.timestamp, url: codable.url, title: codable.title ?? "New Tab", favicon: favicon)
        tabWebPage.id = codable.id
        return tabWebPage
    }
}

