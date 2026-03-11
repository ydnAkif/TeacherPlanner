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
    func scheduleDailyReminders(
        sessions: [(session: ClassSession, period: PeriodDefinition)],
        on date: Date,
        minutesBefore: Int? = nil
    ) async {
        let minutesBefore = minutesBefore ?? Constants.Notification.defaultReminderMinutesBefore
        let calendar = Calendar.current

        for (session, period) in sessions {
            guard let course = session.course else { continue }
            guard
                let reminderTime = Self.reminderDate(
                    for: period,
                    on: date,
                    minutesBefore: minutesBefore,
                    calendar: calendar
                )
            else { continue }
            guard reminderTime > Date() else { continue }

            let identifier = Self.reminderIdentifier(
                for: session.id,
                on: date,
                calendar: calendar
            )

            await scheduleClassReminder(
                courseName: course.title,
                startTime: reminderTime,
                identifier: identifier
            )
        }
    }

    static func reminderDate(
        for period: PeriodDefinition,
        on date: Date,
        minutesBefore: Int,
        calendar: Calendar = .current
    ) -> Date? {
        let startHour = calendar.component(.hour, from: period.startTime)
        let startMinute = calendar.component(.minute, from: period.startTime)
        guard
            let classStart = calendar.date(
                bySettingHour: startHour,
                minute: startMinute,
                second: 0,
                of: date
            )
        else { return nil }

        return calendar.date(byAdding: .minute, value: -minutesBefore, to: classStart)
    }

    static func reminderIdentifier(
        for sessionID: UUID,
        on date: Date,
        calendar: Calendar = .current
    ) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let dateKey = String(format: "%04d%02d%02d", year, month, day)
        return "class_\(sessionID.uuidString)_\(dateKey)"
    }
}
