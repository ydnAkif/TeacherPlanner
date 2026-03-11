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
    let todayScheduleProvider: any TodayScheduleProviding
    let weeklyScheduleBuilder: any WeeklyScheduleBuilding
    let plannerRepository: any PlannerRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let semesterRepository: any SemesterRepositoryProtocol
    let notificationScheduler: any NotificationScheduling
    let router: AppRouter

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

        self.courseRepository = CourseRepository(modelContext: modelContext)
        self.semesterRepository = SemesterRepository(modelContext: modelContext)
        self.plannerRepository = PlannerRepository(modelContext: modelContext)

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
