//
//  TabManager.swift
//  Drift
//
//  Created by Tom Alderson on 04/06/2025.
//

import Foundation
import WebKit

@Observable
class TabManager {
    // Tab Lists
    var tabs: [TabModel] = []
    var webViewManager: WebViewManager!
    var pinnedAndFolderTabs: [TabModel] {
        tabs.filter { $0.tabType == .pinned || $0.tabType == .folder }
    }
    var sortedPinnedAndFolderTabs: [TabModel] {
        pinnedAndFolderTabs.sorted { $0.pinnedIndex ?? 0 < $1.pinnedIndex ?? 0 }
    }
    var pinnedTabs: [TabModel] {
        tabs.filter { $0.tabType == .pinned }
    }
    var sortedPinnedTabs: [TabModel] {
        pinnedTabs.sorted { $0.pinnedIndex ?? 0 < $1.pinnedIndex ?? 0 }
    }
    var standardTabs: [TabModel] {
        tabs.filter { $0.tabType == .standard }
    }
    var sortedStandardTabs: [TabModel] {
        standardTabs.sorted { $0.standardIndex ?? 0 < $1.standardIndex ?? 0 }
    }
    var topLevelPinnedAndFolderTabs : [TabModel] {
        pinnedAndFolderTabs.filter { $0.folderId == nil }
    }
    var sortedTopLevelPinnedAndFolderTabs : [TabModel] {
        topLevelPinnedAndFolderTabs.sorted { $0.pinnedIndex ?? 0 < $1.pinnedIndex ?? 0 }
    }
    var archivedTabs: [TabModel] {
        tabs.filter { $0.tabType == .archived }
    }
    
    
    var focusedTab: TabModel? {
        tabs.first(where: { $0.id == focusedTabId })
    }


    var selectedTabIds: [UUID] = []
    var focusedTabId: UUID?
    var isTabLauncherVisible: Bool = false
    var launcherInitialText: String? = nil
    var dragOverTabId: UUID?
    var dragOverPinnedIndex: Int? = nil
    var currentPip: PiPWindowController? = nil
    var localStorageStore: [String: String] = [:]

    init() {
        self.webViewManager = WebViewManager(tabManager: self)

    }
    
