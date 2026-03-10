//
//  PlannerItemTests.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 10.03.2026.
//

import XCTest

@testable import TeacherPlanner

final class PlannerItemTests: XCTestCase {

    // MARK: - Priority Display

    func testPriorityDisplay_High() {
        let item = PlannerItem(title: "Test", priority: 1)
        XCTAssertEqual(item.priorityDisplay, "Yüksek")
    }

    func testPriorityDisplay_Medium() {
        let item = PlannerItem(title: "Test", priority: 2)
        XCTAssertEqual(item.priorityDisplay, "Orta")
    }

    func testPriorityDisplay_Low() {
        let item = PlannerItem(title: "Test", priority: 3)
        XCTAssertEqual(item.priorityDisplay, "Düşük")
    }

    func testPriorityDisplay_Invalid() {
        let item = PlannerItem(title: "Test", priority: 99)
        XCTAssertEqual(item.priorityDisplay, "-")
    }

    // MARK: - isOverdue

    func testIsOverdue_PastDueDate_NotCompleted() {
        let pastDate = Date().addingTimeInterval(-86400) // Dün
        let item = PlannerItem(title: "Test", dueDate: pastDate, completed: false)
        XCTAssertTrue(item.isOverdue, "Geçmiş tarihli tamamlanmamış görev overdue olmalı")
    }

    func testIsOverdue_PastDueDate_Completed() {
        let pastDate = Date().addingTimeInterval(-86400)
        let item = PlannerItem(title: "Test", dueDate: pastDate, completed: true)
        XCTAssertFalse(item.isOverdue, "Tamamlanmış görev overdue sayılmamalı")
    }

    func testIsOverdue_FutureDueDate() {
        let futureDate = Date().addingTimeInterval(86400) // Yarın
        let item = PlannerItem(title: "Test", dueDate: futureDate, completed: false)
        XCTAssertFalse(item.isOverdue, "Gelecek tarihli görev overdue olmamalı")
    }

    func testIsOverdue_NoDueDate() {
        let item = PlannerItem(title: "Test", dueDate: nil, completed: false)
        XCTAssertFalse(item.isOverdue, "Due date olmayan görev overdue olmamalı")
    }

    // MARK: - PlannerItemType

    func testPlannerItemType_DisplayNames() {
        XCTAssertEqual(PlannerItemType.note.displayName, "Not")
        XCTAssertEqual(PlannerItemType.homework.displayName, "Ödev")
        XCTAssertEqual(PlannerItemType.reminder.displayName, "Hatırlatma")
        XCTAssertEqual(PlannerItemType.exam.displayName, "Sınav")
        XCTAssertEqual(PlannerItemType.material.displayName, "Materyal")
        XCTAssertEqual(PlannerItemType.task.displayName, "Görev")
    }

    func testPlannerItemType_CaseIterable_AllCasesPresent() {
        let expectedCount = 6
        XCTAssertEqual(PlannerItemType.allCases.count, expectedCount, "6 tip olmalı")
    }
}
