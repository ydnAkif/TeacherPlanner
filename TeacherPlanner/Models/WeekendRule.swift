//
//  WeekendRule.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation

/// Hafta sonu hangi günleri skip edeceğini belirtir
enum WeekendRule: String, Codable, CaseIterable, Sendable {
    /// Cumartesi ve Pazar (Türkiye standart)
    case saturdaySunday = "saturday_sunday"

    /// Sadece Pazar (bazı ülkeler)
    case sundayOnly = "sunday_only"

    /// Hafta sonu yok (yıl boyu eğitim)
    case none = "none"

    /// Skip edilen weekdays (Calendar.weekday: 1=Pazar, 7=Cumartesi)
    var skippedWeekdays: Set<Int> {
        switch self {
        case .saturdaySunday:
            return [1, 7]  // Pazar ve Cumartesi
        case .sundayOnly:
            return [1]  // Pazar
        case .none:
            return []
        }
    }

    /// Verilen weekday'in skip edilip edilmeyeceğini kontrol eder
    func isSkipped(weekday: Int) -> Bool {
        skippedWeekdays.contains(weekday)
    }
}
