//
//  Weekday.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation

/// Haftanın günleri (SwiftUI ile uyumlu)
enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var displayName: String {
        switch self {
        case .sunday: return "Pazar"
        case .monday: return "Pazartesi"
        case .tuesday: return "Salı"
        case .wednesday: return "Çarşamba"
        case .thursday: return "Perşembe"
        case .friday: return "Cuma"
        case .saturday: return "Cumartesi"
        }
    }

    var shortName: String {
        switch self {
        case .sunday: return "Paz"
        case .monday: return "Pzt"
        case .tuesday: return "Sal"
        case .wednesday: return "Çar"
        case .thursday: return "Per"
        case .friday: return "Cum"
        case .saturday: return "Cmt"
        }
    }

    var isWeekend: Bool {
        self == .sunday || self == .saturday
    }

    /// Calendar.Weekday değerinden Weekday oluştur
    static func fromCalendarWeekday(_ weekday: Int) -> Weekday? {
        guard weekday >= 1 && weekday <= 7 else { return nil }
        return Weekday(rawValue: weekday)
    }
}
