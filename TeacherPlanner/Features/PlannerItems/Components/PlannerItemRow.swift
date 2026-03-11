//
//  PlannerItemRow.swift
//  TeacherPlanner
//

import SwiftUI

/// Planner item satırı
struct PlannerItemRow: View {
    let item: PlannerItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Tamamlanma checkbox
            Button(action: onToggle) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.completed ? .green : .secondary)
            }
            .buttonStyle(.plain)

            // İçerik
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: item.type.systemImage)
                        .foregroundStyle(.secondary)
                        .font(.caption)

                    Text(item.title)
                        .font(.body)
                        .strikethrough(item.completed)

                    Spacer()

                    priorityBadge
                }

                if let details = item.details {
                    Text(details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    if let course = item.course {
                        Label(course.title, systemImage: "book.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if let dueDate = item.dueDate {
                        Text(dueDate, style: .date)
                            .font(.caption2)
                            .foregroundStyle(item.isOverdue ? .red : .secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(item.completed ? 0.6 : 1.0)
    }

    @ViewBuilder
    private var priorityBadge: some View {
        switch item.priority {
        case .high:
            PriorityBadge(label: Priority.high.badgeLabel, color: .red)
        case .medium:
            PriorityBadge(label: Priority.medium.badgeLabel, color: .orange)
        case .low:
            EmptyView()
        }
    }
}

// MARK: - PriorityBadge

private struct PriorityBadge: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

// MARK: - Preview

#Preview {
    List {
        PlannerItemRow(
            item: PlannerItem(
                title: "Deney föyü hazırla",
                details: "Asit-baz deneyi için malzemeleri kontrol et",
                type: .task,
                dueDate: Date(),
                priority: .high
            ),
            onToggle: {}
        )

        PlannerItemRow(
            item: PlannerItem(
                title: "Zümre toplantısı",
                type: .reminder,
                priority: .medium
            ),
            onToggle: {}
        )

        PlannerItemRow(
            item: PlannerItem(
                title: "Tamamlanmış görev",
                type: .homework,
                priority: .low,
                completed: true
            ),
            onToggle: {}
        )
    }
}
