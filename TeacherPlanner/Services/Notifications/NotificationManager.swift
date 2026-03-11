//
//  NotificationManager.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import UserNotifications

/// Bildirim yöneticisi
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    /// Bildirim izni iste
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            Logger.error(error, message: "Notification permission error")
            return false
        }
    }

    /// Bildirim izni durumu
    func hasPermission() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    /// Ders bildirimini zamanla
    func scheduleClassReminder(
        courseName: String,
        startTime: Date,
        identifier: String
    ) async {
        guard await hasPermission() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Ders Zili"
        content.body = "\(courseName) dersi başlamak üzere!"
        content.sound = .default
        content.categoryIdentifier = "CLASS_REMINDER"

        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: startTime
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            Logger.error(error, message: "Failed to schedule notification")
        }
    }

    /// Bildirimi iptal et
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Tüm bildirimleri iptal et
    func cancelAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Günlük ders bildirimlerini zamanla
    func scheduleDailyReminders(sessions: [(session: ClassSession, period: PeriodDefinition)]) async
    {
        for (session, period) in sessions {
            guard let course = session.course else { continue }

            let identifier = "class_\(session.id.uuidString)"

            // Ders başlamadan 15 dakika önce
            guard
                let reminderTime = Calendar.current.date(
                    byAdding: .minute,
                    value: -15,
                    to: period.startTime
                )
            else { continue }

            await scheduleClassReminder(
                courseName: course.title,
                startTime: reminderTime,
                identifier: identifier
            )
        }
    }
}
