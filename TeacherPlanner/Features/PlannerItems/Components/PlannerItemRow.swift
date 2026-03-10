//
//  PlannerItemRow.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
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

                    // Öncelik badge
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
        case 1:
            Text("Y")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 4)
                .background(Color.red.opacity(0.2))
                .foregroundStyle(.red)
                .cornerRadius(2)
        case 2:
            Text("O")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 4)
                .background(Color.orange.opacity(0.2))
                .foregroundStyle(.orange)
                .cornerRadius(2)
        default:
            EmptyView()
        }
    }
}

#Preview {
    List {
        PlannerItemRow(
            item: PlannerItem(
                title: "Deney föyü hazırla",
                details: "Asit-baz deneyi için malzemeleri kontrol et",
                type: .task,
                dueDate: Date(),
                priority: 1
            ),
            onToggle: {}
        )

        PlannerItemRow(
            item: PlannerItem(
                title: "Zümre toplantısı",
                type: .reminder,
                priority: 2
            ),
            onToggle: {}
        )

        PlannerItemRow(
            item: PlannerItem(
                title: "Tamamlanmış görev",
                type: .homework,
                priority: 3,
                completed: true
            ),
            onToggle: {}
        )
    }
}
