//
//  ServiceProtocols.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 10.03.2026.
//

import Foundation
import SwiftData

// MARK: - School Day Calculating

/// Okul günü hesaplama soyutlaması
@MainActor
protocol SchoolDayCalculating {
    func isInstructionalDay(_ date: Date, semester: Semester?) -> Bool
    func getActiveSemester() -> Semester?
    func nextInstructionalDay(after date: Date, semester: Semester?) -> Date?
    func previousInstructionalDay(before date: Date, semester: Semester?) -> Date?
    func getInstructionalDays(in range: DateInterval, semester: Semester?) -> [Date]
}

// MARK: - Next Class Providing

/// Sıradaki ders sağlayıcısı soyutlaması
@MainActor
protocol NextClassProviding {
    func nextClass(from date: Date, semester: Semester?) async -> NextClassResult?
    func classesForWeekday(_ weekday: Int, semester: Semester) async -> [ClassSession]
}

// MARK: - Today Schedule Providing

/// Bugünkü program sağlayıcısı soyutlaması
@MainActor
protocol TodayScheduleProviding {
    func todayClasses(semester: Semester?) async -> [ClassSession]
    func todayClassesWithPeriods(semester: Semester?) async -> [(session: ClassSession, period: PeriodDefinition)]
    func currentClass(semester: Semester?) async -> (session: ClassSession, period: PeriodDefinition)?
    func hasTodayClasses(semester: Semester?) async -> Bool
}
// MARK: - Weekly Schedule Building

/// Haftalık program oluşturma soyutlaması
@MainActor
protocol WeeklyScheduleBuilding {
    func buildWeeklyGrid() -> WeeklyScheduleGrid
    func buildWeeklyView() -> WeeklyViewData
    func classesForWeekday(_ weekday: Int) -> [ClassSession]
    func allPeriods() -> [PeriodDefinition]
}
// MARK: - Notification Scheduling

/// Bildirim zamanlama soyutlaması
@MainActor
protocol NotificationScheduling {
    func rescheduleAllNotifications() async
    func cancelAllNotifications() async
    func requestPermission() async -> Bool
}
