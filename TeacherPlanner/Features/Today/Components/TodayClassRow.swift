//
//  TodayClassRow.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

/// Bugünkü ders satırı
struct TodayClassRow: View {
    let session: ClassSession
    let period: PeriodDefinition
    let isCurrentClass: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Zaman
            VStack(alignment: .leading, spacing: 2) {
                Text(period.startTimeString)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(period.endTimeString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50, alignment: .leading)

            // Divider
            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(width: 2, height: 32)

            // Ders bilgisi
            HStack(spacing: 12) {
                // Ders rengi
                Circle()
                    .fill(session.course?.color ?? .blue)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: session.course?.symbolName ?? "book.fill")
                            .foregroundStyle(.white)
                            .font(.caption)
                    )

                // Ders adı
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.course?.title ?? "Ders Yok")
                        .font(.body)
                        .fontWeight(.medium)

                    if let room = session.room {
                        Label(room, systemImage: "door.left.hand.open")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Şu anki ders badge
                if isCurrentClass {
                    Text("ŞİMDİ")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(isCurrentClass ? 1.0 : 0.8)
    }
}

#Preview {
    List {
        TodayClassRow(
            session: ClassSession(
                weekday: 2,
                periodOrder: 1,
                course: Course(title: "5-C Fen Bilimleri", colorHex: "#FF9500"),
                room: "201"
            ),
            period: PeriodDefinition(
                title: "1. Ders",
                startTime: Date(),
                endTime: Date(),
                orderIndex: 1
            ),
            isCurrentClass: false
        )

        TodayClassRow(
            session: ClassSession(
                weekday: 2,
                periodOrder: 2,
                course: Course(title: "6-A Fen Bilimleri", colorHex: "#007AFF"),
                room: "202"
            ),
            period: PeriodDefinition(
                title: "2. Ders",
                startTime: Date(),
                endTime: Date(),
                orderIndex: 2
            ),
            isCurrentClass: true
        )
    }
}
