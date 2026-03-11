//
//  ScheduleRowView.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftUI

struct ScheduleRowView: View {
    let row: WeeklyRow
    let onCellTap: (WeeklyCell) -> Void
    let onDeleteSession: (ClassSession) -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.period.title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("\(row.period.startTimeString)-\(row.period.endTimeString)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            ForEach(row.cells.indices, id: \.self) { index in
                let cell = row.cells[index]
                ScheduleCellView(
                    cell: cell,
                    onTap: {
                        onCellTap(cell)
                    },
                    onDelete: {
                        if let session = cell.session {
                            onDeleteSession(session)
                        }
                    }
                )
                .frame(maxWidth: .infinity)

                if index < row.cells.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.vertical, 4)
    }
}
