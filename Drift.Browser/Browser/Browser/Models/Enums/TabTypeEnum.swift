//
//  TabTypeEnum.swift
//  Drift
//
//  Created by Tom Alderson on 06/06/2025.
//

import Foundation


enum TabTypeEnum: Codable, Equatable, Hashable {
    case standard
    case pinned
    case folder
    case archived

    enum CodingKeys: String, CodingKey {
        case type
        case folderId
    }

    enum TabTypeEnumIdentifier: String, Codable {
        case standard, pinned, folder, archived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeIdentifier = try container.decode(TabTypeEnumIdentifier.self, forKey: .type)

        switch typeIdentifier {
        case .standard:
            self = .standard
        case .pinned:
            self = .pinned
        case .folder:
            self = .folder
        case .archived:
            self = .archived
        }
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .standard:
            try container.encode(TabTypeEnumIdentifier.standard, forKey: .type)
        case .pinned:
            try container.encode(TabTypeEnumIdentifier.pinned, forKey: .type)
        case .folder:
            try container.encode(TabTypeEnumIdentifier.folder, forKey: .type)
        case .archived:
            try container.encode(TabTypeEnumIdentifier.archived, forKey: .type)
        }
    }
}
