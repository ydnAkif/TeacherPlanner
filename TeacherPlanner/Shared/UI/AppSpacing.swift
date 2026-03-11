// AppSpacing.swift
// DesignSystem.Spacing + Radius'ın alias'ı — doğrudan DesignSystem kullanın.
import SwiftUI

enum AppSpacing {
    static let none: CGFloat      = DesignSystem.Spacing.none
    static let xxxSmall: CGFloat  = DesignSystem.Spacing.xxxSmall
    static let xxSmall: CGFloat   = DesignSystem.Spacing.xxSmall
    static let xSmall: CGFloat    = DesignSystem.Spacing.xSmall
    static let small: CGFloat     = DesignSystem.Spacing.small
    static let medium: CGFloat    = DesignSystem.Spacing.medium
    static let large: CGFloat     = DesignSystem.Spacing.large
    static let xLarge: CGFloat    = DesignSystem.Spacing.xLarge
    static let xxLarge: CGFloat   = DesignSystem.Spacing.xxLarge
    static let xxxLarge: CGFloat  = DesignSystem.Spacing.xxxLarge

    static let cardPadding        = DesignSystem.Spacing.cardPadding
    static let sectionPadding     = DesignSystem.Spacing.sectionPadding
    static let pagePadding        = DesignSystem.Spacing.pagePadding

    static let cornerRadiusSmall: CGFloat  = DesignSystem.Radius.small
    static let cornerRadiusMedium: CGFloat = DesignSystem.Radius.medium
    static let cornerRadiusLarge: CGFloat  = DesignSystem.Radius.large
    static let cornerRadiusXLarge: CGFloat = DesignSystem.Radius.xLarge
}

extension View {
    func sectionPadding() -> some View { self.padding(AppSpacing.sectionPadding) }
    func cardPadding() -> some View    { self.padding(AppSpacing.cardPadding) }
    func pagePadding() -> some View    { self.padding(AppSpacing.pagePadding) }
}
