//
//  PinnedTabsListView.swift
//  Drift
//
//  Created by Tom Alderson on 06/06/2025.
//

import SwiftUI

struct PinnedTabsListView: View {
    @Environment(TabManager.self) private var tabManager
    @State private var dragOverPinnedIndex: Int? = nil
    @State private var dragOverTargetID: TabDropTargetID? = nil

    var body: some View {
        Rectangle()
            .opacity(0)
            .frame(height: 2)
        
        ForEach(Array(tabManager.sortedTopLevelPinnedAndFolderTabs.enumerated()), id: \.element.id) { index, tab in
            TabWrapperComponentView(index: index, pinned: true, tab: tab, dragOverTargetId: $dragOverTargetID)
                .environment(tabManager)
                .id(tab.id)
        }
        
        // Final indicator to handle dropping a tab at the end of the pinnes tabs list.
        TabDropIndicator(targetID: TabDropTargetID(zone: .pinned, index: tabManager.getNextAvailablePinnedIndex()), dragOverTarget: $dragOverTargetID, tab: nil, tabManager: tabManager)
            .padding(.leading, 4)
            .padding(.trailing, 18)
    }
}

//#Preview {
//    // Mock our tab manager.
//    var tabManager = TabManager()
//    
//    // Mock our pinned tabs.
//    let unloadedPinnedTab = TabModel(url: URL(string: "https://www.google.com")!)
//    unloadedPinnedTab.tabType = .pinned
//    unloadedPinnedTab.title = "Unloaded Pinned Tab"
//    unloadedPinnedTab.unloaded = true
//    
//    let loadedPinnedTab = TabModel(url: URL(string: "https://www.google.com")!)
//    loadedPinnedTab.tabType = .pinned
//    loadedPinnedTab.title = "Loaded Pinned Tab"
//    loadedPinnedTab.unloaded = false
//    
//    
//    // Mock our standard tabs.
//    let standardTab = TabModel(url: URL(string: "https://www.google.com")!)
//    standardTab.tabType = .standard
//    standardTab.title = "Standard Tab"
//    tabManager.tabs = [unloadedPinnedTab, loadedPinnedTab, standardTab]
//    
//    return VStack(spacing: 0) {
//        PinnedTabsListView()
//            .environment(tabManager)
//    }
//}
