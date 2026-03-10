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

    // Services
    private var schoolDayEngine: SchoolDayEngine?
    private var nextClassCalculator: NextClassCalculator?
    private var todayScheduleProvider: TodayScheduleProvider?

    // State
    @Published var activeSemester: Semester?
    @Published var nextClassResult: NextClassResult?
    @Published var todayClasses: [(session: ClassSession, period: PeriodDefinition)] = []
    @Published var todayPlannerItems: [PlannerItem] = []
    @Published var currentClass: (session: ClassSession, period: PeriodDefinition)?
    @Published var isLoading: Bool = false
    @Published var isInitialized: Bool = false
    @Published var errorMessage: String?

    // Tarih formatlayıcılar
    private let dateformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()

    init() {}
    
    func setup(modelContext: ModelContext) async {
        guard !isInitialized else { return }
        
        self.modelContext = modelContext
        self.schoolDayEngine = SchoolDayEngine(modelContext: modelContext)
        self.nextClassCalculator = NextClassCalculator(
            modelContext: modelContext,
            schoolDayEngine: self.schoolDayEngine!
        )
        self.todayScheduleProvider = TodayScheduleProvider(
            modelContext: modelContext,
            schoolDayEngine: self.schoolDayEngine!
        )
        
        self.isInitialized = true
        await loadData()
    }

    /// Verileri yükle
    func loadData() async {
        guard isInitialized,
              let schoolDayEngine = schoolDayEngine,
              let todayScheduleProvider = todayScheduleProvider,
              let nextClassCalculator = nextClassCalculator else { return }
              
        isLoading = true
        errorMessage = nil

        // Aktif dönemi bul
        activeSemester = schoolDayEngine.getActiveSemester()

        guard let semester = activeSemester else {
            errorMessage = "Aktif dönem bulunamadı"
            isLoading = false
            return
        }

        // Bugün öğretim günü mü?
        let today = Date()
        let isInstructionalDay = schoolDayEngine.isInstructionalDay(today, semester: semester)

        if isInstructionalDay {
            // Bugünkü dersleri al
            todayClasses = await todayScheduleProvider.todayClassesWithPeriods(semester: semester)

            // Şu anki dersi bul
            currentClass = await todayScheduleProvider.currentClass(semester: semester)
        } else {
            todayClasses = []
            currentClass = nil
        }

        // Sıradaki dersi bul
        nextClassResult = await nextClassCalculator.nextClass(from: today, semester: semester)

        // Bugünkü planner itemları al
        await loadTodayPlannerItems()

        isLoading = false
    }

    /// Bugünkü planner itemları yükle
    private func loadTodayPlannerItems() async {
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
            sortBy: [SortDescriptor(\.priority), SortDescriptor(\.createdAt)]
        )

        do {
            todayPlannerItems = try context.fetch(descriptor)
        } catch {
            AppLogger.error(error, message: "Bugünkü planner görevleri getirilemedi", category: .data)
            todayPlannerItems = []
        }
    }

    /// Tamamlanma durumunu toggle et
    func toggleCompleted(_ item: PlannerItem) {
        item.completed.toggle()

        do {
            try modelContext?.save()
        } catch {
            AppLogger.error(error, message: "Görev durumu kaydedilemedi", category: .data)
        }
    }

    /// Tarih gösterimi
    var dateDisplay: String {
        dateformatter.string(from: Date())
    }

    /// Bugün ders var mı?
    var hasTodayClasses: Bool {
        !todayClasses.isEmpty
    }
}
