import XCTest
@testable import TeacherPlanner

final class DateHelpersTests: XCTestCase {
    
    // MARK: - DateFormatter Tests
    
    func testShortTimeFormatter() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 3, day: 11, hour: 14, minute: 30)
        let date = calendar.date(from: components)!
        
        let result = date.shortTimeString
        // Locale dependent, usually "14:30" or "2:30 PM"
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("14") || result.contains("2"))
    }
    
    func testIsoDateFormatter() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 3, day: 11)
        let date = calendar.date(from: components)!
        
        let result = date.isoDateString
        XCTAssertEqual(result, "2026-03-11")
    }
    
    func testFullDateFormatter() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 3, day: 11) // 11 March 2026 is Wednesday
        let date = calendar.date(from: components)!
        
        let result = date.fullDateString
        // Turkish locale: "11 Mart 2026 Çarşamba"
        XCTAssertTrue(result.contains("Mart"))
        XCTAssertTrue(result.contains("2026"))
        XCTAssertTrue(result.contains("Çarşamba"))
    }
    
    // MARK: - Date Extension Tests
    
    func testSettingHourMinute() {
        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 11, hour: 10, minute: 0))!
        
        let newDate = baseDate.setting(hour: 18, minute: 45)
        XCTAssertNotNil(newDate)
        
        let newComponents = calendar.dateComponents([.hour, .minute], from: newDate!)
        XCTAssertEqual(newComponents.hour, 18)
        XCTAssertEqual(newComponents.minute, 45)
    }
    
    func testIsSameDay() {
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 11, hour: 10, minute: 0))!
        let date2 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 11, hour: 22, minute: 30))!
        let date3 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 12, hour: 10, minute: 0))!
        
        XCTAssertTrue(date1.isSameDay(as: date2))
        XCTAssertFalse(date1.isSameDay(as: date3))
    }
}
