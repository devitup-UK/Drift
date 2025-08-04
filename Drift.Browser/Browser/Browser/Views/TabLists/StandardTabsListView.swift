//
//  StandardTabsListView.swift
//  Drift
//
//  Created by Tom Alderson on 06/06/2025.
//

import SwiftUI

struct StandardTabsListView: View {
    @Environment(TabManager.self) private var tabManager
    @State private var dragOverTarget: TabDropTargetID? = nil
    
    var body: some View {
        ForEach(Array(tabManager.sortedStandardTabs.enumerated()), id: \.element.id) { index, tab in
            TabWrapperComponentView(index: index, pinned: false, tab: tab, dragOverTargetId: $dragOverTarget)
                    .environment(tabManager)
                    .id(tab.id)
        }
        
        // The very last tab drop indicator so tabs can be dropped at the end of the list.
        TabDropIndicator(targetID: TabDropTargetID(zone: .standard, index: tabManager.getNextAvailableStandardIndex()), dragOverTarget: $dragOverTarget, tab: nil, tabManager: tabManager)
            .padding(.leading, 4)
            .padding(.trailing, 18)
    }
}

#Preview {
    StandardTabsListView()
}
