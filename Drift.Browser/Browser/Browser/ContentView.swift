//
//  ContentView.swift
//  Browser
//
//  Created by Tom Alderson on 04/06/2025.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @Environment(TabManager.self) private var tabManager
    @Environment(DisplayManager.self) private var displayManager
    
    @State private var sidebarWidth: CGFloat = 250
    private let minSidebarWidth: CGFloat = 200
    private let maxSidebarWidth: CGFloat = 500
    
    @State private var isHoveringOverDivider = false
    @State private var splitViewVisibility = NavigationSplitViewVisibility.all
    @State private var isHoveringOverBackButton = false
    @State private var isHoveringOverForwardButton = false
    @State private var isHoveringOverReloadButton = false


    var body: some View {
        
        ZStack {
            HStack(spacing: 2) {
                NavigationSplitView(columnVisibility: $splitViewVisibility) {
                    SidebarView()
                        .environment(tabManager)
                } detail: {
                    //                VStack(spacing: 0) {
                    //                ZStack {
                    //                    RoundedRectangle(cornerRadius: 5) // optional: use your own if you want custom style
                    //                        .frame(maxWidth: 5, maxHeight: .infinity)
                    //                        .foregroundStyle(Color.clear) // make it fully transparent if you want no line
                    ////                        .padding(.top, -10)
                    //                        .padding(.bottom, 18)
                    //                        .onHover { hovering in
                    //                            isHoveringOverDivider = hovering
                    //                            if hovering {
                    //                                NSCursor.resizeLeftRight.set()
                    //                            } else {
                    //                                NSCursor.arrow.set()
                    //                            }
                    //
                    //                        }
                    //
                    //                    RoundedRectangle(cornerRadius: 5) // optional: use your own if you want custom style
                    //                        .frame(maxWidth: 5, maxHeight: .infinity)
                    //                        .foregroundStyle(Color.white.opacity(0.7)) // make it fully transparent if you want no line
                    //                        .padding(.top, 10)
                    //                        .padding(.bottom, 18)
                    //                        .opacity(isHoveringOverDivider ? 1.0 : 0.0)
                    //                        .animation(.easeInOut(duration: 0.2), value: isHoveringOverDivider)
                    //
                    //
                    //
                    //                }
                    //                .gesture(
                    //                    DragGesture()
                    //                        .onChanged { value in
                    //                            NSCursor.resizeLeftRight.set()
                    //                            let newWidth = sidebarWidth + value.translation.width
                    //                            if newWidth >= minSidebarWidth && newWidth <= maxSidebarWidth {
                    //                                sidebarWidth = newWidth
                    //                            }
                    //                        }
                    //                        .onEnded { _ in
                    //                            NSCursor.arrow.set()
                    //                        }
                    //                )
                    
                    
                    
                    //            } detail: {
                    ZStack {
                        if let tab = tabManager.tabs.first(where: { $0.id == tabManager.focusedTabId }) {
                            
                            // Main Browser View
                            
                            if let activeTabIndex = tabManager.tabs.firstIndex(where: { $0.id == tabManager.focusedTabId }) {
                                if let webView = tabManager.webViewManager.webView(for: tabManager.tabs[activeTabIndex].id) {
                                    WebViewComponent(tab: tab, webView: webView)
                                        .id(tabManager.tabs[activeTabIndex].id)
                                        .environment(tabManager.webViewManager)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.bottom, 10)
                                        .padding(.top, displayManager.isSidebarOpen ? -25 : 0)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .toolbar(removing: .title)
                                }else{
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(.black).opacity(0.4))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding(.horizontal, 10)
                                        .padding(.bottom, 10)
                                        .padding(.top, displayManager.isSidebarOpen ? -25 : 0)
                                        .toolbar(removing: .title)
                                }
                            }
                        }else {
                            // fallback UI maybe? return an EmptyView() or something safe
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(.black).opacity(0.4))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                                .padding(.top, displayManager.isSidebarOpen ? -25 : 0)
                                .toolbar(removing: .title)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar {
                        ToolbarItem {
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
                        }
                        ToolbarItem {
                            
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
                        }
                        
                        ToolbarItem {
                            
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
                        
                        ToolbarItem {
                            Spacer()
                        }
                        
                        ToolbarItem {
                            AddressBarComponentView()
                                .environment(tabManager)
                                .padding(10)
                                .onTapGesture {
                                    if tabManager.currentTab != nil {
                                        tabManager.launcherInitialText = tabManager.currentURLString
                                        tabManager.showTabLauncher()
                                    }else{
                                        tabManager.launcherInitialText = nil
                                        tabManager.showTabLauncher()
                                    }
                                }
                        }
                        
                        ToolbarItem {
                            Spacer()
                        }
                    }
                }
                .onChange(of: splitViewVisibility) { oldValue, newValue in
                    // TODO: Use a displayManager to handle the padding of the browser view.
                    if(newValue == NavigationSplitViewVisibility.detailOnly) {
                        displayManager.isSidebarOpen = false
                    }
                    
                    if(newValue == NavigationSplitViewVisibility.all) {
                        displayManager.isSidebarOpen = true
                    }
                }
            }
            
            if(tabManager.isTabLauncherVisible) {
                TabLauncherComponent()
                    .modifier(KeyPressModifier { event in
                        if event.keyCode == 53 { // 53 is Escape
                            tabManager.hideTabLauncher()
                        }
                    })
                    .environment(tabManager)
            }
        }
    }
    
    
    
    func getColorForNavigationButton(_ boolToCheck: Bool) -> Color {
        return boolToCheck ? Color.white : Color.gray
    }
        
    
}

#Preview {
    ContentView()
}
