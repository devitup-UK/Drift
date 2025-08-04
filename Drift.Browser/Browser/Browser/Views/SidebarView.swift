//
//  SidebarView.swift
//  Drift
//
//  Created by Tom Alderson on 04/06/2025.
//

import SwiftUI

struct SidebarView: View {
    @Environment(TabManager.self) private var tabManager
    @State private var isHoveringPinnedZone = false
    @State private var dragOverTabId: UUID?

    
    var body: some View {
        VStack(spacing: 0) {
            
            
            
            HStack {
                Text("Temporary Space")
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 10)
            .onDrop(of: [.text], delegate: SpaceDropDelegate(
                tabManager: tabManager,
                isHovering: $isHoveringPinnedZone
            ))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHoveringPinnedZone && tabManager.pinnedTabs.isEmpty ? Color.gray.opacity(0.2) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isHoveringPinnedZone)
            )
            
            ScrollBorderWrapper {
                    
                // Pinned Tabs
                PinnedTabsListView()
                    .environment(tabManager)
                
                if(!tabManager.standardTabs.isEmpty) {
                    Divider()
                        .padding(.vertical, 8)
                }
                
                // Button to create a new tab.
                NewTabComponentView()
                    .environment(tabManager)
                    .onTapGesture {
                        tabManager.launcherInitialText = nil
                        tabManager.showTabLauncher()
                    }
                
                // Standard tabs list.
                StandardTabsListView()
                    .environment(tabManager)
                

            }
            .animation(.linear(duration: 0.25), value: tabManager.tabs.indices)
            .onTapGesture {
                tabManager.clearSelectedTabs()
            }
            
            Spacer()
            
            
            SidebarFooterComponentView()
                .environment(tabManager)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 10)
    }
}

#Preview {
    SidebarView()
}
