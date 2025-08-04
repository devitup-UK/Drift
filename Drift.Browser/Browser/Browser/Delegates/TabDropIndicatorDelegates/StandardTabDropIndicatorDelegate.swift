//
//  TabDropIndicatorDelegate.swift
//  Drift
//
//  Created by Tom Alderson on 05/06/2025.
//

import SwiftUI

struct StandardTabDropIndicatorDelegate: DropDelegate {
    let tab: TabModel?
    let tabManager: TabManager
    let targetID: TabDropTargetID
    @Binding var dragOverTarget: TabDropTargetID?

    func validateDrop(info: DropInfo) -> Bool { true }

    func dropEntered(info: DropInfo) {
        dragOverTarget = targetID
    }

    func dropExited(info: DropInfo) {
        if dragOverTarget == targetID {
            dragOverTarget = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [.text]).first else { return false }

        item.loadDataRepresentation(forTypeIdentifier: "public.text") { data, _ in
            if let data = data,
               let idString = String(data: data, encoding: .utf8),
               let draggedId = UUID(uuidString: idString),
               let draggedTab = tabManager.getTabById(draggedId) {

                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        tabManager.insertTabToStandardTabsList(tab: draggedTab, standardIndex: targetID.index)
                        tabManager.saveTabs()
                        dragOverTarget = nil
                    }
                }
            }
        }

        return true
    }

    private func adjustedIndex(from oldIndex: Int, to newIndex: Int) -> Int {
        oldIndex < newIndex ? newIndex - 1 : newIndex
    }
}
