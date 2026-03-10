import Foundation
import SwiftData
import SwiftUI

/// Uygulamanın merkezi Dependency Injection konteyneri.
/// Tüm servisler protokol tipleriyle tutularak test edilebilirlik sağlanır.
@MainActor
@Observable
final class AppEnvironment {

    // MARK: - Services (Protocol Types)
    let schoolDayEngine: any SchoolDayCalculating
    let notificationManager: NotificationManager
    let nextClassCalculator: any NextClassProviding
    let todayScheduleProvider: any TodayScheduleProviding
    let weeklyScheduleBuilder: WeeklyScheduleBuilder

    // MARK: - Init
    init(modelContext: ModelContext) {
        let engine = SchoolDayEngine(modelContext: modelContext)
        self.schoolDayEngine = engine
        self.notificationManager = NotificationManager()
        self.nextClassCalculator = NextClassCalculator(
            modelContext: modelContext,
            schoolDayEngine: engine
        )
        self.todayScheduleProvider = TodayScheduleProvider(
            modelContext: modelContext,
            schoolDayEngine: engine
        )
        self.weeklyScheduleBuilder = WeeklyScheduleBuilder(modelContext: modelContext)
    }
}

