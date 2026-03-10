//
//  WeeklyScheduleBuilder.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Haftalık program grid'i oluşturan servis
struct WeeklyScheduleBuilder {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Haftalık programı oluşturur
    /// - Returns: (weekday, periodOrder) -> ClassSession mapping
    func buildWeeklyGrid() -> WeeklyScheduleGrid {
        let descriptor = FetchDescriptor<ClassSession>()

        guard let sessions = try? modelContext.fetch(descriptor) else {
            return WeeklyScheduleGrid()
        }

        var grid = WeeklyScheduleGrid()

        for session in sessions {
            let key = ScheduleCellKey(weekday: session.weekday, periodOrder: session.periodOrder)
            grid.cells[key] = session
        }

        return grid
    }

    /// Belirli bir günün derslerini getirir
    func classesForWeekday(_ weekday: Int) -> [ClassSession] {
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Tüm periodları sıralı getirir
    func allPeriods() -> [PeriodDefinition] {
        let descriptor = FetchDescriptor<PeriodDefinition>(
            sortBy: [SortDescriptor(\.orderIndex)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Haftalık görünüm için veri oluşturur
    /// Tek bir FetchDescriptor ile tüm session'ları çeker, in-memory lookup yapar (N+1 önlemi)
    func buildWeeklyView() -> WeeklyViewData {
        let periods = allPeriods()
        let weekdays: [Int] = [2, 3, 4, 5, 6]  // Pazartesi-Cuma

        // Tüm session'ları tek seferde çek
        let allSessions = buildWeeklyGrid()

        var rows: [WeeklyRow] = []

        for period in periods {
            var cells: [WeeklyCell] = []
            for weekday in weekdays {
                let session = allSessions.session(for: weekday, periodOrder: period.orderIndex)
                cells.append(WeeklyCell(weekday: weekday, session: session))
            }
            rows.append(WeeklyRow(period: period, cells: cells))
        }

        return WeeklyViewData(rows: rows, weekdays: weekdays)
    }

    /// Belirli bir gün ve period için session bulur (in-memory, N+1 yok)
    private func sessionForWeekday(_ weekday: Int, periodOrder: Int) -> ClassSession? {
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday && $0.periodOrder == periodOrder }
        )
        return (try? modelContext.fetch(descriptor))?.first
    }
}

/// Haftalık grid
struct WeeklyScheduleGrid {
    var cells: [ScheduleCellKey: ClassSession] = [:]

    func session(for weekday: Int, periodOrder: Int) -> ClassSession? {
        cells[ScheduleCellKey(weekday: weekday, periodOrder: periodOrder)]
    }
}

/// Grid key
struct ScheduleCellKey: Hashable {
    let weekday: Int
    let periodOrder: Int
}

/// Haftalık görünüm verisi
struct WeeklyViewData {
    let rows: [WeeklyRow]
    let weekdays: [Int]
}

/// Haftalık satır (bir period)
struct WeeklyRow {
    let period: PeriodDefinition
    let cells: [WeeklyCell]
}

/// Haftalık hücre
struct WeeklyCell {
    let weekday: Int
    let session: ClassSession?

    var course: Course? {
        session?.course
    }
}
