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
    let weeklyScheduleBuilder: any WeeklyScheduleBuilding
    let todayOverviewUseCase: any TodayOverviewUseCaseProtocol
    let plannerRepository: any PlannerRepositoryProtocol
    let router: AppRouter
    let courseRepository: any CourseRepositoryProtocol
    let semesterRepository: any SemesterRepositoryProtocol
    let plannerTaskUseCase: any PlannerTaskUseCaseProtocol
    let notificationUseCase: any NotificationUseCaseProtocol
    let notificationScheduler: any NotificationScheduling

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
        
        let courseRepo = CourseRepository(modelContext: modelContext)
        let semesterRepo = SemesterRepository(modelContext: modelContext)
        self.courseRepository = courseRepo
        self.semesterRepository = semesterRepo
        
        let plannerRepo = PlannerRepository(modelContext: modelContext)
        self.plannerRepository = plannerRepo
        
        let sched = NotificationScheduler(
            modelContext: modelContext,
            schoolDayEngine: engine,
            notificationManager: notificationManager
        )
        self.notificationScheduler = sched
        
        self.todayOverviewUseCase = TodayOverviewUseCase(
            schoolDayEngine: engine,
            nextClassCalculator: nextClass,
            todayScheduleProvider: todaySchedule
        )
        
        self.plannerTaskUseCase = PlannerTaskUseCase(repository: plannerRepo)
        self.notificationUseCase = NotificationUseCase(scheduler: sched)
        
        self.router = AppRouter()
        self.weeklyScheduleBuilder = WeeklyScheduleBuilder(modelContext: modelContext)
    }
}

// MARK: - Environment
extension EnvironmentValues {
    @Entry var appEnvironment: AppEnvironment?
}

