//
//  NextClassCard.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

/// Sıradaki ders kartı
struct NextClassCard: View {
    let result: NextClassResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.orange)
                Text("Sıradaki Ders")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
            }

            // Ders bilgisi
            HStack(spacing: 16) {
                // Ders rengi
                Circle()
                    .fill(result.session.course?.color ?? .blue)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: result.session.course?.symbolName ?? "book.fill")
                            .foregroundStyle(.white)
                            .font(.title2)
                    )

                // Ders detayları
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.courseTitle)
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let room = result.session.room {
                        Label(room, systemImage: "door.left.hand.open")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(
                        "\(result.period.title) • \(result.period.startTimeString)-\(result.period.endTimeString)"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Kalan süre (opsiyonel)
                if let timeUntil = timeUntilStart {
                    VStack(alignment: .trailing) {
                        Text(formattedTimeUntil(timeUntil))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.orange)
                        Text("kaldı")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.5))
        .cornerRadius(12)
    }

    /// Başlangıca ne kadar kaldı?
    private var timeUntilStart: TimeInterval? {
        let now = Date()
        let start = result.startTime
        return start.timeIntervalSince(now)
    }

    /// Süreyi formatla
    private func formattedTimeUntil(_ interval: TimeInterval) -> String {
        if interval < 0 {
            return "Başladı"
        }

        let minutes = Int(interval) / 60

        if minutes < 60 {
            return "\(minutes) dk"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) sa \(remainingMinutes) dk"
        }
    }
}

#Preview {
    NextClassCard(
        result: NextClassResult(
            session: ClassSession(
                weekday: 2,
                periodOrder: 1,
                course: Course(title: "5-C Fen Bilimleri", colorHex: "#FF9500"),
                room: "201"
            ),
            date: Date(),
            period: PeriodDefinition(
                title: "1. Ders",
                startTime: Date(),
                endTime: Date(),
                orderIndex: 1
            )
        )
    )
}
