//
//  SkippedDay.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Ders yapılmayan günler (hafta sonu, tatil, manuel vb.)
@Model
final class SkippedDay {
    var id: UUID
    var date: Date
    var reason: String
    var type: SkipType

    @Relationship(inverse: \Semester.skippedDays)
    var semester: Semester?

    init(
        id: UUID = UUID(),
        date: Date,
        reason: String,
        type: SkipType
    ) {
        self.id = id
        self.date = date
        self.reason = reason
        self.type = type
    }

    /// Tarih karşılaştırması için (time component olmadan)
    var dateOnly: Date {
        Calendar.current.startOfDay(for: date)
    }
}
