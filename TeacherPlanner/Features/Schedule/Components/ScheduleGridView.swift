//
//  ScheduleGridView.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftUI

struct ScheduleGridView: View {
    let data: WeeklyViewData
    let onCellTap: (WeeklyCell, PeriodDefinition) -> Void
    let onDeleteSession: (ClassSession) -> Void
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                ScheduleHeaderRow(weekdays: data.weekdays)
                
                ForEach(data.rows.indices, id: \.self) { index in
                    let row = data.rows[index]
                    ScheduleRowView(
                        row: row,
                        onCellTap: { cell in
                            onCellTap(cell, row.period)
                        },
                        onDeleteSession: onDeleteSession
                    )
                    
                    if index < data.rows.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }
}
