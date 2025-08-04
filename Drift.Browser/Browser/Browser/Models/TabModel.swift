//
//  TabModel.swift
//  Drift
//
//  Created by Tom Alderson on 04/06/2025.
//

import Foundation
import WebKit

@Observable
class TabModel: Identifiable, Equatable, Hashable  {
    var id: UUID
    var titleOverride: String = "" // Optional custom name
    var unloaded: Bool = false // This will dictate if a pinned tab is open or not, if it is unloaded then we won't load it's webview.
    var tabType: TabTypeEnum = .standard // Dictates if the tab is a standard one, a pinned one or a folder.
    var folderId: UUID?
    var folderOpen: Bool = false
    var folderIndex: Int?
    var isRenaming: Bool = false
    var pinnedIndex: Int?
    var standardIndex: Int?
    var history: [TabWebPageModel] = []
    var historyIndex: Int = -1
    
    static func == (lhs: TabModel, rhs: TabModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func addToHistory(_ url: URL, firstLoad: Bool = false) {
        let webPage = TabWebPageModel(timestamp: Date(), url: url)
        if let currentHistoryWebPage = currentWebPage {
            if(currentHistoryWebPage.url.absoluteString != webPage.url.absoluteString) {
                history.append(webPage)
                historyIndex += 1
            }
        }
        
        if(firstLoad) {
            history.append(webPage)
            historyIndex += 1
        }
    }
    
    func updateCurrentPage(_ update: (inout TabWebPageModel) -> Void) {
        guard history.indices.contains(historyIndex) else { return }
        update(&history[historyIndex])
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func setTitle(title: String) {
        updateCurrentPage { $0.title = title }
    }
    
    var currentWebPage: TabWebPageModel? {
        history.indices.contains(historyIndex) ? history[historyIndex] : nil
    }
    
    func canGoBack() -> Bool {
        historyIndex > 0
    }
    
    func canGoForward() -> Bool {
        historyIndex < history.count - 1
    }
    
    func goBack(_ webView: WKWebView) {
        historyIndex -= 1
        webView.load(URLRequest(url: history[historyIndex].url))
    }
    
    func goForward(_ webView: WKWebView) {
        historyIndex += 1
        webView.load(URLRequest(url: history[historyIndex].url))
    }
    
    func setFavicon(favicon: NSImage) {
        updateCurrentPage { $0.favicon = favicon }
    }

    
    var url: URL? {
        currentWebPage?.url
    }

    var favicon: NSImage? {
        currentWebPage?.favicon
    }

    var title: String {
        if(!titleOverride.isEmpty) {
            titleOverride
        }else{
            currentWebPage?.title ?? currentWebPage?.url.host ?? "Untitled"
        }
    }

    init(url: URL? = nil, unloaded: Bool = false, titleOverride: String = "", tabType: TabTypeEnum = .standard, folderId: UUID? = nil, folderOpen: Bool = false, folderIndex: Int? = nil, isRenaming: Bool = false, pinnedIndex: Int? = nil, standardIndex: Int? = nil, history: [TabWebPageModel] = [], historyIndex: Int = -1) {
        self.id = UUID()
        self.unloaded = unloaded
        self.titleOverride = titleOverride
        self.tabType = tabType
        self.folderId = folderId
        self.folderOpen = folderOpen
        self.folderIndex = folderIndex
        self.isRenaming = isRenaming
        self.pinnedIndex = pinnedIndex
        self.standardIndex = standardIndex
        self.history = history
        self.historyIndex = historyIndex
        if let urlToLoad = url {
            addToHistory(urlToLoad, firstLoad: true)
        }
    }
    
    func toCodable() -> CodableTabModel {
        let codedHistory: [CodableTabWebPageModel] = self.history.map({$0.toCodable()})
        
        return CodableTabModel(
            unloaded: unloaded,
            titleOverride: titleOverride,
            tabType: tabType,
            folderId: folderId,
            folderOpen: folderOpen,
            folderIndex: folderIndex,
            isRenaming: isRenaming,
            pinnedIndex: pinnedIndex,
            standardIndex: standardIndex,
            history: codedHistory,
            historyIndex: historyIndex
        )
    }

    static func fromCodable(_ codable: CodableTabModel) -> TabModel {
        let history = codable.history.map(TabWebPageModel.fromCodable)
        
        let tab = TabModel(unloaded: codable.unloaded, titleOverride: codable.titleOverride, tabType: codable.tabType, folderId: codable.folderId, folderOpen: codable.folderOpen, folderIndex: codable.folderIndex, isRenaming: codable.isRenaming, pinnedIndex: codable.pinnedIndex, standardIndex: codable.standardIndex, history: history, historyIndex: codable.historyIndex)
        tab.id = codable.id
        return tab
    }
}
