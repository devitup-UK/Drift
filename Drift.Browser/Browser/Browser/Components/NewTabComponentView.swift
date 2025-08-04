//
//  NewTabComponentView.swift
//  Drift
//
//  Created by Tom Alderson on 05/06/2025.
//

import SwiftUI

struct NewTabComponentView: View {

    @Environment(TabManager.self) private var tabManager
    @State private var isHoveringOverNewTab = false
    
    var body: some View {
            
        HStack(alignment: .center, spacing: .zero) {

            Image(systemName: "plus")
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.gray)
            
            
            Text("New Tab")
                .font(.system(size: 14))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.leading, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(8)
                .foregroundStyle(Color.gray)
            
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(determineTabBackgroundColor(hovered: isHoveringOverNewTab))
        }
        .onHover { hovering in
            isHoveringOverNewTab = hovering
        }
        
    }
    
    func determineTabBackgroundColor(hovered: Bool) -> Color {

        if(hovered) {
            return Color.white.opacity(0.1);
        }
        return Color.clear;
    }
}

#Preview {
    var mockTabManager = TabManager()
    
    NewTabComponentView()
        .environment(mockTabManager)
}
