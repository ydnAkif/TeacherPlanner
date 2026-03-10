//
//  AppSpacing.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

/// Spacing token'ları (8pt grid system)
enum AppSpacing {
    // MARK: - Spacing Values (points)

    static let none: CGFloat = 0
    static let xxxSmall: CGFloat = 2
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 6
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
    static let xxLarge: CGFloat = 48
    static let xxxLarge: CGFloat = 64

    // MARK: - Padding Presets

    static let cardPadding = EdgeInsets(
        top: medium,
        leading: medium,
        bottom: medium,
        trailing: medium
    )

    static let sectionPadding = EdgeInsets(
        top: large,
        leading: medium,
        bottom: large,
        trailing: medium
    )

    static let pagePadding = EdgeInsets(
        top: medium,
        leading: medium,
        bottom: medium,
        trailing: medium
    )

    // MARK: - Corner Radius

    static let cornerRadiusSmall: CGFloat = 4
    static let cornerRadiusMedium: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 12
    static let cornerRadiusXLarge: CGFloat = 16

    // MARK: - View Extensions

    static func padding(_ level: CGFloat) -> EdgeInsets {
        EdgeInsets(top: level, leading: level, bottom: level, trailing: level)
    }
}

// MARK: - View Extensions

extension View {
    func sectionPadding() -> some View {
        self.padding(AppSpacing.sectionPadding)
    }

    func cardPadding() -> some View {
        self.padding(AppSpacing.cardPadding)
    }

    func pagePadding() -> some View {
        self.padding(AppSpacing.pagePadding)
    }
}
