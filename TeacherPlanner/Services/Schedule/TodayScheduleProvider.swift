//
//  TodayScheduleProvider.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Bugünkü ders programını sağlayan servis
@MainActor
class TodayScheduleProvider: TodayScheduleProviding {
    private let modelContext: ModelContext
    private let schoolDayEngine: SchoolDayCalculating

    init(modelContext: ModelContext, schoolDayEngine: SchoolDayEngine) {
        self.modelContext = modelContext
        self.schoolDayEngine = schoolDayEngine
    }

    /// Bugünkü dersleri getirir
    /// - Parameter semester: İlgili dönem (nil ise aktif dönem)
    /// - Returns: Bugünkü ClassSession listesi (period order'a göre sıralı)
    func todayClasses(semester: Semester? = nil) async -> [ClassSession] {
        let calendar = Calendar.current
        let today = Date()

        // Bugün öğretim günü mü?
        let targetSemester = schoolDayEngine.getActiveSemester()
        let semesterToUse = semester ?? targetSemester
        guard let semester = semesterToUse else { return [] }

        guard schoolDayEngine.isInstructionalDay(today, semester: semester) else {
            return []
        }

        // Bugünün weekday değerini al
        let weekday = calendar.component(.weekday, from: today)

        // Bugünün derslerini getir
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Bugünkü dersleri period bilgisiyle birlikte getirir
    func todayClassesWithPeriods(semester: Semester? = nil) async -> [(
        session: ClassSession, period: PeriodDefinition
    )] {
        let sessions = await todayClasses(semester: semester)

        return sessions.compactMap { session in
            guard let period = session.period else { return nil }
            return (session: session, period: period)
        }
    }

    /// Bugün ders var mı?
    func hasTodayClasses(semester: Semester? = nil) async -> Bool {
        let sessions = await todayClasses(semester: semester)
        return !sessions.isEmpty
    }

    /// Şu anki dersi bulur (eğer varsa)
    func currentClass(semester: Semester? = nil) async -> (
        session: ClassSession, period: PeriodDefinition
    )? {
        let calendar = Calendar.current
        let now = Date()
        let nowHour = calendar.component(.hour, from: now)
        let nowMinute = calendar.component(.minute, from: now)

        let sessions = await todayClassesWithPeriods(semester: semester)

        for (session, period) in sessions {
            let periodHour = calendar.component(.hour, from: period.startTime)
            let periodMinute = calendar.component(.minute, from: period.startTime)
            let endHour = calendar.component(.hour, from: period.endTime)
            let endMinute = calendar.component(.minute, from: period.endTime)

            // Ders başladı mı?
            let started =
                periodHour < nowHour || (periodHour == nowHour && periodMinute <= nowMinute)
            // Ders bitti mi?
            let ended = endHour < nowHour || (endHour == nowHour && endMinute < nowMinute)

            if started && !ended {
                return (session, period)
            }
        }

        return nil
    }

    /// Bir sonraki teneffüse ne kadar kaldı?
    func timeUntilNextBreak(semester: Semester? = nil) async -> TimeInterval? {
        let calendar = Calendar.current
        let now = Date()

        let sessions = await todayClassesWithPeriods(semester: semester)

        for (_, period) in sessions {
            let periodHour = calendar.component(.hour, from: period.startTime)
            let periodMinute = calendar.component(.minute, from: period.startTime)

            var startDate =
                calendar.date(
                    bySettingHour: periodHour,
                    minute: periodMinute,
                    second: 0,
                    of: now
                ) ?? now

            // Eğer ders geçmişse, yarınki aynı saat
            if startDate < now {
                startDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
            }

            return startDate.timeIntervalSince(now)
        }

        return nil
    }
}
