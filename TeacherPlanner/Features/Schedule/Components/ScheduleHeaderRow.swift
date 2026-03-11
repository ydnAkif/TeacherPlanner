//
//  ScheduleHeaderRow.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftUI

struct ScheduleHeaderRow: View {
    let weekdays: [Int]
    
    var body: some View {
        HStack(spacing: 0) {
            Text("Period")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 80)
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
            
            ForEach(weekdays, id: \.self) { weekday in
                Text(Weekday.fromCalendarWeekday(weekday)?.shortName ?? "")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppColors.cardBackground)
            }
        }
    }
}