    func broadcastLocalStorageUpdate() {
        // Prepare the data to send to JS
        // We send three buckets: keys to set, keys to remove, and if we cleared everything
        
        // For simplicity, we just send everything to set and no remove or clear
        let jsonData = try! JSONSerialization.data(withJSONObject: ["type": "syncLocalStorage", "data": ["set": localStorageStore]], options: [])
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
        
        for tab in tabs {
            if let tabWebView = webViewManager.webView(for: tab.id) {
                let js = "window.postMessage(\(jsonString))"
                tabWebView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
    }
    
    func getNextAvailablePinnedIndex() -> Int {
       return (pinnedAndFolderTabs.compactMap { $0.pinnedIndex }.max() ?? 0) + 1
    }
    
    func getNextAvailableStandardIndex() -> Int {
       return (standardTabs.compactMap { $0.standardIndex }.max() ?? 0) + 1
    }
    
    func tabsInFolder(_ folderId: UUID) -> [TabModel] {
        tabs.filter { $0.folderId == folderId }
    }
    
    func addToHistory(_ tabId: UUID, url: URL) {
        if
            let tab = tabs.first(where: { $0.id == tabId })
        {
            tab.addToHistory(url)
            tabs[tabs.firstIndex(of: tab)!] = tab
        }
    }

    func createNewTab(url: URL = URL(string: "https://www.google.com")!, configuration: WKWebViewConfiguration? = nil) {
        let newTab = TabModel(url: url)
        var webView = webViewManager.createWebView(for: newTab)
        if let predefinedConfiguration = configuration {
            webView = webViewManager.createWebViewWithConfiguration(for: newTab, configuration: predefinedConfiguration)
        }
        webView.load(URLRequest(url: url.canonicalYouTube))
        newTab.standardIndex = self.getNextAvailableStandardIndex()
        self.tabs.append(newTab)
        self.focusedTabId = newTab.id
        print("Created new tab: \(newTab.id) with URL: \(url) and standardIndex: \(String(describing: newTab.standardIndex))")
        self.saveTabs()
    }
    
    func setTabTitle(tabId: UUID, title: String) {
        if let tab = tabs.first(where: { $0.id == tabId }) {
            // Find the index of the tab in the array
            let index = tabs.firstIndex(where: { $0.id == tabId })!
            
            // Update the titleOverride property of the tab
            tab.setTitle(title: title)
            
            // Replace the old tab with the updated version in the array
            tabs[index] = tab
        }
        
        saveTabs()
    }
    
    func setTabTitleOverride(tabId: UUID, title: String) {
        if let tab = tabs.first(where: { $0.id == tabId }) {
            // Find the index of the tab in the array
            let index = tabs.firstIndex(where: { $0.id == tabId })!
            
            // Update the titleOverride property of the tab
            tab.titleOverride = title
            
            // Replace the old tab with the updated version in the array
            tabs[index] = tab
        }
        
        saveTabs()
    }
    
    func setTabFavicon(tabId: UUID, favicon: NSImage) {
        if let tab = tabs.first(where: { $0.id == tabId }) {
            // Find the index of the tab in the array
            let index = tabs.firstIndex(where: { $0.id == tabId })!
            
            // Update the titleOverride property of the tab
            tab.setFavicon(favicon: favicon)
            
            // Replace the old tab with the updated version in the array
            tabs[index] = tab
        }
        
        saveTabs()
    }
    
    func setTabRenaming(tabId: UUID, isRenaming: Bool) {
        if let tab = tabs.first(where: { $0.id == tabId }) {
            let index = tabs.firstIndex(of: tab)!
            tab.isRenaming = isRenaming
            tabs[index] = tab
        }
    }
    
    func getSelectedTabs() -> [TabModel] {
        tabs.filter { selectedTabIds.contains($0.id) }
    }
    
    func archiveSelectedTabs() {
        getSelectedTabs().forEach { tab in
            archiveTab(tabId: tab.id)
        }
    }
    
    func getSelectedTabUrlsAsStringArray() -> [String] {
        getSelectedTabs().map(\.self).map(\.currentWebPage!.url).map(\.absoluteString)
    }
    
    func getTabsInFolder(_ folderId: UUID) -> [TabModel] {
        tabs.filter { $0.folderId == folderId && $0.tabType != .archived}
    }
    
    func getSortedTabsInFolder(_ folderId: UUID) -> [TabModel] {
        getTabsInFolder(folderId)
            .sorted { $0.folderIndex ?? 0 < $1.folderIndex ?? 0 }
    }
    
    func getTabById(_ id: UUID) -> TabModel? {
        for tab in tabs {
            if tab.id == id {
                return tab
            }
        }
        return nil
    }
    
    func getTabIndexFromId(tabId: UUID) -> Int? {
        tabs.firstIndex(where: { $0.id == tabId })
    }

    func archiveTab(tabId: UUID) {
        guard let index = getTabIndexFromId(tabId: tabId) else { return }
        guard let tab = getTabById(tabId) else { return }

        // Unload the tab and then archive it, this keeps it in memory but stops the WKWebView from running and removes it from the tab list.
        unloadTab(tabId: tabId)
        tab.tabType = .archived

        // If the tab being closed was selected, choose a new one
        if focusedTabId == tabId {
            if index < tabs.count {
                // There's a next tab to select
                focusedTabId = tabs[index].id
            } else if index - 1 >= 0 {
                // No next, fallback to previous
                focusedTabId = tabs[index - 1].id
            } else {
                // No tabs left
                focusedTabId = nil
            }
        }
    }
    
    func getLastStandardTabIndex() -> Int {
        standardTabs.last?.standardIndex ?? 0
    }
    
    func getLastPinnedAndFoldersTabIndex() -> Int {
        pinnedAndFolderTabs.last?.pinnedIndex ?? 0
    }
    
    func deleteFolder(tabId: UUID) {
        // TODO: Add a confirmation dialog to let the user know that once they delete the tab they will be archiving the tabs associated to it.
        if let tab = getTabById(tabId) {
            tabs.remove(at: tabs.firstIndex(of: tab)!)
            
            // Loop through all tabs with a matching folderId of the tabId and mark them as archived.
            for tab in getTabsInFolder(tabId) {
                tab.unloaded = true
                tab.tabType = .archived
            }
        }
        
        saveTabs()
    }
    
    func unloadTab(tabId: UUID) {
        guard let index = getTabIndexFromId(tabId: tabId) else { return }
        
        if let tab = tabs.first(where: { $0.id == tabId }) {
            // Find the index of the tab in the array
            let index = tabs.firstIndex(where: { $0.id == tabId })!
            
            // Update the titleOverride property of the tab
            tab.unloaded = true
            if let tabWebView = webViewManager.webView(for: tab.id) {
                webViewManager.destroyWebView(tabWebView)
            }
            
            // Replace the old tab with the updated version in the array
            tabs[index] = tab
        }

        // If the tab being closed was selected, choose a new one
        if focusedTabId == tabId {
            if index < tabs.count {
                // There's a next tab to select
                focusedTabId = tabs[index].id
            } else if index - 1 >= 0 {
                // No next, fallback to previous
                focusedTabId = tabs[index - 1].id
            } else {
                // No tabs left
                focusedTabId = nil
            }
        }
        
        saveTabs()
    }
    
    
    func pinTab(tabId: UUID) {
        if let tab = tabs.first(where: { $0.id == tabId }) {
            tab.tabType = .pinned
            tab.pinnedIndex = getNextAvailablePinnedIndex()
        }
        
        saveTabs()
    }
    
    func unpinTab(tabId: UUID) {
        if let tab = getTabById(tabId) {
            tab.tabType = .standard
        }
        
        saveTabs()
    }
    
    func selectOrDeselectTab(tabId: UUID) {
        guard tabs.firstIndex(where: { $0.id == tabId }) != nil else { return }
        
        // Check if the target tab is the currently focused tab and if not, add the focused tab to the selectedTabIds.
        if focusedTabId != tabId {
            if !selectedTabIds.contains(focusedTabId!) {
                selectedTabIds.append(focusedTabId!)
            }
        }
        
        if tabs.first(where: { $0.id == tabId }) != nil {
            if(selectedTabIds.contains(tabId)) {
                selectedTabIds.removeAll { $0 == tabId }
            }else{
                selectedTabIds.append(tabId)
            }
        }
    }
    
    func clearSelectedTabs() {
        selectedTabIds.removeAll()
    }
    
    func toggleFolderStatus(tabId: UUID) {
        if let tab = getTabById(tabId) {
            if tab.tabType == .folder {
                tab.folderOpen.toggle()
            }
        }
    }
    
    func goBack() {
        if let focusedTabWebView = webViewManager.webView(for: focusedTabId!) {
            focusedTab?.goBack(focusedTabWebView)
        }
    }
    
    func goForward() {
        if let focusedTabWebView = webViewManager.webView(for: focusedTabId!) {
            focusedTab?.goForward(focusedTabWebView)
        }
    }
    
    func reload() {
        if let focusedTabId = focusedTab?.id,
            let focusedTabWebView = webViewManager.webView(for: focusedTabId) {
            focusedTabWebView.reload()
        }
    }
    
    func insertTabToStandardTabsList(tab: TabModel, standardIndex: Int) {
        // Make sure tab is set up correctly
        tab.pinnedIndex = nil
        tab.tabType = .standard
        tab.folderId = nil

        // Inject it into the list at the desired position
        let tabsToReorder = standardTabs.filter { $0.id != tab.id }
        var reordered = tabsToReorder

        if standardIndex >= reordered.count {
            reordered.append(tab)
        } else {
            reordered.insert(tab, at: standardIndex)
        }

        // Reassign standardIndex for each one in order
        for (i, t) in reordered.enumerated() {
            t.standardIndex = i
        }
    }
    
    func insertTabToPinnedTabsList(tab: TabModel, pinnedIndex: Int) {
        // Make sure tab is set up correctly
        tab.standardIndex = nil
        tab.folderIndex = nil
        tab.folderId = nil
        // Folders can stay as folders, we don't need to set them as pinned because they can only be pinned.
        if(tab.tabType != .folder) {
            tab.tabType = .pinned
        }

        // Inject it into the list at the desired position
        let tabsToReorder = pinnedAndFolderTabs.filter { $0.id != tab.id }
        var reordered = tabsToReorder

        if pinnedIndex >= reordered.count {
            reordered.append(tab)
        } else {
            reordered.insert(tab, at: pinnedIndex)
        }

        // Reassign standardIndex for each one in order
        for (i, t) in reordered.enumerated() {
            t.pinnedIndex = i
        }
    }
    
    func insertTabToFolderTabsList(tab: TabModel, folderIndex: Int, folderId: UUID) {
        // Make sure tab is set up correctly
        tab.standardIndex = nil
        tab.pinnedIndex = nil
        tab.folderIndex = folderIndex
        // Folders can stay as folders, we don't need to set them as pinned because they can only be pinned.
        if(tab.tabType != .folder) {
            tab.tabType = .pinned
        }
        tab.folderId = folderId

        // Inject it into the list at the desired position
        let tabsToReorder = getTabsInFolder(folderId).filter { $0.id != tab.id }
        var reordered = tabsToReorder

        if folderIndex >= reordered.count {
            reordered.append(tab)
        } else {
            reordered.insert(tab, at: folderIndex)
        }

        // Reassign standardIndex for each one in order
        for (i, t) in reordered.enumerated() {
            t.folderIndex = i
        }
    }
    
    func recalculateStandardTabIndices() {
        for (i, tab) in sortedStandardTabs.enumerated() {
            tab.standardIndex = i
        }
    }
    
    func recalculatePinnedTabIndices() {
        for (i, tab) in sortedPinnedTabs.enumerated() {
            tab.standardIndex = i
        }
    }
    
    func getTabLevel(tabId: UUID) -> Int {
        guard let tab = getTabById(tabId) else {
            return 0
        }

        guard let folderId = tab.folderId else {
            return 0
        }

        return 1 + getTabLevel(tabId: folderId)
    }
    
    // TODO: Add logic to add folder index.
    func addTabToFolder(tabId: UUID, folderId: UUID) {
        if let folder = tabs.first(where: { $0.id == folderId }) {
            if let tab = tabs.first(where: { $0.id == tabId }) {
                let index = tabs.firstIndex(where: { $0.id == tabId })!
                tab.tabType = .pinned
                tab.folderId = folder.id
                tabs[index] = tab
            }
        }
        
        saveTabs()
    }
    
    func removeTabFromFolder(tabId: UUID, folderId: UUID) {
        if tabs.first(where: { $0.id == folderId }) != nil {
            if let tab = tabs.first(where: { $0.id == tabId }) {
                let index = tabs.firstIndex(where: { $0.id == tabId })!
                tab.folderId = nil
                tabs[index] = tab
            }
        }
        
        saveTabs()
    }
    
    func getNextAvailableIndexForFolder(folderId: UUID) -> Int
    {
        var nextAvailableIndex = 0
        
        tabs.forEach { tab in
            if tab.folderId == folderId {
                if let folderIndex = tab.folderIndex {
                    if folderIndex >= nextAvailableIndex {
                        nextAvailableIndex = folderIndex + 1
                    }
                }
            }
        }
        
        return nextAvailableIndex
    }

    
    func duplicateTabs(tabIds: [UUID]) {
        tabs.forEach { tab in
            duplicateTab(tabId: tab.id)
        }
    }
    
    func createNewFolderWithSelectedTabs() {
        // Create a new tab folder.
        let folder = TabModel(unloaded: false, titleOverride: "", tabType: .folder, folderId: nil)
        folder.titleOverride = "Untitled"
        folder.isRenaming = true
        folder.folderOpen = true
        folder.pinnedIndex = getNextAvailablePinnedIndex()
        tabs.append(folder)
        
        // Folders will always be created at the top level.
        var folderIndex = 0
        
        // Loop through all of the selected tabs and add them to the folder.
        selectedTabIds.forEach { tabId in
            if let tab = tabs.first(where: { $0.id == tabId }) {
                _ = tabs.firstIndex(where: { $0.id == tabId })!
                tab.tabType = .pinned
                tab.pinnedIndex = nil
                tab.folderId = folder.id
                tab.folderIndex = folderIndex
            }
            folderIndex+=1
        }
        
        clearSelectedTabs()
        saveTabs()
    }
    
    func duplicateTab(tabId: UUID) {
        guard tabs.firstIndex(where: { $0.id == tabId }) != nil else { return }
        
        if let tab = tabs.first(where: { $0.id == tabId }),
           let currentWebPage = tab.currentWebPage {
            let duplicatedTab = TabModel(url: currentWebPage.url, unloaded: tab.unloaded, titleOverride: tab.titleOverride, tabType: tab.tabType, folderId: tab.folderId)
            tabs.append(duplicatedTab)
            focusTab(tabId: duplicatedTab.id)
        }
    }

    func focusTab(tabId: UUID) {
        focusedTabId = tabId
        
        guard tabs.firstIndex(where: { $0.id == tabId }) != nil else { return }
        
        if let tab = tabs.first(where: { $0.id == tabId }),
           let currentWebPage = tab.currentWebPage {
            
            if(tab.unloaded) {
                tab.unloaded = false
                
                let webView = webViewManager.createWebView(for: tab)
                webView.load(URLRequest(url: currentWebPage.url.canonicalYouTube))
            }
            // Find the index of the tab in the array
            let index = tabs.firstIndex(where: { $0.id == tabId })!
            
            // Replace the old tab with the updated version in the array
            tabs[index] = tab
        }
    }
    
    func showTabLauncher() {
        isTabLauncherVisible = true
    }
    
    func hideTabLauncher() {
        isTabLauncherVisible = false
    }
    
    func saveTabs() {
        let codableTabs = tabs.map { $0.toCodable() }

        do {
            let data = try JSONEncoder().encode(codableTabs)
            let url = getTabsFileURL()
            try data.write(to: url, options: [.atomic])
        } catch {
            print("❌ Failed to save tabs: \(error)")
        }
    }
    
    private func getTabsFileURL() -> URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

        let folderURL = directory.appendingPathComponent("Drift", isDirectory: true)

        // Create folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }

        return folderURL.appendingPathComponent("tabs.json")
    }

    func loadTabs() {
        let url = getTabsFileURL()

        guard let data = try? Data(contentsOf: url),
              let codableTabs = try? JSONDecoder().decode([CodableTabModel].self, from: data)
        else {
            print("⚠️ No saved tabs found or failed to decode.")
            return
        }

        let loadedTabs = codableTabs.map { TabModel.fromCodable($0) }
        for tab in loadedTabs {
            if !tab.unloaded && tab.tabType != .folder {
                if let currentWebPage = tab.currentWebPage {
                    let webView = webViewManager.createWebView(for: tab)
                    webView.load(URLRequest(url: currentWebPage.url))
                }
            }
        }

        tabs += loadedTabs
    }
    
    // ───────────────────────────────
    // MARK: – Computed Properties
    // ───────────────────────────────
    
    /// Raw URL string of the currently selected tab (if any).
    var currentURLString: String? {
        guard let focusedId = focusedTabId,
              let tab = tabs.first(where: { $0.id == focusedId }),
              let currentWebPage = tab.currentWebPage
        else {
            return nil
        }
        return currentWebPage.url.absoluteString
    }
    
    /// Extracts just the domain (e.g. "apple.com") from the current URL.
    var currentDomain: String? {
        guard let urlString = currentURLString else {
            return nil
        }
        // Ensure there’s a scheme so URL() parsing works
        let formatted = urlString.hasPrefix("http://") || urlString.hasPrefix("https://")
            ? urlString
            : "https://\(urlString)"
        
        guard let url = URL(string: formatted),
              let host = url.host
        else {
            return urlString
        }
        
        // Strip "www." if present
        return host.replacingOccurrences(of: "www.", with: "")
    }
    
    var currentTab: TabModel? {
        guard let focusedTabId else { return nil }
        return tabs.first(where: { $0.id == focusedTabId })
    }
}
