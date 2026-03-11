//
//  Color+Hex.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

extension Color {
    /// Hex string'den Color oluştur
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    /// Color'dan hex string'e çevir
    var hexString: String? {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else { return nil }
        #elseif canImport(AppKit)
        let nsColor = NSColor(self)
        guard let components = nsColor.cgColor.components else { return nil }
        #else
        return nil
        #endif

        let r = components.count >= 1 ? components[0] : 0
        let g = components.count >= 2 ? components[1] : 0
        let b = components.count >= 3 ? components[2] : 0
        let a = components.count >= 4 ? components[3] : 1

        // Alpha 1 değilse, rgba formatında döndür
        if a < 1.0 {
            return String(
                format: "%02lX%02lX%02lX%02lX",
                lround(Double(r) * 255),
                lround(Double(g) * 255),
                lround(Double(b) * 255),
                lround(Double(a) * 255))
        }

        return String(
            format: "%02lX%02lX%02lX",
            lround(Double(r) * 255),
            lround(Double(g) * 255),
            lround(Double(b) * 255))
    }
}
