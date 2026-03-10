//
//  ClassSession.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Haftalık ders programı - bir gün ve period içine dersi bağlar
@Model
final class ClassSession {
    var id: UUID
    var weekday: Int  // 1-7 arası (Pazar-Cumartesi)
    var periodOrder: Int
    var room: String?
    var notes: String?

    @Relationship
    var course: Course?

    @Relationship
    var period: PeriodDefinition?

    init(
        id: UUID = UUID(),
        weekday: Int,
        periodOrder: Int,
        course: Course? = nil,
        period: PeriodDefinition? = nil,
        room: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.weekday = weekday
        self.periodOrder = periodOrder
        self.course = course
        self.period = period
        self.room = room
        self.notes = notes
    }

    /// Haftanın günü (Weekday enum olarak)
    var weekdayEnum: Weekday? {
        Weekday.fromCalendarWeekday(weekday)
    }
}
