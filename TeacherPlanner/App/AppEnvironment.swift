import Foundation
import SwiftData
import SwiftUI

/// Uygulamanın merkezi Dependency Injection konteyneri.
@MainActor
@Observable
final class AppEnvironment {

    // MARK: - Services
    let schoolDayEngine: any SchoolDayCalculating
    let notificationManager: NotificationManager
    let nextClassCalculator: any NextClassProviding
    let todayScheduleProvider: TodayScheduleProvider
    let weeklyScheduleBuilder: WeeklyScheduleBuilder
    let router: AppRouter
    let notificationScheduler: NotificationScheduler

    // MARK: - Init
    init(modelContext: ModelContext) {
        let engine = SchoolDayEngine(modelContext: modelContext)
        self.schoolDayEngine = engine
        self.notificationManager = NotificationManager()

        let nextClass = NextClassCalculator(
            modelContext: modelContext,
            schoolDayEngine: engine
        )
        self.nextClassCalculator = nextClass

        let todaySchedule = TodayScheduleProvider(
            modelContext: modelContext,
            schoolDayEngine: engine
        )
        self.todayScheduleProvider = todaySchedule

        let sched = NotificationScheduler(
            modelContext: modelContext,
            schoolDayEngine: engine,
            notificationManager: notificationManager
        )
        self.notificationScheduler = sched

        self.router = AppRouter()
        self.weeklyScheduleBuilder = WeeklyScheduleBuilder(modelContext: modelContext)
    }
}

// MARK: - Environment
extension EnvironmentValues {
    @Entry var appEnvironment: AppEnvironment?
    @Entry var isUITesting: Bool = false
}
