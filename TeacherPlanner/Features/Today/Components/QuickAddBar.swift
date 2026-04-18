//
//  QuickAddBar.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

struct QuickAddBar: View {
    var onItemAdded: (() -> Void)? = nil

    @State private var showingSheet = false
    @State private var selectedType: PlannerItemType = .task

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    // Hızlı erişim için öne çıkan tipler
    private let primaryTypes: [PlannerItemType] = [.task, .homework, .exam, .note]

    var body: some View {
        VStack(spacing: 10) {
            sectionHeader

            HStack(spacing: 10) {
                ForEach(primaryTypes, id: \.self) { type in
                    QuickAddButton(type: type) {
                        selectedType = type
                        showingSheet = true
                    }
                }
            }
            .padding(.horizontal)
        }
        .sheet(
            isPresented: $showingSheet,
            onDismiss: {
                onItemAdded?()
            }
        ) {
            EditPlannerItemView(type: selectedType, prefillDueDate: today)
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack {
            Text("Hızlı Ekle")
                .font(.headline)
            Spacer()
            // Diğer tipler için ek menü (reminder, material)
            Menu {
                ForEach(PlannerItemType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                        showingSheet = true
                    } label: {
                        Label(type.displayName, systemImage: type.systemImage)
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
                    .font(.body)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Quick Add Button

private struct QuickAddButton: View {
    let type: PlannerItemType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(type.accentColor)

                Text(type.displayName)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(type.accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(type.accentColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PlannerItemType + Accent Color

extension PlannerItemType {
    fileprivate var accentColor: Color {
        switch self {
        case .task: return .blue
        case .homework: return .purple
        case .exam: return .red
        case .note: return .orange
        case .reminder: return .teal
        case .material: return .green
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        QuickAddBar(onItemAdded: {
            print("Item added!")
        })
        .padding(.bottom)
    }
    .background(Color(.systemGroupedBackground))
    .modelContainer(try! ModelContainerFactory.createPreview())
}
