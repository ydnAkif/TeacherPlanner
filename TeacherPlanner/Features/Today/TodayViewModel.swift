//
//  TodayViewModel.swift
//  TeacherPlanner
//

import Combine
import Foundation
import SwiftData
import SwiftUI

/// Today ekranı için ViewModel
@MainActor
final class TodayViewModel: ObservableObject {
    private var modelContext: ModelContext?
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
        modelContext: ModelContext,
        schoolDayEngine: any SchoolDayCalculating,
        nextClassCalculator: any NextClassProviding,
        todayScheduleProvider: any TodayScheduleProviding
    ) async {
        guard !isInitialized else { return }

        self.modelContext = modelContext
        self.schoolDayEngine = schoolDayEngine
        self.nextClassCalculator = nextClassCalculator
        self.todayScheduleProvider = todayScheduleProvider

        self.isInitialized = true
        await loadData()
    }

    /// Verileri yükle
    func loadData() async {
        guard isInitialized,
            let engine = schoolDayEngine,
            let nextCalc = nextClassCalculator,
            let scheduleProvider = todayScheduleProvider
        else { return }

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
            loadTodayPlannerItems()
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

        loadTodayPlannerItems()
        isLoading = false
    }

    /// Bugünkü planner itemları yükle (ModelContext üzerinden doğrudan fetch)
    private func loadTodayPlannerItems() {
        guard let context = modelContext else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        let descriptor = FetchDescriptor<PlannerItem>(
            predicate: #Predicate { item in
                if let dueDate = item.dueDate {
                    return dueDate >= today && dueDate < tomorrow
                } else {
                    return false
                }
            },
            sortBy: [
                SortDescriptor(\.createdAt)
            ]
        )

        let result = context.fetchResult(
            descriptor, failureMessage: "TodayViewModel: loadTodayPlannerItems failed")
        switch result {
        case .success(let items):
            todayPlannerItems = items
        case .failure(let error):
            appError = error
        }
    }

    /// Tamamlanma durumunu toggle et
    func toggleCompleted(_ item: PlannerItem) {
        guard let context = modelContext else { return }
        item.completed.toggle()
        let result = context.saveResult("TodayViewModel: toggleCompleted failed")
        if case .failure(let error) = result {
            appError = error
            return
        }
        loadTodayPlannerItems()
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
