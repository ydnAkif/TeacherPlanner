//
//  DesignSystem.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 11.03.2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// TeacherPlanner Design System
/// Merkezi renk, spacing, typography ve radius tanımları
enum DesignSystem {
    
    // MARK: - Colors
    
    enum Colors {
        // Primary colors
        static let primary = SwiftUI.Color.blue
        static let secondary = SwiftUI.Color.gray
        static let accent = SwiftUI.Color.orange
        
        // Semantic colors
        static let success = SwiftUI.Color.green
        static let error = SwiftUI.Color.red
        static let warning = SwiftUI.Color.orange
        static let info = SwiftUI.Color.blue
        
        // Background colors
        static let background: SwiftUI.Color = {
            #if canImport(UIKit)
            return SwiftUI.Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
            return SwiftUI.Color(nsColor: .windowBackgroundColor)
            #else
            return .white
            #endif
        }()
        
        static let cardBackground: SwiftUI.Color = {
            #if canImport(UIKit)
            return SwiftUI.Color(uiColor: .secondarySystemBackground)
            #elseif canImport(AppKit)
            return SwiftUI.Color(nsColor: .controlBackgroundColor)
            #else
            return .gray.opacity(0.1)
            #endif
        }()
        
        static let groupedBackground: SwiftUI.Color = {
            #if canImport(UIKit)
            return SwiftUI.Color(uiColor: .systemGroupedBackground)
            #elseif canImport(AppKit)
            return SwiftUI.Color(nsColor: .underPageBackgroundColor)
            #else
            return .gray.opacity(0.05)
            #endif
        }()
        
        // Text colors
        static let primaryText: SwiftUI.Color = {
            #if canImport(UIKit)
            return SwiftUI.Color(uiColor: .label)
            #elseif canImport(AppKit)
            return SwiftUI.Color(nsColor: .labelColor)
            #else
            return .black
            #endif
        }()
        
        static let secondaryText: SwiftUI.Color = {
            #if canImport(UIKit)
            return SwiftUI.Color(uiColor: .secondaryLabel)
            #elseif canImport(AppKit)
            return SwiftUI.Color(nsColor: .secondaryLabelColor)
            #else
            return .gray
            #endif
        }()
        
        static let tertiaryText: SwiftUI.Color = {
            #if canImport(UIKit)
            return SwiftUI.Color(uiColor: .tertiaryLabel)
            #elseif canImport(AppKit)
            return SwiftUI.Color(nsColor: .tertiaryLabelColor)
            #else
            return .gray.opacity(0.5)
            #endif
        }()
        
        // Border colors
        static let border: SwiftUI.Color = {
            #if canImport(UIKit)
            return SwiftUI.Color(uiColor: .separator)
            #elseif canImport(AppKit)
            return SwiftUI.Color(nsColor: .separatorColor)
            #else
            return .gray.opacity(0.2)
            #endif
        }()
        
        static let divider: SwiftUI.Color = border.opacity(0.5)
        
        // Course colors (for random assignment)
        static let courseColors: [String] = [
            "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
            "#007AFF", "#5856D6", "#AF52DE", "#FF2D55", "#8E8E93",
        ]
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        // Base spacing values (8pt grid system)
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
        
        // Padding presets
        static let cardPadding = EdgeInsets(top: medium, leading: medium, bottom: medium, trailing: medium)
        static let sectionPadding = EdgeInsets(top: large, leading: medium, bottom: large, trailing: medium)
        static let pagePadding = EdgeInsets(top: medium, leading: medium, bottom: medium, trailing: medium)
    }
    
    // MARK: - Radius
    
    enum Radius {
        static let none: CGFloat = 0
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xLarge: CGFloat = 16
        static let xxLarge: CGFloat = 20
        static let full: CGFloat = 999
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Font styles
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
        
        // Font weights
        enum Weight {
            case regular
            case medium
            case semibold
            case bold
            
            var swiftFontWeight: Font.Weight {
                switch self {
                case .regular: return .regular
                case .medium: return .medium
                case .semibold: return .semibold
                case .bold: return .bold
                }
            }
        }
        
        // Font factory method
        static func font(_ style: Style, weight: Weight = .regular) -> Font {
            switch style {
            case .largeTitle: return .largeTitle.weight(weight.swiftFontWeight)
            case .title: return .title.weight(weight.swiftFontWeight)
            case .title2: return .title2.weight(weight.swiftFontWeight)
            case .title3: return .title3.weight(weight.swiftFontWeight)
            case .headline: return .headline.weight(weight.swiftFontWeight)
            case .subheadline: return .subheadline.weight(weight.swiftFontWeight)
            case .body: return .body.weight(weight.swiftFontWeight)
            case .callout: return .callout.weight(weight.swiftFontWeight)
            case .footnote: return .footnote.weight(weight.swiftFontWeight)
            case .caption: return .caption.weight(weight.swiftFontWeight)
            case .caption2: return .caption2.weight(weight.swiftFontWeight)
            }
        }
        
        // Preset styles
        static let largeTitle = font(.largeTitle, weight: .bold)
        static let title = font(.title, weight: .semibold)
        static let title2 = font(.title2, weight: .semibold)
        static let title3 = font(.title3, weight: .semibold)
        static let headline = font(.headline, weight: .semibold)
        static let subheadline = font(.subheadline, weight: .regular)
        static let body = font(.body, weight: .regular)
        static let callout = font(.callout, weight: .regular)
        static let footnote = font(.footnote, weight: .regular)
        static let caption = font(.caption, weight: .regular)
        static let caption2 = font(.caption2, weight: .medium)
        
        // Component presets
        static let cardTitle = font(.title3, weight: .semibold)
        static let cardBody = font(.body, weight: .regular)
        static let cardCaption = font(.caption, weight: .regular)
        
        static let listTitle = font(.body, weight: .medium)
        static let listSubtitle = font(.subheadline, weight: .regular)
        static let listCaption = font(.caption, weight: .regular)
        
        static let buttonLabel = font(.body, weight: .semibold)
        static let buttonSmall = font(.caption, weight: .medium)
    }
    
    // MARK: - Shadows
    // Intentionally omitted: SwiftUI does not expose a standalone Shadow type.
}

// MARK: - View Extensions

extension View {
    /// Apply card style
    func cardStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.cardPadding)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.large))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
