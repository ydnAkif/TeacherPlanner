//
//  MEBPresetProvider.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Thread-safe veri taşıyıcısı — SwiftData bağımsız, arka plan thread'inde kullanılabilir.
struct SkippedDayData: Sendable {
    let date: Date
    let reason: String
    let type: SkipType
}

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
    nonisolated static func getSemesterBreaks() -> [(start: Date, end: Date, name: String)] {
        let calendar = Calendar.current
        var breaks: [(start: Date, end: Date, name: String)] = []

        // Güz Dönemi Ara Tatili (15 Kasım 2025 - 23 Kasım 2025)
        if let start = calendar.date(from: DateComponents(year: 2025, month: 11, day: 15)),
            let end = calendar.date(from: DateComponents(year: 2025, month: 11, day: 23))
        {
            breaks.append((start, end, "1. Ara Tatil"))
        }

        // Yılbaşı Tatili (1 Ocak 2026)
        if let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)),
            let end = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))
        {
            breaks.append((start, end, "Yılbaşı Tatili"))
        }

        // Bahar Dönemi Ara Tatili (13 Nisan 2026 - 17 Nisan 2026)
        if let start = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13)),
            let end = calendar.date(from: DateComponents(year: 2026, month: 4, day: 17))
        {
            breaks.append((start, end, "2. Ara Tatil"))
        }

        return breaks
    }

    /// Hangi günlerin atlanacağını **saf hesaplama** ile belirler.
    /// SwiftData'ya dokunmaz; `Task.detached` içinde güvenle çalıştırılabilir.
    /// - Parameters:
    ///   - start: Dönem başlangıç tarihi
    ///   - end: Dönem bitiş tarihi
    ///   - weekendRule: Hafta sonu kuralı
    /// - Returns: Atlanacak günlerin listesi (Sendable)
    nonisolated static func computeSkippedDays(
        start: Date,
        end: Date,
        weekendRule: WeekendRule
    ) -> [SkippedDayData] {
        let calendar = Calendar.current
        let breaks = getSemesterBreaks()
        let holidayInterval = DateInterval(start: start, end: end)
        let holidays = HolidayProvider.getHolidays(in: holidayInterval)

        var result: [SkippedDayData] = []
        var currentDate = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)

        while currentDate <= endDay {
            var skipType: SkipType?
            var reason = ""

            // Öncelik: Ara tatil > Resmi tatil > Hafta sonu
            if let br = breaks.first(where: { currentDate >= $0.start && currentDate <= $0.end }) {
                skipType = .semesterBreak
                reason = br.name
            } else if let hol = holidays.first(where: {
                calendar.isDate($0.date, inSameDayAs: currentDate)
            }) {
                skipType = .holiday
                reason = hol.name
            } else if weekendRule.isSkipped(
                weekday: calendar.component(.weekday, from: currentDate)
            ) {
                skipType = .weekend
                reason = "hafta sonu"
            }

            if let type = skipType {
                result.append(SkippedDayData(date: currentDate, reason: reason, type: type))
            }

            currentDate =
                calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return result
    }

    /// Belirli bir dönem için MEB preset'ini uygular.
    /// - Note: Bu metod main thread'de **senkron** çalışır.
    ///   Yeni kodda `computeSkippedDays` + manuel insert tercih edilmeli.
    /// - Parameters:
    ///   - semester: Güncellenecek semester
    ///   - context: Model context
    static func applyMEBPreset(to semester: Semester, in context: ModelContext) {
        let skippedDays = computeSkippedDays(
            start: semester.startDate,
            end: semester.endDate,
            weekendRule: semester.weekendRule
        )

        for dayData in skippedDays {
            let skippedDay = SkippedDay(
                date: dayData.date,
                reason: dayData.reason,
                type: dayData.type
            )
            skippedDay.semester = semester
            context.insert(skippedDay)
        }

        // SkippedDay'ler üzerinden yönetildiği için weekendRule .none yapılır
        semester.weekendRule = .none
    }

    /// JSON tabanlı preset yükleme (gelecek sürümler için)
    static func loadFromJSON(_ data: Data) throws -> MEBSemesterPreset {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.isoDate)
        return try decoder.decode(MEBSemesterPreset.self, from: data)
    }
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
