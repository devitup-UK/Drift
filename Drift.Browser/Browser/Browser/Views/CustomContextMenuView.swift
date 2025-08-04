//
//  CustomContextMenuView.swift
//  Drift
//
//  Created by Tom Alderson on 11/06/2025.
//

import SwiftUI


class CustomContextMenuView<Content: View>: NSHostingView<Content>, NSMenuItemValidation {
    let tabManager: TabManager
    let tab: TabModel

    init(tabManager: TabManager, tab: TabModel, rootView: Content) {
        self.tabManager = tabManager
        self.tab = tab
        super.init(rootView: rootView)
    }
    
    // Validate your action so it enables the menu item
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor @preconcurrency required init(rootView: Content) {
        fatalError("init(rootView:) has not been implemented")
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        let multipleTabsSelected = tabManager.selectedTabIds.count > 1
        let menu = NSMenu()
        
        if(tab.tabType == .folder) {
            let deleteFolder = NSMenuItem(title: "Delete", action: #selector(deleteFolder), keyEquivalent: "")
            deleteFolder.target = self
            menu.addItem(deleteFolder)
        }else{
            
            
            if(multipleTabsSelected) {
                let copyItem = NSMenuItem(title: "Copy Links", action: #selector(copyLinks), keyEquivalent: "")
                copyItem.target = self
                menu.addItem(copyItem)
                
                // Share submenu (native macOS style)
                let picker = NSSharingServicePicker(items: tabManager.getSelectedTabUrlsAsStringArray())
                let shareMenuItem = picker.standardShareMenuItem
                menu.addItem(shareMenuItem)
                
                menu.addItem(NSMenuItem.separator())
                
                let muteItem = NSMenuItem(title: "Mute", action: #selector(muteTab), keyEquivalent: "")
                muteItem.target = self
                menu.addItem(muteItem)
                
                menu.addItem(NSMenuItem.separator())
                
                let addSplitViewItem = NSMenuItem(title: "Open in Split View", action: #selector(addSplitView), keyEquivalent: "")
                addSplitViewItem.target = self
                menu.addItem(addSplitViewItem)
                
                let duplicateItem = NSMenuItem(title: "Duplicate", action: #selector(duplicateTab), keyEquivalent: "")
                duplicateItem.target = self
                menu.addItem(duplicateItem)
                
                let createFolderItem = NSMenuItem(title: "New Folder with Tabs", action: #selector(createFolderWithTabs), keyEquivalent: "")
                createFolderItem.target = self
                menu.addItem(createFolderItem)
                
                menu.addItem(NSMenuItem.separator())
                
                let archiveItem = NSMenuItem(title: "Archive Tabs", action: #selector(archiveTabs), keyEquivalent: "")
                archiveItem.target = self
                menu.addItem(archiveItem)
                
            }else{
                let copyItem = NSMenuItem(title: "Copy Link", action: #selector(copyLink), keyEquivalent: "")
                copyItem.target = self
                menu.addItem(copyItem)
                
                // Share submenu (native macOS style)
                let picker = NSSharingServicePicker(items: [tab.url])
                let shareMenuItem = picker.standardShareMenuItem
                menu.addItem(shareMenuItem)
                
                menu.addItem(NSMenuItem.separator())
                
                let renameItem = NSMenuItem(title: "Rename...", action: #selector(renameTab), keyEquivalent: "")
                renameItem.target = self
                menu.addItem(renameItem)
                
                let muteItem = NSMenuItem(title: "Mute", action: #selector(muteTab), keyEquivalent: "")
                muteItem.target = self
                menu.addItem(muteItem)
                
                menu.addItem(NSMenuItem.separator())
                
                let addSplitViewItem = NSMenuItem(title: "Add Split View", action: #selector(addSplitView), keyEquivalent: "")
                addSplitViewItem.target = self
                menu.addItem(addSplitViewItem)
                
                let duplicateItem = NSMenuItem(title: "Duplicate", action: #selector(duplicateTab), keyEquivalent: "")
                duplicateItem.target = self
                menu.addItem(duplicateItem)
                
                menu.addItem(NSMenuItem.separator())
                
                let archiveItem = NSMenuItem(title: "Archive Tab", action: #selector(archiveTab), keyEquivalent: "")
                archiveItem.target = self
                menu.addItem(archiveItem)
                
                // TODO: Fix greyed out issue and hook up method.
                let archiveTabsBelowItem = NSMenuItem(title: "Archive Tabs Below", action: #selector(archiveTabsBelow), keyEquivalent: "")
                archiveTabsBelowItem.target = self
                menu.addItem(archiveTabsBelowItem)
            }
        }

        return menu
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    @objc func createFolderWithTabs() {
        tabManager.createNewFolderWithSelectedTabs()
    }
    
    @objc func deleteFolder() {
        tabManager.deleteFolder(tabId: tab.id)
    }
    
    @objc func archiveTabsBelow() {
        print("Archive tabs below clicked")
    }
    
    @objc func archiveTab() {
        tabManager.archiveTab(tabId: tab.id)
    }
    
    @objc func archiveTabs() {
        tabManager.archiveSelectedTabs()
    }
    
    @objc func duplicateTab() {
        if(tabManager.selectedTabIds.count > 0) {
            tabManager.duplicateTabs(tabIds: Array(tabManager.selectedTabIds + [tab.id]))
        }else{
            tabManager.duplicateTab(tabId: tab.id)
        }
    }
    
    @objc func addSplitView() {
        print("Add split view clicked")
    }
    
    @objc func muteTab() {
        print("Mute tab clicked")
    }

    @objc func renameTab() {
        tabManager.setTabRenaming(tabId: tab.id, isRenaming: true)
    }

    @objc func copyLinks() {
        // Loop through all selectedTabs and build up a list of links.
        let links = tabManager.getSelectedTabUrlsAsStringArray().joined(separator: "\n")
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(links, forType: .string)
    }
    
    @objc func copyLink() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(tab.currentWebPage!.url.absoluteString, forType: .string)
    }

    @objc func performShare(_ sender: NSMenuItem) {
        guard let service = sender.representedObject as? NSSharingService else { return }
        service.perform(withItems: [tab.currentWebPage?.url])
    }
}
