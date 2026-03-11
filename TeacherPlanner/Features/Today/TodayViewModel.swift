//
//  TodayViewModel.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

/// Today ekranı için ViewModel
@MainActor
class TodayViewModel: ObservableObject {
    private var modelContext: ModelContext?
    private var taskUseCase: (any PlannerTaskUseCaseProtocol)?

    // Use Case
    private var overviewUseCase: (any TodayOverviewUseCaseProtocol)?

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
        overviewUseCase: any TodayOverviewUseCaseProtocol,
        taskUseCase: any PlannerTaskUseCaseProtocol
    ) async {
        guard !isInitialized else { return }
        
        self.modelContext = modelContext
        self.overviewUseCase = overviewUseCase
        self.taskUseCase = taskUseCase
        
        self.isInitialized = true
        await loadData()
    }

    /// Verileri yükle
    func loadData() async {
        guard isInitialized, let useCase = overviewUseCase else { return }
              
        isLoading = true
        appError = nil

        let data = await useCase.execute()
        
        activeSemester = data.activeSemester
        nextClassResult = data.nextClass
        todayClasses = data.todayClasses
        currentClass = data.currentClass

        // Bugünkü planner itemları al
        await loadTodayPlannerItems()

        isLoading = false
    }

    /// Bugünkü planner itemları yükle
    private func loadTodayPlannerItems() async {
        guard let useCase = taskUseCase else { return }
        
        do {
            todayPlannerItems = try await useCase.fetchTodayItems()
        } catch {
            appError = AppError.from(error: error)
            todayPlannerItems = []
        }
    }

    /// Tamamlanma durumunu toggle et
    func toggleCompleted(_ item: PlannerItem) {
        guard let useCase = taskUseCase else { return }
        
        Task {
            do {
                try await useCase.toggleCompleted(item)
                await loadTodayPlannerItems()
            } catch {
                appError = AppError.from(error: error)
            }
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
