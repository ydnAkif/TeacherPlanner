//
//  AppTypography.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

/// Typography token'ları
enum AppTypography {
    // MARK: - Font Styles

    enum Style {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption
        case caption2
    }

    // MARK: - Font Weights

    enum Weight {
        case regular
        case medium
        case semibold
        case bold
    }

    // MARK: - Font Methods

    static func font(_ style: Style, weight: Weight = .regular) -> Font {
        switch style {
        case .largeTitle:
            return .largeTitle.weight(weight.swiftFontWeight)
        case .title:
            return .title.weight(weight.swiftFontWeight)
        case .title2:
            return .title2.weight(weight.swiftFontWeight)
        case .title3:
            return .title3.weight(weight.swiftFontWeight)
        case .headline:
            return .headline.weight(weight.swiftFontWeight)
        case .subheadline:
            return .subheadline.weight(weight.swiftFontWeight)
        case .body:
            return .body.weight(weight.swiftFontWeight)
        case .callout:
            return .callout.weight(weight.swiftFontWeight)
        case .footnote:
            return .footnote.weight(weight.swiftFontWeight)
        case .caption:
            return .caption.weight(weight.swiftFontWeight)
        case .caption2:
            return .caption2.weight(weight.swiftFontWeight)
        }
    }

    // MARK: - Preset Styles

    static let cardTitle = font(.title3, weight: .semibold)
    static let cardBody = font(.body, weight: .regular)
    static let cardCaption = font(.caption, weight: .regular)

    static let listTitle = font(.body, weight: .medium)
    static let listSubtitle = font(.subheadline, weight: .regular)
    static let listCaption = font(.caption, weight: .regular)

    static let buttonLabel = font(.body, weight: .semibold)
    static let buttonSmall = font(.caption, weight: .medium)
}

// MARK: - Helper Extension

extension AppTypography.Weight {
    var swiftFontWeight: Font.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }
}
