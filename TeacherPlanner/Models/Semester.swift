//
//  Semester.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Bir eğitim dönemini temsil eder
@Model
final class Semester {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var weekendRule: WeekendRule
    var isActive: Bool

    @Relationship(deleteRule: .cascade)
    var skippedDays: [SkippedDay]

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date,
        weekendRule: WeekendRule = .saturdaySunday,
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.weekendRule = weekendRule
        self.isActive = isActive
        self.skippedDays = []
    }

    /// Dönem içinde mi?
    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let target = calendar.startOfDay(for: date)
        return target >= start && target <= end
    }

    /// Gün sayısı
    var totalDays: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
