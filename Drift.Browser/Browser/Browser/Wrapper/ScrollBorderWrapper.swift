//
//  ScrollBorderWrapper.swift
//  Drift
//
//  Created by Tom Alderson on 12/06/2025.
//

import SwiftUI

struct ScrollBorderWrapper<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { outsideGeo in
                ScrollView {
                    VStack(spacing: 0) {
                        content()
                            .background(
                                GeometryReader { contentGeo in
                                    Color.clear
                                        .onAppear {
                                            contentHeight = contentGeo.size.height
                                        }
                                        .onChange(of: contentGeo.size.height) {
                                            contentHeight = contentGeo.size.height
                                        }
                                }
                            )
                    }
                }
                .background(
                    GeometryReader { scrollGeo in
                        Color.clear
                            .onAppear {
                                viewportHeight = scrollGeo.size.height
                            }
                            .onChange(of: scrollGeo.size.height) {
                                viewportHeight = scrollGeo.size.height
                            }
                    }
                )
                .overlay(
                    VStack(spacing: 0) {
                        if contentHeight > viewportHeight {
                            Divider() // Top border
                                .zIndex(10)
                        }
                        Spacer()
                        if contentHeight > viewportHeight {
                            Divider() // Bottom border
                                .zIndex(10)
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    VStack {
        ScrollBorderWrapper {
            VStack {
                ForEach(0..<50) { i in
                    Text("Item \(i)")
                        .padding()
                }
            }
        }
    }
    .padding(20)
    


}
