//
//  TodayClassesSection.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftUI

struct TodayClassesSection: View {
    let classes: [(session: ClassSession, period: PeriodDefinition)]
    let currentClassId: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bugünkü Dersler")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(classes.indices, id: \.self) { index in
                    let (session, period) = classes[index]
                    let isCurrent = currentClassId == session.id
                    
                    TodayClassRow(
                        session: session,
                        period: period,
                        isCurrentClass: isCurrent
                    )
                    .padding(.horizontal)
                    
                    if index < classes.count - 1 {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
            .padding(.horizontal)
        }
    }
}
