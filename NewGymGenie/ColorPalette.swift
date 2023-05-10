//
//  ColorPalette.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

import SwiftUI

extension Color {
    static let gymGeniePurple = Color(hex: "#604573")
    static let gymGenieBlue1 = Color(hex: "#6258A6")
    static let gymGenieBlue2 = Color(hex: "#4E8BBF")
    static let gymGenieBlue3 = Color(hex: "#55B3D9")
    static let gymGenieGreen = Color(hex: "#3FBFB2")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


