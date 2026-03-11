import XCTest

@testable import TeacherPlanner

@MainActor
final class NotificationManagerTests: XCTestCase {

    func testReminderDate_UsesTargetDayAndMinutesBefore() {
        let calendar = Calendar(identifier: .gregorian)
        let basePeriodDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 8, minute: 40))!
        let period = PeriodDefinition(
            title: "1. Ders",
            startTime: basePeriodDate,
            endTime: calendar.date(byAdding: .minute, value: 40, to: basePeriodDate)!,
            orderIndex: 1
        )

        let targetDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 16, hour: 12, minute: 0))!
        let reminder = NotificationManager.reminderDate(
            for: period,
            on: targetDate,
            minutesBefore: 15,
            calendar: calendar
        )

        let expected = calendar.date(from: DateComponents(year: 2026, month: 3, day: 16, hour: 8, minute: 25))!
        XCTAssertEqual(reminder, expected)
    }

    func testReminderIdentifier_ContainsDateKey() {
        let calendar = Calendar(identifier: .gregorian)
        let sessionID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 11))!

        let identifier = NotificationManager.reminderIdentifier(for: sessionID, on: date, calendar: calendar)

        XCTAssertEqual(identifier, "class_AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE_20260311")
    }
}
