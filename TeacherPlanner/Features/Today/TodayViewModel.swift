import Combine
import Foundation
import SwiftData
import SwiftUI

/// Today ekranı için ViewModel
@MainActor
final class TodayViewModel: ObservableObject {
    private var plannerRepository: (any PlannerRepositoryProtocol)?
    private var schoolDayEngine: (any SchoolDayCalculating)?
    private var nextClassCalculator: (any NextClassProviding)?
    private var todayScheduleProvider: (any TodayScheduleProviding)?

    // State
    @Published var activeSemester: Semester?
    @Published var nextClassResult: NextClassResult?
    @Published var todayClasses: [(session: ClassSession, period: PeriodDefinition)] = []
    @Published var todayPlannerItems: [PlannerItem] = []
    @Published var currentClass: (session: ClassSession, period: PeriodDefinition)?
    @Published var isLoading: Bool = false
    @Published var isInitialized: Bool = false
    @Published var appError: AppError?

    init() {}

    func setup(
        schoolDayEngine: any SchoolDayCalculating,
        nextClassCalculator: any NextClassProviding,
        todayScheduleProvider: any TodayScheduleProviding,
        plannerRepository: any PlannerRepositoryProtocol
    ) async {
        guard !isInitialized else { return }

        self.schoolDayEngine = schoolDayEngine
        self.nextClassCalculator = nextClassCalculator
        self.todayScheduleProvider = todayScheduleProvider
        self.plannerRepository = plannerRepository

        self.isInitialized = true
        await loadData()
    }

    /// Verileri yükle
    func loadData() async {
        guard isInitialized,
              let engine = schoolDayEngine,
              let nextCalc = nextClassCalculator,
              let scheduleProvider = todayScheduleProvider else { return }

        isLoading = true
        appError = nil

        let today = Date()
        let semester = engine.getActiveSemester()
        activeSemester = semester

        guard let semester else {
            nextClassResult = nil
            todayClasses = []
            currentClass = nil
            isLoading = false
            await loadTodayPlannerItems()
            return
        }

        let isInstructionalDay = engine.isInstructionalDay(today, semester: semester)

        if isInstructionalDay {
            todayClasses = await scheduleProvider.todayClassesWithPeriods(semester: semester)
            currentClass = await scheduleProvider.currentClass(semester: semester)
        } else {
            todayClasses = []
            currentClass = nil
        }

        nextClassResult = await nextCalc.nextClass(from: today, semester: semester)

        await loadTodayPlannerItems()
        isLoading = false
    }

    /// Bugünkü planner itemları yükle
    private func loadTodayPlannerItems() async {
        guard let repo = plannerRepository else { return }

        let result = await repo.fetchTodayItems()
        todayPlannerItems = result.get(or: [])
        if case .failure(let error) = result {
            appError = error
        }
    }

    /// Tamamlanma durumunu toggle et
    func toggleCompleted(_ item: PlannerItem) {
        guard let repo = plannerRepository else { return }

        Task {
            let result = await repo.toggleCompleted(item)
            if case .failure(let error) = result {
                appError = error
                return
            }
            await loadTodayPlannerItems()
        }
    }

    /// Tarih gösterimi
    var dateDisplay: String {
        Date().fullDateString
    }

    /// Bugün ders var mı?
    var hasTodayClasses: Bool {
        !todayClasses.isEmpty
    }
}
