//
//  NextClassCalculatorTests.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import XCTest

@testable import TeacherPlanner

@MainActor
final class NextClassCalculatorTests: XCTestCase {
    var context: ModelContext!
    var schoolDayEngine: SchoolDayEngine!

    override func setUp() async throws {
        let container = try await ModelContainerFactory.createPreview()
        context = container.mainContext
        schoolDayEngine = SchoolDayEngine(modelContext: context)

        try createSampleData()
    }

    func createSampleData() throws {
        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!

        // Aktif dönem (Sep 2025 - Jan 2026)
        let semester = Semester(
            name: "Test Dönem",
            startDate: calendar.date(from: DateComponents(year: 2025, month: 9, day: 1))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 31))!,
            weekendRule: .saturdaySunday,
            isActive: true
        )
        context.insert(semester)

        let course = Course(title: "Test Fen", colorHex: "#FF9500", symbolName: "flask.fill")
        context.insert(course)

        // 1. ders saati: 08:40 - 09:20
        let period1 = PeriodDefinition(
            title: "1. Ders",
            startTime: calendar.date(bySettingHour: 8, minute: 40, second: 0, of: baseDate)!,
            endTime: calendar.date(bySettingHour: 9, minute: 20, second: 0, of: baseDate)!,
            orderIndex: 1
        )
        context.insert(period1)

        // 2. ders saati: 09:25 - 10:05
        let period2 = PeriodDefinition(
            title: "2. Ders",
            startTime: calendar.date(bySettingHour: 9, minute: 25, second: 0, of: baseDate)!,
            endTime: calendar.date(bySettingHour: 10, minute: 5, second: 0, of: baseDate)!,
            orderIndex: 2
        )
        context.insert(period2)

        // Salı (weekday=3) 1. ve 2. ders
        let session1 = ClassSession(weekday: 3, periodOrder: 1, course: course, period: period1, room: "201")
        let session2 = ClassSession(weekday: 3, periodOrder: 2, course: course, period: period2, room: "201")

        // Salı'ya ek olarak Pazartesi (weekday=2) 1. ders
        let sessionMonday = ClassSession(weekday: 2, periodOrder: 1, course: course, period: period1, room: "101")

        context.insert(session1)
        context.insert(session2)
        context.insert(sessionMonday)

        try context.save()
    }

    // MARK: - Mevcut Test

    func testNextClassCalculation() async {
        let calculator = NextClassCalculator(
            modelContext: context,
            schoolDayEngine: schoolDayEngine
        )

        let calendar = Calendar.current
        let mondayMorning = calendar.date(
            from: DateComponents(year: 2025, month: 9, day: 15, hour: 8, minute: 0))!

        let nextClass = await calculator.nextClass(from: mondayMorning)

        XCTAssertNotNil(nextClass)
        XCTAssertEqual(nextClass?.courseTitle, "Test Fen")
        XCTAssertEqual(nextClass?.period.title, "1. Ders")
    }

    // MARK: - Yeni Testler

    func testNextClass_AfterLastClassOfDay() async {
        let calculator = NextClassCalculator(
            modelContext: context,
            schoolDayEngine: schoolDayEngine
        )

        let calendar = Calendar.current
        // Pazartesi 2. dersten sonra (10:30) → Salı 1. ders olmalı
        let mondayAfterClasses = calendar.date(
            from: DateComponents(year: 2025, month: 9, day: 15, hour: 10, minute: 30))!

        let nextClass = await calculator.nextClass(from: mondayAfterClasses)

        XCTAssertNotNil(nextClass, "Pazartesi dersleri bittikten sonra Salı dersi bulunmalı")
        XCTAssertEqual(nextClass?.period.title, "1. Ders")
    }

    func testNextClass_NoClassesInDB() async throws {
        // Tüm session'ları sil
        let descriptor = FetchDescriptor<ClassSession>()
        let sessions = try context.fetch(descriptor)
        sessions.forEach { context.delete($0) }
        try context.save()

        let calculator = NextClassCalculator(
            modelContext: context,
            schoolDayEngine: schoolDayEngine
        )

        let calendar = Calendar.current
        let mondayMorning = calendar.date(
            from: DateComponents(year: 2025, month: 9, day: 15, hour: 8, minute: 0))!

        let nextClass = await calculator.nextClass(from: mondayMorning)

        XCTAssertNil(nextClass, "Session yokken nil dönmeli")
    }

    func testNextClass_OnWeekend_ReturnsWeekdayClass() async {
        let calculator = NextClassCalculator(
            modelContext: context,
            schoolDayEngine: schoolDayEngine
        )

        let calendar = Calendar.current
        // Pazar sabahı (2025-09-21) → Pazartesi dersine geçmeli
        let sundayMorning = calendar.date(
            from: DateComponents(year: 2025, month: 9, day: 21, hour: 8, minute: 0))!

        let nextClass = await calculator.nextClass(from: sundayMorning)

        XCTAssertNotNil(nextClass, "Pazar'dan sonra hafta içi dersi bulunmalı")
    }
}
