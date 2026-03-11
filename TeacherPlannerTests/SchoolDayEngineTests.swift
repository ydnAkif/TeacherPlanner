//
//  SchoolDayEngineTests.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import XCTest

@testable import TeacherPlanner

final class SchoolDayEngineTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var semester: Semester!

    override func setUp() async throws {
        let newContainer = try await MainActor.run {
            try ModelContainerFactory.createPreview()
        }
        await MainActor.run {
            container = newContainer
            context = container.mainContext
        }

        try await MainActor.run {
            // Sample semester ekle (Pazartesi 2025-09-01, Cuma 2026-01-31)
            let calendar = Calendar.current
            let newSemester = Semester(
                name: "Test Dönem",
                startDate: calendar.date(from: DateComponents(year: 2025, month: 9, day: 1))!,
                endDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 31))!,
                weekendRule: .saturdaySunday,
                isActive: true
            )
            context.insert(newSemester)
            try context.save()
            semester = newSemester
        }
    }

    override func tearDown() async throws {
        await MainActor.run {
            context = nil
            semester = nil
        }
    }

    // MARK: - Mevcut Testler

    func testIsInstructionalDay_WithinSemester() async {
        await MainActor.run {
            let engine = SchoolDayEngine(modelContext: context)
            let calendar = Calendar.current

            // Dönem içinde bir hafta içi gün
            let testDate = calendar.date(
                from: DateComponents(year: 2025, month: 9, day: 15, hour: 12))!

            let result = engine.isInstructionalDay(testDate)
            XCTAssertTrue(result, "Dönem içindeki hafta içi gün öğretim günü olmalı")
        }
    }

    func testIsInstructionalDay_Weekend() async {
        await MainActor.run {
            let engine = SchoolDayEngine(modelContext: context)
            let calendar = Calendar.current

            // Pazar günü
            let sundayDate = calendar.date(
                from: DateComponents(year: 2025, month: 9, day: 7, hour: 12))!

            let result = engine.isInstructionalDay(sundayDate)
            XCTAssertFalse(result, "Pazar günü öğretim günü olmamalı")
        }
    }

    func testIsInstructionalDay_OutsideSemester() async {
        await MainActor.run {
            let engine = SchoolDayEngine(modelContext: context)
            let calendar = Calendar.current

            // Dönem dışı
            let holidayDate = calendar.date(
                from: DateComponents(year: 2025, month: 7, day: 15, hour: 12))!

            let result = engine.isInstructionalDay(holidayDate)
            XCTAssertFalse(result, "Dönem dışı gün öğretim günü olmamalı")
        }
    }

    func testGetActiveSemester() async {
        await MainActor.run {
            let engine = SchoolDayEngine(modelContext: context)

            let activeSemester = engine.getActiveSemester()

            XCTAssertNotNil(activeSemester)
            XCTAssertEqual(activeSemester?.name, "Test Dönem")
        }
    }

    // MARK: - Yeni Edge Case Testleri

    func testIsInstructionalDay_WithSkippedDay() async throws {
        try await MainActor.run {
            let engine = SchoolDayEngine(modelContext: context)
            let calendar = Calendar.current

            // Hafta içi bir günü manuel olarak skip et
            let skippedDate = calendar.date(from: DateComponents(year: 2025, month: 10, day: 6))!  // Pazartesi
            let skippedDay = SkippedDay(date: skippedDate, reason: "Test Tatili", type: .holiday)
            semester.skippedDays.append(skippedDay)
            context.insert(skippedDay)
            try context.save()

            let result = engine.isInstructionalDay(skippedDate, semester: semester)
            XCTAssertFalse(result, "Skip edilmiş gün öğretim günü olmamalı")
        }
    }

    func testIsInstructionalDay_OnSemesterEndBoundary() async {
        await MainActor.run {
            let engine = SchoolDayEngine(modelContext: context)
            let calendar = Calendar.current

            // Dönemin son günü: 2026-01-31 Cumartesi → hafta sonu, sınırda değil
            // Son hafta içi günü: 2026-01-30 Cuma
            let lastFriday = calendar.date(
                from: DateComponents(year: 2026, month: 1, day: 30, hour: 12))!

            let result = engine.isInstructionalDay(lastFriday, semester: semester)
            XCTAssertTrue(result, "Dönemin son haftasındaki Cuma günü öğretim günü olmalı")
        }
    }

    func testGetInstructionalDays_InRange() async {
        await MainActor.run {
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
    }

    func testNextInstructionalDay_FromFriday() async {
        await MainActor.run {
            let engine = SchoolDayEngine(modelContext: context)
            let calendar = Calendar.current

            // Cuma öğleden sonra
            let friday = calendar.date(
                from: DateComponents(year: 2025, month: 9, day: 19, hour: 16))!

            let nextDay = engine.nextInstructionalDay(after: friday, semester: semester)

            XCTAssertNotNil(nextDay)
            // Sonraki öğretim günü Pazartesi (22 Eylül) olmalı
            let expectedMonday = calendar.date(from: DateComponents(year: 2025, month: 9, day: 22))!
            let isSameDay = calendar.isDate(nextDay!, inSameDayAs: expectedMonday)
            XCTAssertTrue(isSameDay, "Cuma'dan sonraki öğretim günü Pazartesi olmalı")
        }
    }
}
