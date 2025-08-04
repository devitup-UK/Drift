//
//  KeyPressModifier.swift
//  Drift
//
//  Created by Tom Alderson on 04/06/2025.
//


import SwiftUI
import AppKit

struct KeyPressModifier: ViewModifier {
    let keyDown: (NSEvent) -> Void

    func body(content: Content) -> some View {
        content
            .background(KeyPressView(keyDown: keyDown))
    }

    private struct KeyPressView: NSViewRepresentable {
        let keyDown: (NSEvent) -> Void

        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 {
                    keyDown(event)
                    return nil
                }
                return event
            }
            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {}
    }
}
