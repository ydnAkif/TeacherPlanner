//
//  PeriodDefinition.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Ders saatlerini tanımlar (örn: 1. Ders 08:40-09:20)
@Model
final class PeriodDefinition {
    var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var orderIndex: Int

    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date,
        endTime: Date,
        orderIndex: Int
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.orderIndex = orderIndex
    }

    /// Başlangıç saati (String olarak)
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    /// Bitiş saati (String olarak)
    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endTime)
    }

    /// Süre (dakika)
    var durationMinutes: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
    }
}
