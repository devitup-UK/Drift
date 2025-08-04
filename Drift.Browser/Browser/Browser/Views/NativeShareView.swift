//
//  NativeShareView.swift
//  Drift
//
//  Created by Tom Alderson on 11/06/2025.
//


import SwiftUI
import AppKit

struct NativeShareView: NSViewRepresentable {
    let items: [Any]

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)

        DispatchQueue.main.async {
            let picker = NSSharingServicePicker(items: items)
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
