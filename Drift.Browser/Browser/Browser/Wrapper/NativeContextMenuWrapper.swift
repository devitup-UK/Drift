//
//  NativeContextMenuWrapper.swift
//  Drift
//
//  Created by Tom Alderson on 11/06/2025.
//


import SwiftUI
import AppKit

struct NativeContextMenuWrapper<Content: View>: NSViewRepresentable {
    var tabManager: TabManager
    var tab: TabModel
    var content: () -> Content

    func makeNSView(context: Context) -> NSHostingView<Content> {
        let view = CustomContextMenuView(tabManager: tabManager, tab: tab, rootView: content())
        return view
    }

    func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
        nsView.rootView = content()
    }
}
