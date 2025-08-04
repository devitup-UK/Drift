//
//  TabWrapperComponentView.swift
//  Drift
//
//  Created by Tom Alderson on 05/06/2025.
//

import SwiftUI

struct TabWrapperComponentView: View {
    var index: Int
    var pinned: Bool
    var tab: TabModel

    @Environment(TabManager.self) private var tabManager
    @Binding var dragOverTargetId: TabDropTargetID?

    
    var body: some View {
        VStack {
            TabDropIndicator(targetID: getTabTargetId(tab: tab), dragOverTarget: $dragOverTargetId, tab: tab, tabManager: tabManager)
                .padding(.leading, tabManager.getTabLevel(tabId: tab.id)  == 0 ? 4 : CGFloat(14 * tabManager.getTabLevel(tabId: tab.id)))
            
            
            TabComponentView(tab: tab)
                .onDrag {
                    let provider = NSItemProvider()
                    provider.registerDataRepresentation(forTypeIdentifier: "public.text", visibility: .all) { completion in
                        let data = tab.id.uuidString.data(using: .utf8)
                        completion(data, nil)
                        return nil
                    }
                    return provider
                }
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            tabManager.setTabRenaming(tabId: tab.id, isRenaming: true)
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 1)
                        .onEnded {
                            handleClick(tabId: tab.id)
                        }
                )
                .onExitCommand {
                    tabManager.setTabRenaming(tabId: tab.id, isRenaming: false)
                }
                .padding(.leading, CGFloat(10 * tabManager.getTabLevel(tabId: tab.id)))
                .padding(.top, -8)
                .transition(.identity)
                .environment(tabManager)
            
            if(tab.tabType == .folder && tab.folderOpen) {
                FolderTabsListView(folderId: tab.id)
            }
        }
    }
    
    private func getTabTargetId(tab: TabModel) -> TabDropTargetID {
        if(tab.tabType == .standard) {
            return TabDropTargetID(zone: .standard, index: tab.standardIndex ?? 0)
        }
        
        if(tab.tabType == .pinned) {
            if(tab.folderId != nil) {
                return TabDropTargetID(zone: .folder(tab.folderId!), index: tab.folderIndex ?? 0)
            }else{
                return TabDropTargetID(zone: .pinned, index: tab.pinnedIndex ?? 0)
            }
        }
        
        if(tab.tabType == .folder) {
            return TabDropTargetID(zone: .pinned, index: tab.pinnedIndex ?? 0)
        }
        
        return TabDropTargetID(zone: .standard, index: 0)
    }
    
    private func handleClick(tabId: UUID) {
        let flags = NSEvent.modifierFlags

        if flags.contains(.command) {
            // Toggle selection
            tabManager.selectOrDeselectTab(tabId: tab.id)
        } else {
            if let tab = tabManager.getTabById(tabId) {
                if(tab.tabType == .folder) {
                    tabManager.toggleFolderStatus(tabId: tabId)
                }else{
                    // Regular click = single selection
                    tabManager.focusTab(tabId: tab.id)
                    tabManager.selectedTabIds.removeAll()
                }
            }
        }
    }
}

//#Preview {
//    var tab = TabModel(url: URL(string: "https://www.google.com")!)
//    TabWrapperComponentView(index: 0, pinned: false, tab: tab, dragOverIndex: Binding<Int?>(
//        get: { 1 },
//        set: { _ in /* do nothing */ }
//    ))
//    .environment(TabManager())
//}
