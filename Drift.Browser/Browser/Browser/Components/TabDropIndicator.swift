//
//  TabDropIndicator.swift
//  Drift
//
//  Created by Tom Alderson on 05/06/2025.
//

import SwiftUI

struct TabDropIndicator: View {
    let targetID: TabDropTargetID
    @Binding var dragOverTarget: TabDropTargetID?
    let tab: TabModel?
    let tabManager: TabManager
    
    var body: some View {
        HStack(spacing: .zero) {
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 6, height: 6)

            Rectangle()
                .fill(Color.white)
                .frame(height: 2)
        }
        .opacity(dragOverTarget == targetID ? 1 : 0)
        .onDrop(of: [.text], delegate: delegateForTarget())
        .onHover { hovering in
            if !hovering && dragOverTarget == targetID {
                dragOverTarget = nil
            }
        }
    }
    
    private func delegateForTarget() -> DropDelegate {
            switch targetID.zone {
            case .pinned:
                return PinnedTabDropIndicatorDelegate(
                    tab: tab,
                    tabManager: tabManager,
                    targetID: targetID,
                    dragOverTarget: $dragOverTarget,
                )
            case .standard:
                return StandardTabDropIndicatorDelegate(
                    tab: tab,
                    tabManager: tabManager,
                    targetID: targetID,
                    dragOverTarget: $dragOverTarget,
                )
            case .folder(_):
                return PinnedTabDropIndicatorDelegate(
                    tab: tab,
                    tabManager: tabManager,
                    targetID: targetID,
                    dragOverTarget: $dragOverTarget,
                )
//                return FolderTabDropIndicatorDelegate(
//                    targetID: targetID,
//                    folderId: folderId,
//                    dragOverTarget: $dragOverTarget,
//                    ...
//                )
            }
        }
}

#Preview {
    let mockTabManager = TabManager()
    
    TabDropIndicator(targetID: TabDropTargetID(zone: .standard, index: 0), dragOverTarget: Binding<TabDropTargetID?>(
        get: { TabDropTargetID(zone: .standard, index: 0) },
        set: { _ in }
    ), tab: TabModel(url: URL(string: "https://google.com")!), tabManager: mockTabManager)
}
