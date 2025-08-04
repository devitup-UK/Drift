//
//  WindowState.swift
//  Drift
//
//  Created by Tom Alderson on 23/07/2025.
//


import SwiftUI
import Combine

class WindowState: ObservableObject {
    @Published var isFullScreen: Bool = false

    private var observation: NSKeyValueObservation?

    func watch(window: NSWindow) {
        observation = window.observe(\.styleMask, options: [.initial, .new]) { [weak self] win, _ in
            DispatchQueue.main.async {
                self?.isFullScreen = win.styleMask.contains(.fullScreen)
            }
        }
    }
}
