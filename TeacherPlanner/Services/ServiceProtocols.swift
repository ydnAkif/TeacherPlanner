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
