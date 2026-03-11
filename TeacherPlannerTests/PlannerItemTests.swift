//
//  PlannerItemTests.swift
//  TeacherPlanner
//

import XCTest

@testable import TeacherPlanner

final class PlannerItemTests: XCTestCase {

    // MARK: - Priority Display

    func testPriorityDisplay_High() {
        let item = PlannerItem(title: "Test", priority: .high)
        XCTAssertEqual(item.priorityDisplay, "Yüksek")
    }

    func testPriorityDisplay_Medium() {
        let item = PlannerItem(title: "Test", priority: .medium)
        XCTAssertEqual(item.priorityDisplay, "Orta")
    }

    func testPriorityDisplay_Low() {
        let item = PlannerItem(title: "Test", priority: .low)
        XCTAssertEqual(item.priorityDisplay, "Düşük")
    }

    func testPriority_AllCases() {
        XCTAssertEqual(Priority.allCases.count, 3, "3 öncelik seviyesi olmalı")
        XCTAssertEqual(Priority.high.rawValue, 1)
        XCTAssertEqual(Priority.medium.rawValue, 2)
        XCTAssertEqual(Priority.low.rawValue, 3)
    }

    func testPriority_DisplayNames() {
        XCTAssertEqual(Priority.high.displayName, "Yüksek")
        XCTAssertEqual(Priority.medium.displayName, "Orta")
        XCTAssertEqual(Priority.low.displayName, "Düşük")
    }

    func testPriority_BadgeLabels() {
        XCTAssertEqual(Priority.high.badgeLabel, "Y")
        XCTAssertEqual(Priority.medium.badgeLabel, "O")
        XCTAssertEqual(Priority.low.badgeLabel, "D")
    }

    // MARK: - isOverdue

    func testIsOverdue_PastDueDate_NotCompleted() {
        let pastDate = Date().addingTimeInterval(-86400)
        let item = PlannerItem(title: "Test", dueDate: pastDate, completed: false)
        XCTAssertTrue(item.isOverdue, "Geçmiş tarihli tamamlanmamış görev overdue olmalı")
    }

    func testIsOverdue_PastDueDate_Completed() {
        let pastDate = Date().addingTimeInterval(-86400)
        let item = PlannerItem(title: "Test", dueDate: pastDate, completed: true)
        XCTAssertFalse(item.isOverdue, "Tamamlanmış görev overdue sayılmamalı")
    }

    func testIsOverdue_FutureDueDate() {
        let futureDate = Date().addingTimeInterval(86400)
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
        XCTAssertEqual(PlannerItemType.allCases.count, 6, "6 tip olmalı")
    }

    func testPlannerItemType_SystemImages() {
        XCTAssertFalse(PlannerItemType.note.systemImage.isEmpty)
        XCTAssertFalse(PlannerItemType.homework.systemImage.isEmpty)
        XCTAssertFalse(PlannerItemType.reminder.systemImage.isEmpty)
        XCTAssertFalse(PlannerItemType.exam.systemImage.isEmpty)
        XCTAssertFalse(PlannerItemType.material.systemImage.isEmpty)
        XCTAssertFalse(PlannerItemType.task.systemImage.isEmpty)
    }

    // MARK: - Default Values

    func testPlannerItem_DefaultPriority() {
        let item = PlannerItem(title: "Test")
        XCTAssertEqual(item.priority, .medium, "Varsayılan öncelik orta olmalı")
    }

    func testPlannerItem_DefaultCompleted() {
        let item = PlannerItem(title: "Test")
        XCTAssertFalse(item.completed, "Yeni görev tamamlanmamış olmalı")
    }

    func testPlannerItem_DefaultType() {
        let item = PlannerItem(title: "Test")
        XCTAssertEqual(item.type, .note, "Varsayılan tip not olmalı")
    }
}
