//
//  SchoolDayEngineTests.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import XCTest

@testable import TeacherPlanner

@MainActor
final class SchoolDayEngineTests: XCTestCase {
    var context: ModelContext!
    var semester: Semester!

    override func setUp() async throws {
        let container = try await ModelContainerFactory.createPreview()
        context = container.mainContext

        // Sample semester ekle (Pazartesi 2025-09-01, Cuma 2026-01-31)
        let calendar = Calendar.current
        semester = Semester(
            name: "Test Dönem",
            startDate: calendar.date(from: DateComponents(year: 2025, month: 9, day: 1))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 31))!,
            weekendRule: .saturdaySunday,
            isActive: true
        )
        context.insert(semester)
        try context.save()
    }

    // MARK: - Mevcut Testler

    func testIsInstructionalDay_WithinSemester() {
        let engine = SchoolDayEngine(modelContext: context)
        let calendar = Calendar.current

        // Dönem içinde bir hafta içi gün
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 9, day: 15, hour: 12))!

        let result = engine.isInstructionalDay(testDate)
        XCTAssertTrue(result, "Dönem içindeki hafta içi gün öğretim günü olmalı")
    }

    func testIsInstructionalDay_Weekend() {
        let engine = SchoolDayEngine(modelContext: context)
        let calendar = Calendar.current

        // Pazar günü
        let sundayDate = calendar.date(
            from: DateComponents(year: 2025, month: 9, day: 7, hour: 12))!

        let result = engine.isInstructionalDay(sundayDate)
        XCTAssertFalse(result, "Pazar günü öğretim günü olmamalı")
    }

    func testIsInstructionalDay_OutsideSemester() {
        let engine = SchoolDayEngine(modelContext: context)
        let calendar = Calendar.current

        // Dönem dışı
        let holidayDate = calendar.date(
            from: DateComponents(year: 2025, month: 7, day: 15, hour: 12))!

        let result = engine.isInstructionalDay(holidayDate)
        XCTAssertFalse(result, "Dönem dışı gün öğretim günü olmamalı")
    }

    func testGetActiveSemester() async {
        let engine = SchoolDayEngine(modelContext: context)

        let semester = engine.getActiveSemester()

        XCTAssertNotNil(semester)
        XCTAssertEqual(semester?.name, "Test Dönem")
    }

    // MARK: - Yeni Edge Case Testleri

    func testIsInstructionalDay_WithSkippedDay() throws {
        let engine = SchoolDayEngine(modelContext: context)
        let calendar = Calendar.current

        // Hafta içi bir günü manuel olarak skip et
        let skippedDate = calendar.date(from: DateComponents(year: 2025, month: 10, day: 6))! // Pazartesi
        let skippedDay = SkippedDay(date: skippedDate, reason: "Test Tatili", type: .holiday)
        semester.skippedDays.append(skippedDay)
        context.insert(skippedDay)
        try context.save()

        let result = engine.isInstructionalDay(skippedDate, semester: semester)
        XCTAssertFalse(result, "Skip edilmiş gün öğretim günü olmamalı")
    }

    func testIsInstructionalDay_OnSemesterEndBoundary() {
        let engine = SchoolDayEngine(modelContext: context)
        let calendar = Calendar.current

        // Dönemin son günü: 2026-01-31 Cumartesi → hafta sonu, sınırda değil
        // Son hafta içi günü: 2026-01-30 Cuma
        let lastFriday = calendar.date(from: DateComponents(year: 2026, month: 1, day: 30, hour: 12))!

        let result = engine.isInstructionalDay(lastFriday, semester: semester)
        XCTAssertTrue(result, "Dönemin son haftasındaki Cuma günü öğretim günü olmalı")
    }

    func testGetInstructionalDays_InRange() {
        let engine = SchoolDayEngine(modelContext: context)
        let calendar = Calendar.current

        // Bir haftalık aralık: 2025-09-15 (Pzt) - 2025-09-19 (Cum)
        let start = calendar.date(from: DateComponents(year: 2025, month: 9, day: 15))!
        let end = calendar.date(from: DateComponents(year: 2025, month: 9, day: 19))!
        let range = DateInterval(start: start, end: end)

        let days = engine.getInstructionalDays(in: range, semester: semester)

        // Pzt, Salı, Çar, Per, Cum = 5 gün
        XCTAssertEqual(days.count, 5, "Tam bir hafta içinde 5 öğretim günü olmalı")
    }

    func testNextInstructionalDay_FromFriday() {
        let engine = SchoolDayEngine(modelContext: context)
        let calendar = Calendar.current

        // Cuma öğleden sonra
        let friday = calendar.date(from: DateComponents(year: 2025, month: 9, day: 19, hour: 16))!

        let nextDay = engine.nextInstructionalDay(after: friday, semester: semester)

        XCTAssertNotNil(nextDay)
        // Sonraki öğretim günü Pazartesi (22 Eylül) olmalı
        let expectedMonday = calendar.date(from: DateComponents(year: 2025, month: 9, day: 22))!
        let isSameDay = calendar.isDate(nextDay!, inSameDayAs: expectedMonday)
        XCTAssertTrue(isSameDay, "Cuma'dan sonraki öğretim günü Pazartesi olmalı")
    }
}

