//
//  NoClassesView.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftUI

struct NoClassesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("Bugün Ders Yok")
                .font(.headline)
            
            Text("Tatil gününün tadını çıkar! 🎉")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
        .padding(.horizontal)
    }
}
