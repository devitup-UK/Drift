//
//  CodableTabWebPageModel.swift
//  Drift
//
//  Created by Tom Alderson on 27/07/2025.
//

import Foundation

struct CodableTabWebPageModel: Codable {
    var id: UUID
    var timestamp: Date
    var url: URL
    var title: String?
    var faviconData: Data?
}
