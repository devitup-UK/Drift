//
//  BrowserApp.swift
//  Browser
//
//  Created by Tom Alderson on 04/06/2025.
//

import SwiftUI
import SwiftData

@main
struct BrowserApp: App {
    @State private var tabManager = TabManager()
    @State private var displayManager = DisplayManager()

    var body: some Scene {
        WindowGroup("Browser") {
            ContentView()
                .environment(tabManager)
                .environment(displayManager)
                .task {
                    if(tabManager.tabs.isEmpty) {
                        tabManager.loadTabs()
                    }
//                    repositionTrafficLights()
                }
                .ignoresSafeArea(.container, edges: .top)
//                // Embed in a background NSViewGetter to hook into the window
//                .background(WindowAccessor { window in
//                    repositionTrafficLights(window: window)
//                })
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Tab") {
                    tabManager.launcherInitialText = nil
                    tabManager.showTabLauncher()
                }
                .keyboardShortcut("t", modifiers: [.command])
            }
        }
        .windowStyle(.hiddenTitleBar)
    }

    func repositionTrafficLights(window: NSWindow? = nil) {
        guard let window = window ?? NSApplication.shared.windows.first else { return }

        // Insert full size content view
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)

        if let closeButton = window.standardWindowButton(.closeButton),
           let miniButton = window.standardWindowButton(.miniaturizeButton),
           let zoomButton = window.standardWindowButton(.zoomButton) {

            let xOffset: CGFloat = 10
            let yOffset: CGFloat = 100
            let topInset = window.contentView?.superview?.frame.height ?? window.frame.height

            closeButton.setFrameOrigin(NSPoint(x: xOffset, y: topInset - yOffset - closeButton.frame.height))
            miniButton.setFrameOrigin(NSPoint(x: xOffset + 20, y: topInset - yOffset - miniButton.frame.height))
            zoomButton.setFrameOrigin(NSPoint(x: xOffset + 40, y: topInset - yOffset - zoomButton.frame.height))
        }
    }
}

// This helper injects access to NSWindow from SwiftUI
//struct WindowAccessor: NSViewRepresentable {
//    let callback: (NSWindow?) -> Void
//
//    func makeNSView(context: Context) -> NSView {
//        let view = NSView()
//
//        DispatchQueue.main.async {
//            if let window = view.window {
//                NotificationCenter.default.addObserver(
//                    forName: NSWindow.didBecomeKeyNotification,
//                    object: window,
//                    queue: .main
//                ) { _ in
//                    self.callback(window)
//                }
//            }
//        }
//
//        return view
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {}
//}

