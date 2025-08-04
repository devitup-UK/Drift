//
//  TabDropTargetID.swift
//  Drift
//
//  Created by Tom Alderson on 25/06/2025.
//

import Foundation


struct TabDropTargetID: Equatable {
    enum TabDropZone: Equatable {
        case pinned
        case standard
        case folder(UUID) // Folder ID
    }

    let zone: TabDropZone
    let index: Int
}
