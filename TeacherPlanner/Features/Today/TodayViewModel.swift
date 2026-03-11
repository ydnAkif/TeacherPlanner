//
//  TodayViewModel.swift
//  TeacherPlanner
//

import Foundation
import Observation
import SwiftData
import SwiftUI

/// Today ekranı için ViewModel
@MainActor
@Observable
final class TodayViewModel {
    private let modelContext: ModelContext
    private let schoolDayEngine: any SchoolDayCalculating
    private let nextClassCalculator: any NextClassProviding
    private let todayScheduleProvider: TodayScheduleProvider

    // State
    var activeSemester: Semester?
    var nextClassResult: NextClassResult?
    var todayClasses: [(session: ClassSession, period: PeriodDefinition)] = []
    var todayPlannerItems: [PlannerItem] = []
    var currentClass: (session: ClassSession, period: PeriodDefinition)?
    var isLoading: Bool = false
    var appError: AppError?

    init(
        modelContext: ModelContext,
        schoolDayEngine: any SchoolDayCalculating,
        nextClassCalculator: any NextClassProviding,
        todayScheduleProvider: TodayScheduleProvider
    ) {
        self.modelContext = modelContext
        self.schoolDayEngine = schoolDayEngine
        self.nextClassCalculator = nextClassCalculator
        self.todayScheduleProvider = todayScheduleProvider
    }

    /// Verileri yükle
    func loadData() async {
        isLoading = true
        appError = nil

        let today = Date()
        let semester = schoolDayEngine.getActiveSemester()
        activeSemester = semester

        guard let semester else {
            nextClassResult = nil
            todayClasses = []
            currentClass = nil
            isLoading = false
            loadTodayPlannerItems()
            return
        }

        let isInstructionalDay = schoolDayEngine.isInstructionalDay(today, semester: semester)

        if isInstructionalDay {
            todayClasses = await todayScheduleProvider.todayClassesWithPeriods(semester: semester)
            currentClass = await todayScheduleProvider.currentClass(semester: semester)
        } else {
            todayClasses = []
            currentClass = nil
        }

        nextClassResult = await nextClassCalculator.nextClass(from: today, semester: semester)

        loadTodayPlannerItems()
        isLoading = false
    }

    /// Bugünkü planner itemları yükle (ModelContext üzerinden doğrudan fetch)
    private func loadTodayPlannerItems() {
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

        let result = modelContext.fetchResult(
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
        item.completed.toggle()
        let result = modelContext.saveResult("TodayViewModel: toggleCompleted failed")
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
