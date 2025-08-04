//
//  SidebarFooterComponentView.swift
//  Drift
//
//  Created by Tom Alderson on 06/06/2025.
//

import SwiftUI

struct SidebarFooterComponentView: View {

    @Environment(TabManager.self) private var tabManager
    @State private var isHoveringOverNewTabButton = false
    @State private var isHoveringOverDownloadsButton = false
    
    var body: some View {
        
        HStack(alignment: .center) {
            Image(systemName: "square.and.arrow.down.fill")
                .resizable()
                .frame(width: 16, height: 16)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHoveringOverDownloadsButton ? Color.white.opacity(0.1) : Color.clear)
                        .padding(-8)
                }
                .onTapGesture {
                    // Open the downloads explorer.
                }
                .onHover{ hovering in
                    isHoveringOverDownloadsButton = hovering
                }
            
            Spacer()
            
            Image(systemName: "plus")
                .resizable()
                .frame(width: 16, height: 16)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHoveringOverNewTabButton ? Color.white.opacity(0.1) : Color.clear)
                        .padding(-8)
                }
                .keyboardShortcut("t", modifiers: [.command])
                .onTapGesture {
                    tabManager.launcherInitialText = nil
                    tabManager.showTabLauncher()
                }
                .onHover{ hovering in
                    isHoveringOverNewTabButton = hovering
                }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 10)
    }
}

#Preview {
    var mockTabManager = TabManager()
    
    SidebarFooterComponentView()
        .environment(mockTabManager)
}
