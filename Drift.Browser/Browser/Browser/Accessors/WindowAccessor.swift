//
//  WindowAccessor.swift
//  Drift
//
//  Created by Tom Alderson on 24/07/2025.
//


import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    var onWindowFound: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                onWindowFound(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}