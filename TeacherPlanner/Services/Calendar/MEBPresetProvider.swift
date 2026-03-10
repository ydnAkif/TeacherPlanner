//
//  MEBPresetProvider.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// MEB 2025-2026 eğitim yılı preset sağlayıcı
/// Ara tatiller ve dönem tarihlerini içerir
struct MEBPresetProvider {

    /// 2025-2026 Eğitim Yılı Dönem Bilgileri
    /// Kaynak: MEB Takvimi
    static let academicYear2025_2026: (guz: DateInterval, bahar: DateInterval) = {
        let calendar = Calendar.current

        // Güz Dönemi: 8 Eylül 2025 - 23 Ocak 2026
        let guzStart = calendar.date(from: DateComponents(year: 2025, month: 9, day: 8))!
        let guzEnd = calendar.date(from: DateComponents(year: 2026, month: 1, day: 23))!

        // Bahar Dönemi: 9 Şubat 2026 - 19 Haziran 2026
        let baharStart = calendar.date(from: DateComponents(year: 2026, month: 2, day: 9))!
        let baharEnd = calendar.date(from: DateComponents(year: 2026, month: 6, day: 26))!

        return (
            guz: DateInterval(start: guzStart, end: guzEnd),
            bahar: DateInterval(start: baharStart, end: baharEnd)
        )
    }()

    /// 2025-2026 Ara Tatiller
    static func getSemesterBreaks() -> [(start: Date, end: Date, name: String)] {
        let calendar = Calendar.current
        var breaks: [(start: Date, end: Date, name: String)] = []

        // Güz Dönemi Ara Tatili (15 Kasım 2025 - 23 Kasım 2025)
        if let start = calendar.date(from: DateComponents(year: 2025, month: 11, day: 15)),
           let end = calendar.date(from: DateComponents(year: 2025, month: 11, day: 23)) {
            breaks.append((start, end, "1. Ara Tatil"))
        }

        // Yılbaşı Tatili (1 Ocak 2026)
        if let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)),
           let end = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) {
            breaks.append((start, end, "Yılbaşı Tatili"))
        }

        // Bahar Dönemi Ara Tatili (13 Nisan 2026 - 17 Nisan 2026)
        if let start = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13)),
           let end = calendar.date(from: DateComponents(year: 2026, month: 4, day: 17)) {
            breaks.append((start, end, "2. Ara Tatil"))
        }

        return breaks
    }

    /// Belirli bir dönem için MEB preset'ini uygular
    /// - Parameters:
    ///   - semester: Güncellenecek semester
    ///   - context: Model context
    static func applyMEBPreset(to semester: Semester, in context: ModelContext) {
        let calendar = Calendar.current

        // Ara tatilleri ekle
        for breakPeriod in getSemesterBreaks() {
            // Dönem içinde mi kontrol et
            guard breakPeriod.start >= semester.startDate && breakPeriod.end <= semester.endDate else {
                continue
            }

            // Tüm ara tatil günlerini ekle
            var currentDate = breakPeriod.start
            while currentDate <= breakPeriod.end {
                let skippedDay = SkippedDay(
                    date: currentDate,
                    reason: breakPeriod.name,
                    type: .semesterBreak
                )
                skippedDay.semester = semester
                context.insert(skippedDay)

                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }

        // Resmi tatilleri ekle
        let dateRange = DateInterval(start: semester.startDate, end: semester.endDate)
        let holidays = HolidayProvider.getHolidays(in: dateRange)

        for holiday in holidays {
            let skippedDay = SkippedDay(
                date: holiday.date,
                reason: holiday.name,
                type: .holiday
            )
            skippedDay.semester = semester
            context.insert(skippedDay)
        }
    }

    /// JSON tabanlı preset yükleme (gelecek sürümler için)
    static func loadFromJSON(_ data: Data) throws -> MEBSemesterPreset {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Self.dateFormatter)
        return try decoder.decode(MEBSemesterPreset.self, from: data)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
}

/// JSON preset modeli
struct MEBSemesterPreset: Codable {
    let name: String
    let startDate: Date
    let endDate: Date
    let breaks: [SemesterBreak]
    let holidays: [Holiday]
}

struct SemesterBreak: Codable {
    let start: Date
    let end: Date
    let name: String
}

struct Holiday: Codable {
    let date: Date
    let name: String
}
