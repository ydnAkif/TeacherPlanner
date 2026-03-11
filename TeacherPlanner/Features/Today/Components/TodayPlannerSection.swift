//
//  TodayPlannerSection.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftUI

struct TodayPlannerSection: View {
    let items: [PlannerItem]
    let onToggle: (PlannerItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Görevler")
                    .font(.headline)
                    .padding(.horizontal)
                
                Spacer()
                
                if !items.isEmpty {
                    Text("\(items.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(.trailing, 16)
                }
            }
            
            if items.isEmpty {
                Text("Bugün görev yok")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(items) { item in
                        PlannerItemRow(
                            item: item,
                            onToggle: {
                                onToggle(item)
                            }
                        )
                        .padding(.horizontal)
                        
                        if item.id != items.last?.id {
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
}
