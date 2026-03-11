//
//  TodayDateHeader.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftUI

struct TodayDateHeader: View {
    let dateDisplay: String
    let semesterName: String?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dateDisplay)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let semesterName = semesterName {
                Label(semesterName, systemImage: "graduationcap")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        .padding(.horizontal)
    }
}
