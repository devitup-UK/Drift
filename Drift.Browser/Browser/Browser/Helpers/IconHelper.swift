//
//  IconHelper 2.swift
//  Drift
//
//  Created by Tom Alderson on 04/06/2025.
//


import AppKit

struct IconHelper {
    static func nsImageFromSFSymbol(named symbolName: String, pointSize: CGFloat = 16, weight: NSFont.Weight = .regular) -> NSImage? {
        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
    }
}
