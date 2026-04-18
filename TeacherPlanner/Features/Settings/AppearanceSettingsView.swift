//
//  AppearanceSettingsView.swift
//  TeacherPlanner
//

import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(Constants.UI.Keys.appearanceMode) private var appearanceMode: Int = 0

    var body: some View {
        List {
            Section {
                ForEach(AppearanceOption.allCases) { option in
                    AppearanceOptionRow(
                        option: option,
                        isSelected: appearanceMode == option.rawValue
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appearanceMode = option.rawValue
                        }
                    }
                }
            } header: {
                Text("Tema")
            } footer: {
                Text(selectedOption.footerDescription)
            }

            Section {
                HStack(spacing: 12) {
                    ForEach(AppearanceOption.allCases) { option in
                        ThemePreviewCard(
                            option: option, isSelected: appearanceMode == option.rawValue
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                appearanceMode = option.rawValue
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            } header: {
                Text("Önizleme")
            }
        }
        .navigationTitle("Görünüm")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(resolvedColorScheme)
    }

    // MARK: - Helpers

    private var selectedOption: AppearanceOption {
        AppearanceOption(rawValue: appearanceMode) ?? .system
    }

    private var resolvedColorScheme: ColorScheme? {
        switch appearanceMode {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
}

// MARK: - Appearance Option

enum AppearanceOption: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .system: return "Sistem"
        case .light: return "Açık"
        case .dark: return "Koyu"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .system: return .blue
        case .light: return .orange
        case .dark: return .indigo
        }
    }

    var footerDescription: String {
        switch self {
        case .system:
            return "Tema, cihazınızın sistem ayarlarına göre otomatik olarak değişir."
        case .light:
            return "Uygulama her zaman açık temada görüntülenir."
        case .dark:
            return "Uygulama her zaman koyu temada görüntülenir."
        }
    }
}

// MARK: - Appearance Option Row

private struct AppearanceOptionRow: View {
    let option: AppearanceOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: option.icon)
                    .font(.body)
                    .foregroundStyle(option.iconColor)
                    .frame(width: 28)

                Text(option.title)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Theme Preview Card

private struct ThemePreviewCard: View {
    let option: AppearanceOption
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackground)
                    .shadow(
                        color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.08),
                        radius: isSelected ? 6 : 3,
                        y: 2
                    )

                VStack(spacing: 6) {
                    // Mock nav bar
                    HStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(mockTextColor.opacity(0.5))
                            .frame(width: 40, height: 6)
                        Spacer()
                        Circle()
                            .fill(mockTextColor.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)

                    // Mock content rows
                    ForEach(0..<3, id: \.self) { i in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(mockAccentColor.opacity(0.7))
                                .frame(width: 8, height: 8)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(mockTextColor.opacity(0.4 - Double(i) * 0.08))
                                .frame(height: 5)
                        }
                        .padding(.horizontal, 10)
                    }

                    Spacer()

                    // Mock tab bar
                    HStack {
                        ForEach(0..<4, id: \.self) { i in
                            Spacer()
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i == 0 ? mockAccentColor : mockTextColor.opacity(0.25))
                                .frame(width: 12, height: i == 0 ? 12 : 8)
                            Spacer()
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .frame(height: 120)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.blue, lineWidth: 2)
                }
            }

            Text(option.title)
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .blue : .secondary)
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Colors per theme

    private var cardBackground: Color {
        switch option {
        case .system: return Color(uiColor: .systemBackground)
        case .light: return .white
        case .dark: return Color(red: 0.11, green: 0.11, blue: 0.12)
        }
    }

    private var mockTextColor: Color {
        switch option {
        case .system: return Color(uiColor: .label)
        case .light: return .black
        case .dark: return .white
        }
    }

    private var mockAccentColor: Color {
        .blue
    }
}

// MARK: - Preview

#Preview("System") {
    NavigationStack {
        AppearanceSettingsView()
    }
}

#Preview("Dark") {
    NavigationStack {
        AppearanceSettingsView()
    }
    .preferredColorScheme(.dark)
}
