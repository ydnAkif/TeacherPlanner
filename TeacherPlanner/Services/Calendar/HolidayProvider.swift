//
//  HolidayProvider.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation

/// Türkiye Cumhuriyeti resmi tatilleri sağlar
struct HolidayProvider {

    /// Sabit resmi tatiller (her yıl aynı tarih)
    static let fixedHolidays: [(month: Int, day: Int, name: String)] = [
        (1, 1, "Yılbaşı Tatili"),
        (4, 23, "Ulusal Egemenlik ve Çocuk Bayramı"),
        (5, 19, "Atatürk'ü Anma, Gençlik ve Spor Bayramı"),
        (8, 30, "Zafer Bayramı"),
        (10, 29, "Cumhuriyet Bayramı")
    ]

    /// Dini bayramlar için 2025-2026 yılları (Hicri takvime göre değişir)
    /// Kaynak: Diyanet İşleri Başkanlığı
    static func getReligiousHolidays(for year: Int) -> [(date: Date, name: String)] {
        let calendar = Calendar.current
        var holidays: [(date: Date, name: String)] = []

        // 2025 Yılı Dini Bayramlar
        if year == 2025 {
            // Ramazan Bayramı (3 gün)
            if let ramazanEve = calendar.date(from: DateComponents(year: 2025, month: 3, day: 30)) {
                holidays.append((ramazanEve, "Ramazan Bayramı Arefesi"))
            }
            if let ramazan1 = calendar.date(from: DateComponents(year: 2025, month: 3, day: 31)) {
                holidays.append((ramazan1, "Ramazan Bayramı 1. Gün"))
            }
            if let ramazan2 = calendar.date(from: DateComponents(year: 2025, month: 4, day: 1)) {
                holidays.append((ramazan2, "Ramazan Bayramı 2. Gün"))
            }
            if let ramazan3 = calendar.date(from: DateComponents(year: 2025, month: 4, day: 2)) {
                holidays.append((ramazan3, "Ramazan Bayramı 3. Gün"))
            }

            // Kurban Bayramı (4 gün)
            if let kurbanEve = calendar.date(from: DateComponents(year: 2025, month: 6, day: 5)) {
                holidays.append((kurbanEve, "Kurban Bayramı Arefesi"))
            }
            if let kurban1 = calendar.date(from: DateComponents(year: 2025, month: 6, day: 6)) {
                holidays.append((kurban1, "Kurban Bayramı 1. Gün"))
            }
            if let kurban2 = calendar.date(from: DateComponents(year: 2025, month: 6, day: 7)) {
                holidays.append((kurban2, "Kurban Bayramı 2. Gün"))
            }
            if let kurban3 = calendar.date(from: DateComponents(year: 2025, month: 6, day: 8)) {
                holidays.append((kurban3, "Kurban Bayramı 3. Gün"))
            }
            if let kurban4 = calendar.date(from: DateComponents(year: 2025, month: 6, day: 9)) {
                holidays.append((kurban4, "Kurban Bayramı 4. Gün"))
            }
        }

        // 2026 Yılı Dini Bayramlar
        if year == 2026 {
            // Ramazan Bayramı (3 gün) - yaklaşık tarihler
            if let ramazanEve = calendar.date(from: DateComponents(year: 2026, month: 3, day: 20)) {
                holidays.append((ramazanEve, "Ramazan Bayramı Arefesi"))
            }
            if let ramazan1 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 21)) {
                holidays.append((ramazan1, "Ramazan Bayramı 1. Gün"))
            }
            if let ramazan2 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 22)) {
                holidays.append((ramazan2, "Ramazan Bayramı 2. Gün"))
            }
            if let ramazan3 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 23)) {
                holidays.append((ramazan3, "Ramazan Bayramı 3. Gün"))
            }

            // Kurban Bayramı (4 gün) - yaklaşık tarihler
            if let kurbanEve = calendar.date(from: DateComponents(year: 2026, month: 5, day: 26)) {
                holidays.append((kurbanEve, "Kurban Bayramı Arefesi"))
            }
            if let kurban1 = calendar.date(from: DateComponents(year: 2026, month: 5, day: 27)) {
                holidays.append((kurban1, "Kurban Bayramı 1. Gün"))
            }
            if let kurban2 = calendar.date(from: DateComponents(year: 2026, month: 5, day: 28)) {
                holidays.append((kurban2, "Kurban Bayramı 2. Gün"))
            }
            if let kurban3 = calendar.date(from: DateComponents(year: 2026, month: 5, day: 29)) {
                holidays.append((kurban3, "Kurban Bayramı 3. Gün"))
            }
            if let kurban4 = calendar.date(from: DateComponents(year: 2026, month: 5, day: 30)) {
                holidays.append((kurban4, "Kurban Bayramı 4. Gün"))
            }
        }

        return holidays
    }

    /// Belirli bir yıl için tüm resmi tatilleri döner
    static func getAllHolidays(for year: Int) -> [(date: Date, name: String)] {
        let calendar = Calendar.current
        var holidays: [(date: Date, name: String)] = []

        // Sabit tatiller
        for holiday in fixedHolidays {
            if let date = calendar.date(
                from: DateComponents(year: year, month: holiday.month, day: holiday.day))
            {
                holidays.append((date, holiday.name))
            }
        }

        // Dini bayramlar
        holidays.append(contentsOf: getReligiousHolidays(for: year))

        return holidays
    }

    /// Tarih aralığındaki tatilleri döner
    static func getHolidays(in range: DateInterval) -> [(date: Date, name: String)] {
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: range.start)
        let endYear = calendar.component(.year, from: range.end)

        var allHolidays: [(date: Date, name: String)] = []

        for year in startYear...endYear {
            let yearHolidays = getAllHolidays(for: year)
            for holiday in yearHolidays {
                if holiday.date >= range.start && holiday.date <= range.end {
                    allHolidays.append(holiday)
                }
            }
        }

        return allHolidays.sorted { $0.date < $1.date }
    }
}
