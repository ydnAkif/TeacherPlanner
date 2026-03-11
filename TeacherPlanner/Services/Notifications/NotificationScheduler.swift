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
final class NotificationScheduler: NotificationScheduling {
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
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )

        let fetchResult = modelContext.fetchResult(
            descriptor,
            failureMessage: "NotificationScheduler: today sessions fetch failed"
        )
        let sessions = fetchResult.get(or: [])
        guard !sessions.isEmpty else { return }

        // Bildirimleri zamanla
        let sessionsWithPeriods = sessions.compactMap {
            session -> (ClassSession, PeriodDefinition)? in
            guard let period = session.period else { return nil }
            return (session, period)
        }

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

            let descriptor = FetchDescriptor<ClassSession>(
                predicate: #Predicate { $0.weekday == weekday },
                sortBy: [SortDescriptor(\.periodOrder)]
            )

            let fetchResult = modelContext.fetchResult(
                descriptor,
                failureMessage: "NotificationScheduler: week sessions fetch failed"
            )
            let sessions = fetchResult.get(or: [])
            guard !sessions.isEmpty else { continue }

            let sessionsWithPeriods = sessions.compactMap {
                session -> (ClassSession, PeriodDefinition)? in
                guard let period = session.period else { return nil }
                return (session, period)
            }

            await notificationManager.scheduleDailyReminders(sessions: sessionsWithPeriods, on: date)
        }
    }

    /// Tüm bildirimleri sıfırla
    func rescheduleAllNotifications() async {
        await notificationManager.cancelAllNotifications()
        await scheduleWeekNotifications()
    }
}
