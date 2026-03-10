import Foundation
import SwiftUI

struct SharedWidgetSession: Codable, Identifiable {
    var id: UUID = UUID()
    let title: String
    let symbolName: String
    let colorHex: String
    let startTime: Date
    let endTime: Date
}

struct SharedWidgetData: Codable {
    let nextClassTitle: String
    let nextClassStart: Date
    let todaysCount: Int
    let todaySessions: [SharedWidgetSession]
    let itemsCount: Int
    
    static func readFromAppGroup() -> SharedWidgetData? {
        let identifier = "group.com.teacherplanner.shared"
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else { return nil }
        let fileURL = container.appendingPathComponent("widget_summary.json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(SharedWidgetData.self, from: data)
    }
}

enum WidgetSampleColors {
    static let warmAccent = Color.orange
    static let primary = Color.blue
    static let accent = Color.green
    static let tertiary = Color.purple
}

struct WidgetSampleCourse {
    let title: String
    let symbolName: String
    let color: Color
    let room: String?

    static let demoCourses: [WidgetSampleCourse] = [
        .init(
            title: "Fen Bilimleri", symbolName: "flask.fill", color: WidgetSampleColors.warmAccent,
            room: "203"),
        .init(
            title: "Matematik", symbolName: "function", color: WidgetSampleColors.primary,
            room: "101"),
        .init(
            title: "Türkçe", symbolName: "book.closed.fill", color: WidgetSampleColors.accent,
            room: "210"),
        .init(
            title: "Beden Eğitimi", symbolName: "figure.run", color: WidgetSampleColors.tertiary,
            room: nil),
    ]
}

struct WidgetSampleSession: Identifiable {
    let id = UUID()
    let course: WidgetSampleCourse
    let periodText: String
    let startTime: Date
    let endTime: Date

    static func sampleSessions() -> [WidgetSampleSession] {
        let calendar = Calendar.current
        let today = Date()

        let times: [(start: Date, end: Date)] = [
            (
                calendar.date(bySettingHour: 8, minute: 40, second: 0, of: today)!,
                calendar.date(bySettingHour: 9, minute: 20, second: 0, of: today)!
            ),
            (
                calendar.date(bySettingHour: 9, minute: 30, second: 0, of: today)!,
                calendar.date(bySettingHour: 10, minute: 10, second: 0, of: today)!
            ),
            (
                calendar.date(bySettingHour: 10, minute: 25, second: 0, of: today)!,
                calendar.date(bySettingHour: 11, minute: 5, second: 0, of: today)!
            ),
        ]

        return zip(WidgetSampleCourse.demoCourses, times).enumerated().map { index, pair in
            WidgetSampleSession(
                course: pair.0,
                periodText: "\(index + 1). Ders",
                startTime: pair.1.start,
                endTime: pair.1.end
            )
        }
    }
}

struct WidgetSampleSummary {
    let nextClassTitle: String
    let nextClassStart: Date
    let todaysLessonCount: Int
    let highlightColor: Color

    static let livePreview: WidgetSampleSummary = {
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: 10, minute: 25, second: 0, of: Date()) ?? Date()
        return WidgetSampleSummary(
            nextClassTitle: "6-A Matematik",
            nextClassStart: start,
            todaysLessonCount: 4,
            highlightColor: WidgetSampleColors.primary
        )
    }()
}
