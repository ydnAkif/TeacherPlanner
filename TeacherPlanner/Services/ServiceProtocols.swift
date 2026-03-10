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
protocol SchoolDayCalculating: Sendable {
    func isInstructionalDay(_ date: Date, semester: Semester?) -> Bool
    func getActiveSemester() -> Semester?
    func nextInstructionalDay(after date: Date, semester: Semester?) -> Date?
    func previousInstructionalDay(before date: Date, semester: Semester?) -> Date?
    func getInstructionalDays(in range: DateInterval, semester: Semester?) -> [Date]
}

// MARK: - Next Class Providing

/// Sıradaki ders sağlayıcısı soyutlaması
protocol NextClassProviding: Sendable {
    func nextClass(from date: Date, semester: Semester?) async -> NextClassResult?
    func classesForWeekday(_ weekday: Int, semester: Semester) async -> [ClassSession]
}

// MARK: - Today Schedule Providing

/// Bugünkü program sağlayıcısı soyutlaması
protocol TodayScheduleProviding: Sendable {
    func todayClasses(semester: Semester?) async -> [ClassSession]
    func todayClassesWithPeriods(semester: Semester?) async -> [(session: ClassSession, period: PeriodDefinition)]
    func currentClass(semester: Semester?) async -> (session: ClassSession, period: PeriodDefinition)?
    func hasTodayClasses(semester: Semester?) async -> Bool
}
