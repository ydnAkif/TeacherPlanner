//
//  NextClassCalculator.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Sıradaki dersi hesaplayan servis
actor NextClassCalculator: NextClassProviding {
    private let modelContext: ModelContext
    private let schoolDayEngine: SchoolDayEngine

    init(modelContext: ModelContext, schoolDayEngine: SchoolDayEngine) {
        self.modelContext = modelContext
        self.schoolDayEngine = schoolDayEngine
    }

    /// Sıradaki dersi bulur
    /// - Parameters:
    ///   - from: Başlangıç zamanı (varsayılan: şimdi)
    ///   - semester: İlgili dönem (nil ise aktif dönem)
    /// - Returns: Sıradaki ClassSession ve Period bilgisi
    func nextClass(from date: Date = Date(), semester: Semester? = nil) async -> NextClassResult? {
        let calendar = Calendar.current
        let targetSemester = await schoolDayEngine.getActiveSemester()
        let semesterToUse = semester ?? targetSemester
        guard let semester = semesterToUse else { return nil }

        // Bugün mü yoksa gelecek gün mü?
        var currentDate = date
        let today = calendar.startOfDay(for: date)

        // Bugünün derslerini kontrol et
        if await schoolDayEngine.isInstructionalDay(today, semester: semester) {
            if let todayClass = await findNextClassToday(after: date, semester: semester) {
                return todayClass
            }
            // Bugünün dersleri bitti, yarına bak
            currentDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        } else {
            // Bugün ders yok, ilk öğretim gününü bul
            guard
                let nextDay = await schoolDayEngine.nextInstructionalDay(
                    after: date, semester: semester)
            else {
                return nil
            }
            currentDate = nextDay
        }

        // Gelecek öğretim günlerini tara
        for _ in 0..<30 {
            if await schoolDayEngine.isInstructionalDay(currentDate, semester: semester) {
                if let classSession = await findFirstClass(on: currentDate, semester: semester) {
                    return classSession
                }
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return nil
    }

    /// Bugünkü sıradaki dersi bulur
    private func findNextClassToday(after date: Date, semester: Semester) async -> NextClassResult?
    {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: date)
        let currentMinute = calendar.component(.minute, from: date)

        // Bugünün weekday değerini al
        let weekday = calendar.component(.weekday, from: date)

        // Tüm sessionları getir
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )

        guard let sessions = try? modelContext.fetch(descriptor) else { return nil }

        for session in sessions {
            guard let period = session.period else { continue }

            // Period başlangıç saati
            let periodHour = calendar.component(.hour, from: period.startTime)
            let periodMinute = calendar.component(.minute, from: period.startTime)

            // Henüz başlamamış mı?
            if periodHour > currentHour
                || (periodHour == currentHour && periodMinute > currentMinute)
            {
                return NextClassResult(
                    session: session,
                    date: calendar.startOfDay(for: date),
                    period: period
                )
            }
        }

        return nil
    }

    /// Belirli bir gündeki ilk dersi bulur
    private func findFirstClass(on date: Date, semester: Semester) async -> NextClassResult? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )

        guard let sessions = try? modelContext.fetch(descriptor),
            let firstSession = sessions.first,
            let period = firstSession.period
        else {
            return nil
        }

        return NextClassResult(
            session: firstSession,
            date: calendar.startOfDay(for: date),
            period: period
        )
    }

    /// Haftanın belirli bir günündeki dersleri getirir
    func classesForWeekday(_ weekday: Int, semester: Semester) async -> [ClassSession] {
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

/// Next class sonucu
struct NextClassResult {
    let session: ClassSession
    let date: Date
    let period: PeriodDefinition

    /// Dersin tam başlangıç zamanı
    var startTime: Date {
        let calendar = Calendar.current
        let periodHour = calendar.component(.hour, from: period.startTime)
        let periodMinute = calendar.component(.minute, from: period.startTime)
        let periodSecond = calendar.component(.second, from: period.startTime)

        return calendar.date(
            bySettingHour: periodHour,
            minute: periodMinute,
            second: periodSecond,
            of: date
        ) ?? date
    }

    /// Dersin tam bitiş zamanı
    var endTime: Date {
        let calendar = Calendar.current
        let periodHour = calendar.component(.hour, from: period.endTime)
        let periodMinute = calendar.component(.minute, from: period.endTime)
        let periodSecond = calendar.component(.second, from: period.endTime)

        return calendar.date(
            bySettingHour: periodHour,
            minute: periodMinute,
            second: periodSecond,
            of: date
        ) ?? date
    }

    /// Ders adı
    var courseTitle: String {
        session.course?.title ?? "Ders Yok"
    }

    /// Ders süresi (dakika)
    var durationMinutes: Int {
        period.durationMinutes
    }
}
