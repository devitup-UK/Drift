//
//  TabLauncherComponent.swift
//  Drift
//
//  Created by Tom Alderson on 04/06/2025.
//


import SwiftUI

struct TabLauncherComponent: View {
    @Environment(TabManager.self) private var tabManager
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    tabManager.isTabLauncherVisible = false
                }

            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.secondary)
                    
                    TextField("Search or Enter URL...", text: $inputText, onCommit: {
                        submit()
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                    .disableAutocorrection(true)
                    .focused($isInputFocused) // 👈 Focus binding here
                }
                .padding(20)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(hexColor("#1A1918"))

                        // Inset inner edge highlight (optional)
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.6), lineWidth: 3)
                        
                        // Outer faint border
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.06), lineWidth: 2)
                    }
                )
                .cornerRadius(16)
                .frame(width: 760)
                .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 10)
            }
            .shadow(radius: 30)
            .onAppear {
                inputText = tabManager.launcherInitialText ?? "" // 👈 Pre-fill text
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isInputFocused = true // 👈 Set focus when presented
                }
            }
            .offset(y: -100)
        }
    }

    func submit() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        let url = resolveURL(from: trimmed)

        if tabManager.launcherInitialText == nil {
            tabManager.createNewTab(url: url)
        } else {
            if let currentTab = tabManager.currentTab {
                if let currentTabWebView = tabManager.webViewManager.webView(for: currentTab.id) {
                    currentTabWebView.load(URLRequest(url: url.canonicalYouTube
                                                     ))
                }
                
            }
        }

        // Cleanup
        tabManager.launcherInitialText = nil
        tabManager.isTabLauncherVisible = false
    }
    
    func resolveURL(from input: String) -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains(" ") || !trimmed.contains(".") {
            let query = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
            return URL(string: "https://www.google.com/search?q=\(query)")!
        } else if !trimmed.hasPrefix("http") {
            return URL(string: "https://\(trimmed)")!
        } else {
            return URL(string: trimmed)!
        }
    }
}

#Preview {
    let mockTabManager = TabManager()
    
    TabLauncherComponent()
        .environment(mockTabManager)
}
