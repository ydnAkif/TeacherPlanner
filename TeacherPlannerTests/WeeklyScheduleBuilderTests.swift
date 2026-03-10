//
//  WeeklyScheduleBuilderTests.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import XCTest

@testable import TeacherPlanner

@MainActor
final class WeeklyScheduleBuilderTests: XCTestCase {
    var context: ModelContext!
    var course: Course!
    var period: PeriodDefinition!

    override func setUp() async throws {
        let container = try await ModelContainerFactory.createPreview()
        context = container.mainContext

        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!

        course = Course(title: "Test Matematik", colorHex: "#007AFF", symbolName: "function")
        context.insert(course)

        period = PeriodDefinition(
            title: "1. Ders",
            startTime: calendar.date(bySettingHour: 8, minute: 40, second: 0, of: baseDate)!,
            endTime: calendar.date(bySettingHour: 9, minute: 20, second: 0, of: baseDate)!,
            orderIndex: 1
        )
        context.insert(period)

        try context.save()
    }

    // MARK: - Grid Testleri

    func testBuildWeeklyGrid_Empty() {
        let builder = WeeklyScheduleBuilder(modelContext: context)
        let grid = builder.buildWeeklyGrid()

        XCTAssertTrue(grid.cells.isEmpty, "Boş DB'de grid boş olmalı")
    }

    func testBuildWeeklyGrid_WithSessions() throws {
        // Pazartesi (weekday=2) 1. derse session ekle
        let session = ClassSession(weekday: 2, periodOrder: 1, course: course, period: period, room: "101")
        context.insert(session)
        try context.save()

        let builder = WeeklyScheduleBuilder(modelContext: context)
        let grid = builder.buildWeeklyGrid()

        XCTAssertEqual(grid.cells.count, 1, "Grid'de 1 session olmalı")
        let found = grid.session(for: 2, periodOrder: 1)
        XCTAssertNotNil(found, "Pazartesi 1. ders grid'de bulunmalı")
        XCTAssertEqual(found?.room, "101")
    }

    func testClassesForWeekday_WithSessions() throws {
        // Salı (weekday=3) iki session
        let s1 = ClassSession(weekday: 3, periodOrder: 1, course: course, period: period, room: "A1")
        let s2 = ClassSession(weekday: 3, periodOrder: 2, course: course, period: period, room: "A2")
        // Başka gün de bir session (gürültü)
        let s3 = ClassSession(weekday: 4, periodOrder: 1, course: course, period: period, room: "B1")
        context.insert(s1)
        context.insert(s2)
        context.insert(s3)
        try context.save()

        let builder = WeeklyScheduleBuilder(modelContext: context)
        let tuesdaySessions = builder.classesForWeekday(3)

        XCTAssertEqual(tuesdaySessions.count, 2, "Salı için 2 session dönmeli")
        XCTAssertTrue(tuesdaySessions.allSatisfy { $0.weekday == 3 }, "Tüm sessionlar Salı'ya ait olmalı")
    }

    func testBuildWeeklyView_HasRows() throws {
        // 3 period ekle
        let calendar = Calendar.current
        let base = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        for i in 2...3 {
            let p = PeriodDefinition(
                title: "\(i). Ders",
                startTime: calendar.date(bySettingHour: 8 + i, minute: 0, second: 0, of: base)!,
                endTime: calendar.date(bySettingHour: 8 + i, minute: 40, second: 0, of: base)!,
                orderIndex: i
            )
            context.insert(p)
        }
        try context.save()

        let builder = WeeklyScheduleBuilder(modelContext: context)
        let weeklyView = builder.buildWeeklyView()

        // 1 mevcut + 2 yeni = 3 period
        XCTAssertEqual(weeklyView.rows.count, 3, "Period sayısı kadar satır olmalı")
        XCTAssertFalse(weeklyView.weekdays.isEmpty, "Hafta günleri listesi boş olmamalı")
    }

    func testGridCell_SessionLookup_EmptyForMissingCell() throws {
        let builder = WeeklyScheduleBuilder(modelContext: context)
        let grid = builder.buildWeeklyGrid()

        // Var olmayan bir hücre nil dönmeli
        let result = grid.session(for: 5, periodOrder: 99)
        XCTAssertNil(result, "Olmayan hücre nil olmalı")
    }
}
