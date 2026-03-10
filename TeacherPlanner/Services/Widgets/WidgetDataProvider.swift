import Foundation
import SwiftData
import WidgetKit

@MainActor
protocol WidgetScheduleProviding {
    func fetchTodayClasses(context: ModelContext) throws -> [ClassSession]
    func fetchUpcomingSessions(context: ModelContext, limit: Int) throws -> [ClassSession]
    func cachedSummary() -> SharedWidgetData?
    func cache(summary: SharedWidgetData)
}

/// Shared cache helper for widgets that rely on App Group shared container.
/// Write summary data to a JSON file so extension/s can read it quickly without hitting SwiftData on every timeline refresh.
final class WidgetAppGroupCache {
    private let fileURL: URL

    init(appGroupIdentifier: String = "group.com.teacherplanner.shared") {
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        self.fileURL =
            container?
            .appendingPathComponent("widget_summary.json")
            ?? FileManager.default.temporaryDirectory.appendingPathComponent("widget_summary.json")
    }

    func readSummary() -> SharedWidgetData? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(SharedWidgetData.self, from: data)
    }

    func writeSummary(_ summary: SharedWidgetData) {
        guard let data = try? JSONEncoder().encode(summary) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

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
}

final class WidgetDataProvider: WidgetScheduleProviding {
    private let cache = WidgetAppGroupCache()
    
    @MainActor
    static let sharedContainer: ModelContainer? = {
        do {
            let schema = Schema([
                Course.self,
                PeriodDefinition.self,
                ClassSession.self,
                PlannerItem.self,
                // Semester and SkippedDay might be needed for full schema match if they are in the same DB
                Semester.self,
                SkippedDay.self
            ])
            let sharedStoreURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.teacherplanner.shared"
            )?.appendingPathComponent("TeacherPlanner.sqlite")
            
            let fallbackURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TeacherPlanner.sqlite")
            
            let configuration = ModelConfiguration(
                schema: schema,
                url: sharedStoreURL ?? fallbackURL,
                allowsSave: false
            )
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("WidgetDataProvider sharedContainer error: \(error)")
            return nil
        }
    }()
    
    @MainActor
    static var sharedContext: ModelContext? {
        guard let container = sharedContainer else { return nil }
        return ModelContext(container)
    }

    func fetchTodayClasses(context: ModelContext) throws -> [ClassSession] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let descriptor = FetchDescriptor<ClassSession>(
            predicate: #Predicate { $0.weekday == weekday },
            sortBy: [SortDescriptor(\.periodOrder)]
        )
        return try context.fetch(descriptor)
    }

    func fetchUpcomingSessions(context: ModelContext, limit: Int = 5) throws -> [ClassSession]
    {
        let descriptor = FetchDescriptor<ClassSession>(
            sortBy: [SortDescriptor(\.weekday), SortDescriptor(\.periodOrder)]
        )
        let sessions = try context.fetch(descriptor)
        return Array(sessions.prefix(limit))
    }

    func cachedSummary() -> SharedWidgetData? {
        cache.readSummary()
    }

    func cache(summary: SharedWidgetData) {
        cache.writeSummary(summary)
    }

    /// Provides sample data for SwiftUI previews and placeholder timelines.
    static func sampleNextClass() -> ClassSession {
        ClassSession(
            weekday: Calendar.current.component(.weekday, from: Date()),
            periodOrder: 1,
            course: Course(
                title: "5-C Fen Bilimleri", colorHex: "#FF9500", symbolName: "flask.fill"),
            period: PeriodDefinition(
                title: "1. Ders",
                startTime: Calendar.current.date(
                    bySettingHour: 08, minute: 40, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 09, minute: 20, second: 0, of: Date())
                    ?? Date(),
                orderIndex: 1
            ),
            room: "203"
        )
    }

    static func sampleSummary() -> SharedWidgetData {
        SharedWidgetData(
            nextClassTitle: "5-C Fen Bilimleri",
            nextClassStart: Calendar.current.date(
                bySettingHour: 8, minute: 40, second: 0, of: Date()) ?? Date(),
            todaysCount: 4,
            todaySessions: [
                SharedWidgetSession(title: "5-C Fen Bilimleri", symbolName: "flask.fill", colorHex: "#FF9500", startTime: Date(), endTime: Date().addingTimeInterval(2400))
            ],
            itemsCount: 2
        )
    }
}
