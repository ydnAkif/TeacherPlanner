//
//  SchoolDayEngine.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Okul günü hesaplama motoru
/// Bir tarihin öğretim günü olup olmadığını kontrol eder
struct SchoolDayEngine: SchoolDayCalculating {
    private let modelContext: ModelContext
    private let weekendRule: WeekendRule

    init(modelContext: ModelContext, weekendRule: WeekendRule = .saturdaySunday) {
        self.modelContext = modelContext
        self.weekendRule = weekendRule
    }

    /// Verilen tarihin öğretim günü olup olmadığını kontrol eder
    /// - Parameters:
    ///   - date: Kontrol edilecek tarih
    ///   - semester: İlgili dönem (nil ise aktif dönem kullanılır)
    /// - Returns: true ise o gün ders var
    func isInstructionalDay(_ date: Date, semester: Semester? = nil) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)

        // Kullanılacak semester
        let semesterToUse = semester ?? getActiveSemester()
        guard let semester = semesterToUse else {
            return false  // Aktif dönem yok
        }

        // 1. Dönem içinde mi?
        guard semester.contains(date) else {
            return false
        }

        // 2. Hafta sonu mu?
        let weekday = calendar.component(.weekday, from: date)
        if weekendRule.isSkipped(weekday: weekday) {
            return false
        }

        // 3. Skipped day mi? (manuel eklenenler, resmi tatil vb.)
        let isSkipped = isSkippedDay(targetDate, in: semester)
        if isSkipped {
            return false
        }

        return true
    }

    /// Tarihin skipped day olup olmadığını kontrol eder
    private func isSkippedDay(_ date: Date, in semester: Semester) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)

        for skippedDay in semester.skippedDays {
            let skippedDate = calendar.startOfDay(for: skippedDay.date)
            if skippedDate == targetDate {
                return true
            }
        }
        return false
    }

    /// Aktif dönemi bulur
    func getActiveSemester() -> Semester? {
        let descriptor = FetchDescriptor<Semester>(
            predicate: #Predicate { $0.isActive }
        )

        do {
            let semesters = try modelContext.fetch(descriptor)
            return semesters.first
        } catch {
            return nil
        }
    }

    /// Bir tarih aralığındaki tüm öğretim günlerini döner
    func getInstructionalDays(in range: DateInterval, semester: Semester? = nil) -> [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        var currentDate = range.start

        while currentDate <= range.end {
            if isInstructionalDay(currentDate, semester: semester) {
                days.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }

    /// Belirli bir tarihten sonraki ilk öğretim gününü bulur
    func nextInstructionalDay(after date: Date, semester: Semester? = nil) -> Date? {
        let calendar = Calendar.current
        var currentDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date

        // Maksimum 365 gün ileriye bak
        for _ in 0..<365 {
            if isInstructionalDay(currentDate, semester: semester) {
                return currentDate
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return nil
    }

    /// Belirli bir tarihten önceki son öğretim gününü bulur
    func previousInstructionalDay(before date: Date, semester: Semester? = nil) -> Date? {
        let calendar = Calendar.current
        var currentDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date

        // Maksimum 365 gün geriye bak
        for _ in 0..<365 {
            if isInstructionalDay(currentDate, semester: semester) {
                return currentDate
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        return nil
    }
}
