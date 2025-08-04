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
    
    @State private var isHoveringOverBackButton = false
    @State private var isHoveringOverForwardButton = false
    @State private var isHoveringOverReloadButton = false

    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Spacer()
                    // Back, forward and refresh buttons.
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 14, height: 13)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .fill((isHoveringOverBackButton && (tabManager.focusedTab?.canGoBack() ?? false)) ? Color.white.opacity(0.1) : Color.clear)
                                .padding(-8)
                        }
                        .foregroundStyle(getColorForNavigationButton(tabManager.focusedTab?.canGoBack() ?? false))
                        .onTapGesture {
                            tabManager.goBack()
                        }
                        .onHover(perform: { isHovering in
                            isHoveringOverBackButton = isHovering
                        })
                    
                    // Back, forward and refresh buttons.
                    Image(systemName: "arrow.forward")
                        .resizable()
                        .frame(width: 14, height: 13)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .fill((isHoveringOverForwardButton && (tabManager.focusedTab?.canGoForward() ?? false)) ? Color.white.opacity(0.1) : Color.clear)
                                .padding(-8)
                        }
                        .foregroundStyle(getColorForNavigationButton(tabManager.focusedTab?.canGoForward() ?? false))
                        .onTapGesture {
                            tabManager.goForward()
                        }
                        .onHover(perform: { isHovering in
                            isHoveringOverForwardButton = isHovering
                        })
                    
                    // Back, forward and refresh buttons.
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 16, height: 18)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isHoveringOverReloadButton ? Color.white.opacity(0.1) : Color.clear)
                                .padding(.horizontal, -6)
                                .padding(.vertical, -4)
                        }
                        .foregroundStyle(.primary)
                        .onTapGesture {
                            tabManager.reload()
                        }
                        .onHover(perform: { isHovering in
                            isHoveringOverReloadButton = isHovering
                        })
            }
            .padding(.top, 10)
            
            AddressBarComponentView()
                .environment(tabManager)
                .padding(.vertical, 10)
                .onTapGesture {
                    if tabManager.currentTab != nil {
                        tabManager.launcherInitialText = tabManager.currentURLString
                        tabManager.showTabLauncher()
                    }else{
                        tabManager.launcherInitialText = nil
                        tabManager.showTabLauncher()
                    }
                }
            
            
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
    
    
    func getColorForNavigationButton(_ boolToCheck: Bool) -> Color {
        return boolToCheck ? Color.white : Color.gray
    }
}

#Preview {
    SidebarView()
}
