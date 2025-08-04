//
//  TabComponentView.swift
//  Drift
//
//  Created by Tom Alderson on 04/06/2025.
//

import SwiftUI

struct TabComponentView: View {
    @Environment(TabManager.self) private var tabManager

    var tab: TabModel
    @State private var isHoveringOverTab = false
    @State private var isDragging = false
    @State private var isHoveringOverCloseButton = false
    @FocusState private var isTitleEditorFocused: Bool
    @State private var tempName: String = ""
    @State private var showShareMenu = false
    
    var body: some View {
        NativeContextMenuWrapper(tabManager: tabManager, tab: tab) {
            HStack(alignment: .center, spacing: .zero) {
                if let tabFavicon = tab.favicon {
                    if(tab.tabType == .folder) {
                        Image(systemName: tab.folderOpen ? "folder" : "folder.fill")
                            .resizable()
                            .frame(width: 20, height: 16)
                    }else{
                        Image(nsImage: tabFavicon)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                } else {
                    Image(systemName: "globe") // fallback
                        .frame(width: 20, height: 20)
                }
                
                if tab.isRenaming {
                    TextField("", text: $tempName, onCommit: {
                        tabManager.setTabRenaming(tabId: tab.id, isRenaming: false)
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .padding(.leading, 8)
                    .focused($isTitleEditorFocused)
                    .onAppear {
                        tempName = tab.title
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.isTitleEditorFocused = true
                        }
                    }
                    .onSubmit {
                        tabManager.setTabTitleOverride(tabId: tab.id, title: tempName)
                        tabManager.setTabRenaming(tabId: tab.id, isRenaming: false)
                    }
                }else{
                    Text(tab.title)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cornerRadius(8)
                        
                }
                
                if(isHoveringOverTab && tab.tabType != .folder) {
                    if(tab.tabType == .pinned) {
                        if(!tab.unloaded) {
                            Image(systemName: "minus")
                                .frame(width: 16, height: 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(isHoveringOverCloseButton ? Color.white.opacity(0.1) : Color.clear)
                                        .padding(-2)
                                }
                                .onHover { hovering in
                                    isHoveringOverCloseButton = hovering
                                }
                                .onTapGesture {
                                    tabManager.unloadTab(tabId: tab.id)
                                }
                        }else{
                            Image(systemName: "xmark")
                                .frame(width: 16, height: 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(isHoveringOverCloseButton ? Color.white.opacity(0.1) : Color.clear)
                                        .padding(-2)
                                }
                                .onHover { hovering in
                                    isHoveringOverCloseButton = hovering
                                }
                                .onTapGesture {
                                    tabManager.archiveTab(tabId: tab.id)
                                }
                        }
                    }else{
                        Image(systemName: "xmark")
                            .frame(width: 16, height: 16)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isHoveringOverCloseButton ? Color.white.opacity(0.1) : Color.clear)
                                    .padding(-2)
                            }
                            .onHover { hovering in
                                isHoveringOverCloseButton = hovering
                            }
                            .onTapGesture {
                                tabManager.archiveTab(tabId: tab.id)
                            }
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(determineTabBackgroundColor(hovered: isHoveringOverTab, active: tabManager.focusedTabId == tab.id, selected: tabManager.selectedTabIds.contains(tab.id)))
            }
            .onHover { hovering in
                isHoveringOverTab = hovering
            }
        }
        
    }
    
    func determineTabBackgroundColor(hovered: Bool, active: Bool, selected: Bool) -> Color {
        if(active) {
            return Color.white.opacity(0.2);
        }else{
            if(hovered || selected) {
                return Color.white.opacity(0.1);
            }
        }
        return Color.clear;
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
//    VStack {
//        TabComponentView(tab: unloadedPinnedTab)
//            .environment(tabManager)
//        
//        TabComponentView(tab: loadedPinnedTab)
//            .environment(tabManager)
//        
//        TabComponentView(tab: standardTab)
//            .environment(tabManager)
//    }
//    .padding(20)
//}
