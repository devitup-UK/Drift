//
//  CodableTabModel.swift
//  Drift
//
//  Created by Tom Alderson on 27/07/2025.
//

import Foundation


struct CodableTabModel: Codable {
    var id: UUID = UUID()
    var unloaded: Bool
    var titleOverride: String
    var tabType: TabTypeEnum
    var folderId: UUID?
    var folderOpen: Bool
    var folderIndex: Int?
    var isRenaming: Bool = false
    var pinnedIndex: Int?
    var standardIndex: Int?
    var history: [CodableTabWebPageModel] = []
    var historyIndex: Int
}
