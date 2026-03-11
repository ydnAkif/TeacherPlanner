//
//  NotificationScheduler.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Bildirim zamanlayıcı servis
@MainActor
final class NotificationScheduler {
    private let modelContext: ModelContext
    private let schoolDayEngine: any SchoolDayCalculating
    private let notificationManager: NotificationManager

    init(
        modelContext: ModelContext,
        schoolDayEngine: any SchoolDayCalculating,
        notificationManager: NotificationManager
    ) {
        self.modelContext = modelContext
        self.schoolDayEngine = schoolDayEngine
        self.notificationManager = notificationManager
    }

    func cancelAllNotifications() async {
        await notificationManager.cancelAllNotifications()
    }

    func requestPermission() async -> Bool {
        await notificationManager.requestPermission()
    }

    /// Bugünün bildirimlerini zamanla
    func scheduleTodayNotifications() async {
        guard let semester = schoolDayEngine.getActiveSemester() else { return }

        // Bugün öğretim günü mü?
        let today = Date()
        let isInstructionalDay = schoolDayEngine.isInstructionalDay(today, semester: semester)

        guard isInstructionalDay else {
            // Ders yoksa tüm bildirimleri iptal et
            await notificationManager.cancelAllNotifications()
            return
        }

        // Bugünün weekday değerini al
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)

        // Bugünkü dersleri al
        let sessionsWithPeriods = classesForWeekday(weekday)
        guard !sessionsWithPeriods.isEmpty else { return }

        await notificationManager.scheduleDailyReminders(sessions: sessionsWithPeriods, on: today)
    }

    /// Gelecek 7 günün bildirimlerini zamanla
    func scheduleWeekNotifications() async {
        guard let semester = schoolDayEngine.getActiveSemester() else { return }

        let calendar = Calendar.current
        let today = Date()

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }

            let isInstructionalDay = schoolDayEngine.isInstructionalDay(
                date, semester: semester)
            guard isInstructionalDay else { continue }

            let weekday = calendar.component(.weekday, from: date)

            let sessionsWithPeriods = classesForWeekday(weekday)
            guard !sessionsWithPeriods.isEmpty else { continue }

            await notificationManager.scheduleDailyReminders(
                sessions: sessionsWithPeriods, on: date)
        }
    }

    // MARK: - Private Helpers

    /// Belirli bir hafta günündeki dersleri period bilgisiyle birlikte getirir
    private func classesForWeekday(_ weekday: Int) -> [(ClassSession, PeriodDefinition)] {
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )
        let sessions = modelContext.fetchResult(
            descriptor,
            failureMessage: "NotificationScheduler: sessions fetch failed"
        ).get(or: [])
        return sessions.compactMap { session -> (ClassSession, PeriodDefinition)? in
            guard let period = session.period else { return nil }
            return (session, period)
        }
    }

    /// Tüm bildirimleri sıfırla
    func rescheduleAllNotifications() async {
        await notificationManager.cancelAllNotifications()
        await scheduleWeekNotifications()
    }
}
