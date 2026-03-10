//
//  PeriodRow.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

/// Ders saati satırı
struct PeriodRow: View {
    let period: PeriodDefinition

    var body: some View {
        HStack(spacing: 12) {
            // Sıra numarası
            Text("\(period.orderIndex)")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .cornerRadius(4)

            // Ders bilgisi
            VStack(alignment: .leading, spacing: 4) {
                Text(period.title)
                    .font(.body)
                    .fontWeight(.medium)

                Text("\(period.startTimeString) - \(period.endTimeString)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Süre
            Text("\(period.durationMinutes) dk")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        PeriodRow(
            period: PeriodDefinition(
                title: "1. Ders",
                startTime: Date(),
                endTime: Date(),
                orderIndex: 1
            )
        )
    }
}
