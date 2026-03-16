//
//  NextClassCard.swift
//  TeacherPlanner
//

import Combine
import SwiftUI

/// Sıradaki ders kartı — premium/modern tasarım
struct NextClassCard: View {
    let result: NextClassResult

    @State private var now: Date = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .topLeading) {
            // MARK: Arka plan gradyanı
            courseGradient
                .clipShape(RoundedRectangle(cornerRadius: 24))

            // MARK: Glassmorphism iç katman
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.15))

            // MARK: İnce üst kenar parlaması
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            // MARK: İçerik
            VStack(alignment: .leading, spacing: 0) {
                headerRow
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                Divider()
                    .overlay(Color.white.opacity(0.2))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)

                mainContent
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
            }
        }
        .shadow(color: courseColor.opacity(0.35), radius: 20, x: 0, y: 8)
        .onReceive(timer) { _ in now = Date() }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))

            Text("Sıradaki Ders")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .textCase(.uppercase)
                .tracking(0.8)

            Spacer()

            // Tarih etiketi
            Text(result.date, style: .date)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        HStack(alignment: .center, spacing: 16) {
            courseIconBadge
            courseInfo
            Spacer(minLength: 8)
            countdownBlock
        }
    }

    // MARK: - Ders İkonu

    private var courseIconBadge: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 56, height: 56)

            Circle()
                .stroke(.white.opacity(0.35), lineWidth: 1)
                .frame(width: 56, height: 56)

            Image(systemName: result.session.course?.symbolName ?? "book.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Ders Bilgisi

    private var courseInfo: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(result.courseTitle)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            HStack(spacing: 10) {
                Label(result.period.title, systemImage: "number")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))

                if let room = result.session.room {
                    Label(room, systemImage: "door.left.hand.open")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Label(
                "\(result.period.startTimeString) – \(result.period.endTimeString)",
                systemImage: "timer"
            )
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - Geri Sayım

    private var countdownBlock: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if let interval = timeUntilStart {
                Group {
                    if interval <= 0 {
                        Text("Başladı")
                            .font(.system(.title2, design: .rounded, weight: .heavy))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    } else {
                        Text(formattedInterval(interval))
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    }
                }

                Text(interval <= 0 ? "devam ediyor" : "kaldı")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
                    .textCase(.uppercase)
                    .tracking(1.0)
            } else {
                // Başlangıç zamanı hesaplanamadı
                Image(systemName: "clock.badge.questionmark")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(minWidth: 80, alignment: .trailing)
    }

    // MARK: - Helpers

    private var courseColor: Color {
        result.session.course?.color ?? AppColors.primary
    }

    private var courseGradient: LinearGradient {
        let base = courseColor
        return LinearGradient(
            stops: [
                .init(color: base.opacity(0.95), location: 0.0),
                .init(color: base.opacity(0.75), location: 0.6),
                .init(color: base.opacity(0.85), location: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var timeUntilStart: TimeInterval? {
        let interval = result.startTime.timeIntervalSince(now)
        // Ders bitmişse nil döndür
        if interval < -Double(result.durationMinutes * 60) {
            return nil
        }
        return interval
    }

    private func formattedInterval(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / 60
        if totalMinutes < 60 {
            return "\(totalMinutes) dk"
        }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return minutes == 0 ? "\(hours) sa" : "\(hours)sa \(minutes)dk"
    }
}

// MARK: - Preview

#Preview("Yaklaşan ders") {
    let period = PeriodDefinition(
        title: "1. Ders",
        startTime: Calendar.current.date(byAdding: .minute, value: 23, to: Date()) ?? Date(),
        endTime: Calendar.current.date(byAdding: .minute, value: 63, to: Date()) ?? Date(),
        orderIndex: 1
    )
    let course = Course(
        title: "5-C Fen Bilimleri",
        colorHex: "#FF9500",
        symbolName: "flask.fill"
    )
    let session = ClassSession(
        weekday: 2,
        periodOrder: 1,
        course: course,
        period: period,
        room: "Fen Lab 201"
    )
    return NextClassCard(
        result: NextClassResult(session: session, date: Date(), period: period)
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Devam eden ders") {
    let period = PeriodDefinition(
        title: "3. Ders",
        startTime: Calendar.current.date(byAdding: .minute, value: -10, to: Date()) ?? Date(),
        endTime: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date(),
        orderIndex: 3
    )
    let course = Course(
        title: "7-A Matematik",
        colorHex: "#5856D6",
        symbolName: "function"
    )
    let session = ClassSession(
        weekday: 3,
        periodOrder: 3,
        course: course,
        period: period,
        room: "A-12"
    )
    return NextClassCard(
        result: NextClassResult(session: session, date: Date(), period: period)
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
