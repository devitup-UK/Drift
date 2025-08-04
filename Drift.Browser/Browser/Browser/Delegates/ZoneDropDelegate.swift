//
//  ZoneDropDelegate.swift
//  Drift
//
//  Created by Tom Alderson on 05/06/2025.
//

import SwiftUI


struct SpaceDropDelegate: DropDelegate {
    let tabManager: TabManager
    @Binding var isHovering: Bool

    func performDrop(info: DropInfo) -> Bool {
        isHovering = false

        guard let item = info.itemProviders(for: [.text]).first else { return false }

        item.loadDataRepresentation(forTypeIdentifier: "public.text") { data, _ in
            if let data = data,
               let idString = String(data: data, encoding: .utf8),
               let draggedId = UUID(uuidString: idString) {

                DispatchQueue.main.async {
                    if(tabManager.pinnedAndFolderTabs.isEmpty) {
                        let draggedTab = tabManager.getTabById(draggedId)!
                        draggedTab.tabType = .pinned
                        draggedTab.pinnedIndex = 0
                        tabManager.saveTabs()
                    }
                }
            }
        }

        return true
    }

    func dropEntered(info: DropInfo) {
        isHovering = true
    }

    func dropExited(info: DropInfo) {
        isHovering = false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
