//
//  AddressBarComponentView.swift
//  Drift
//
//  Created by Tom Alderson on 05/06/2025.
//

import SwiftUI

struct AddressBarComponentView: View {
    @Environment(TabManager.self) private var tabManager

    @State private var isHoveringOverAddressBar = false
    @State private var isHoveringOverCopyButton = false
    @State private var didCopy = false
    @State private var iconScale: CGFloat = 1.0

    
    var body: some View {
            
        HStack(alignment: .center, spacing: .zero) {
            
            if(tabManager.focusedTabId == nil) {
                Image(systemName: "magnifyingglass")
            }
            
            Text(tabManager.currentDomain ?? "Search or Enter URL...")
                .font(.system(size: 14))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.leading, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .cornerRadius(8)
            
            // Example of buttons at the end of the bar.
            if(isHoveringOverAddressBar && tabManager.focusedTabId != nil) {
                Image(systemName: didCopy ? "checkmark" : "link")
                    .frame(width: 16, height: 16)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isHoveringOverCopyButton ? Color.white.opacity(0.1) : Color.clear)
                            .padding(-4)
                    }
                    .scaleEffect(iconScale)
                    .animation(.easeInOut(duration: 0.2), value: iconScale)
                    .onHover { hovering in
                        isHoveringOverCopyButton = hovering
                    }
                    .onTapGesture {
                        if let focusedTabWebview = tabManager.webViewManager.webView(for: tabManager.focusedTabId!) {
                            guard let urlString = focusedTabWebview.url?.absoluteString else { return }
                            
                            
                            
                            // 📋 Copy to clipboard
                            let pb = NSPasteboard.general
                            pb.clearContents()
                            pb.setString(urlString, forType: .string)
                            
                            // 🔽 Shrink icon
                            withAnimation(.spring(response: 0.2, dampingFraction: 1.0)) {
                                iconScale = 0.7
                            }
                            
                            // 🔼 Grow with "checkmark"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                didCopy = true
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    iconScale = 1.2
                                }
                                
                                // 🔁 Reset back after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.spring()) {
                                        didCopy = false
                                        iconScale = 1.0
                                    }
                                }
                            }
                        }
                    }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(determineTabBackgroundColor(hovered: isHoveringOverAddressBar))
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHoveringOverAddressBar = hovering
            }
        }
        
    }
    
    func determineTabBackgroundColor(hovered: Bool) -> Color {
        if(hovered) {
            return Color.white.opacity(0.15);
        }
        
        return Color.white.opacity(0.1);
    }
}

#Preview {
    var mockTabManager1 = TabManager()
    mockTabManager1.focusedTabId = nil
    
    var mockTabManager2 = TabManager()
    
    return VStack {
        // No focused tab.
        AddressBarComponentView()
            .environment(mockTabManager1)
        
        // Focused Tab
        AddressBarComponentView()
            .environment(mockTabManager2)
    }
    


    
    
}
