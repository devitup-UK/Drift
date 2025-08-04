//
//  TabDropIndicatorDelegate.swift
//  Drift
//
//  Created by Tom Alderson on 05/06/2025.
//

import SwiftUI

struct PinnedTabDropIndicatorDelegate: DropDelegate {
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
               let draggedId = UUID(uuidString: idString) {

                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        // Get the tab that has been dragged here and remove it from the collection of tabs.
                        let draggedTab = tabManager.getTabById(draggedId)!
                        var folderDrag = false
                        
//                        if(draggedTab.tabType != .folder) {
                            // We need to handle the scenario where the tab is being dragged into a folder.
                            
                        if let targetTab = tab {
                            if(targetTab.folderId != nil) {
                                draggedTab.folderId = targetTab.folderId
                                folderDrag = true
                            }
                        }
                        
                        if case .folder = targetID.zone {
                            folderDrag = true
                        }
                            
                        if(folderDrag) {
                            if let folderId = getFolderId(from: targetID) {
                                tabManager.insertTabToFolderTabsList(tab: draggedTab, folderIndex: targetID.index, folderId: folderId)
                            }
                        }else{
                            tabManager.insertTabToPinnedTabsList(tab: draggedTab, pinnedIndex: targetID.index)
                        }
//                        }
                        
                        tabManager.saveTabs()
                        dragOverTarget = nil
                    }
                }
            }
        }

        return true
    }
    
    func getFolderId(from targetID: TabDropTargetID) -> UUID? {
        switch targetID.zone {
        case .folder(let folderId):
            return folderId
        default:
            return nil
        }
    }

    private func adjustedIndex(from oldIndex: Int, to newIndex: Int) -> Int {
        oldIndex < newIndex ? newIndex - 1 : newIndex
    }
}
