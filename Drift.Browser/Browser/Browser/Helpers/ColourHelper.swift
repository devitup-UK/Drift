//
//  ColourHelper.swift
//  Application
//
//  Created by Tom Alderson on 28/05/2025.
//

import SwiftUI

func hexColor(_ hex: String) -> Color {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexSanitized.hasPrefix("#") {
        hexSanitized.remove(at: hexSanitized.startIndex)
    }

    var rgb: UInt64 = 0
    Scanner(string: hexSanitized).scanHexInt64(&rgb)

    let red, green, blue: Double

    switch hexSanitized.count {
    case 6: // RRGGBB
        red   = Double((rgb & 0xFF0000) >> 16) / 255
        green = Double((rgb & 0x00FF00) >> 8) / 255
        blue  = Double(rgb & 0x0000FF) / 255
        return Color(red: red, green: green, blue: blue)
        
    default:
        return Color.gray // fallback color
    }
}
