//
//  NotificationScheduler.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Bildirim zamanlayıcı servis
actor NotificationScheduler {
    private let modelContext: ModelContext
    private let schoolDayEngine: SchoolDayEngine
    private let notificationManager: NotificationManager

    init(
        modelContext: ModelContext,
        schoolDayEngine: SchoolDayEngine,
        notificationManager: NotificationManager
    ) {
        self.modelContext = modelContext
        self.schoolDayEngine = schoolDayEngine
        self.notificationManager = notificationManager
    }

    /// Bugünün bildirimlerini zamanla
    func scheduleTodayNotifications() async {
        guard let semester = await schoolDayEngine.getActiveSemester() else { return }

        // Bugün öğretim günü mü?
        let today = Date()
        let isInstructionalDay = await schoolDayEngine.isInstructionalDay(today, semester: semester)

        guard isInstructionalDay else {
            // Ders yoksa tüm bildirimleri iptal et
            await notificationManager.cancelAllNotifications()
            return
        }

        // Bugünün weekday değerini al
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)

        // Bugünkü dersleri al
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )

        guard let sessions = try? modelContext.fetch(descriptor) else { return }

        // Bildirimleri zamanla
        let sessionsWithPeriods = sessions.compactMap {
            session -> (ClassSession, PeriodDefinition)? in
            guard let period = session.period else { return nil }
            return (session, period)
        }

        await notificationManager.scheduleDailyReminders(sessions: sessionsWithPeriods)
    }

    /// Gelecek 7 günün bildirimlerini zamanla
    func scheduleWeekNotifications() async {
        guard let semester = await schoolDayEngine.getActiveSemester() else { return }

        let calendar = Calendar.current
        let today = Date()

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }

            let isInstructionalDay = await schoolDayEngine.isInstructionalDay(
                date, semester: semester)
            guard isInstructionalDay else { continue }

            let weekday = calendar.component(.weekday, from: date)

            let descriptor = FetchDescriptor<ClassSession>(
                predicate: #Predicate { $0.weekday == weekday },
                sortBy: [SortDescriptor(\.periodOrder)]
            )

            guard let sessions = try? modelContext.fetch(descriptor) else { continue }

            let sessionsWithPeriods = sessions.compactMap {
                session -> (ClassSession, PeriodDefinition)? in
                guard let period = session.period else { return nil }
                return (session, period)
            }

            await notificationManager.scheduleDailyReminders(sessions: sessionsWithPeriods)
        }
    }

    /// Tüm bildirimleri sıfırla
    func rescheduleAllNotifications() async {
        await notificationManager.cancelAllNotifications()
        await scheduleWeekNotifications()
    }
}
