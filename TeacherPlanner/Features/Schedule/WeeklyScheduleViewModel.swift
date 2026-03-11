import SwiftUI
import SwiftData
import Combine

@MainActor
final class WeeklyScheduleViewModel: ObservableObject {
    @Published var viewData: WeeklyViewData?
    @Published var isLoading: Bool = false
    @Published var appError: AppError?
    @Published var isInitialized: Bool = false
    
    // Dependencies
    private var modelContext: ModelContext?
    private var builder: (any WeeklyScheduleBuilding)?
    
    init() {}
    
    func setup(modelContext: ModelContext, builder: any WeeklyScheduleBuilding) {
        guard !isInitialized else { return }
        self.modelContext = modelContext
        self.builder = builder
        self.isInitialized = true
        
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        guard let builder = builder else { return }
        isLoading = true
        
        viewData = builder.buildWeeklyView()
        
        isLoading = false
    }
    
    func deleteSession(_ session: ClassSession) {
        guard let context = modelContext else { return }
        context.delete(session)
        do {
            try context.save()
            Task { await loadData() }
        } catch {
            appError = AppError.from(error: error)
        }
    }
}
