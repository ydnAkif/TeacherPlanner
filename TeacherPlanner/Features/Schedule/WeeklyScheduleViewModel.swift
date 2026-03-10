import SwiftUI
import SwiftData
import Combine

@MainActor
final class WeeklyScheduleViewModel: ObservableObject {
    @Published var weekData: [Int: [ClassSession]] = [:]
    @Published var isLoading: Bool = false
    
    // Dependencies
    private var modelContext: ModelContext?
    
    init() {}
    
    func setup(with context: ModelContext) {
        self.modelContext = context
        Task {
            await fetchWeekData()
        }
    }
    
    func fetchWeekData() async {
        guard let context = modelContext else { return }
        isLoading = true
        
        do {
            let descriptor = FetchDescriptor<ClassSession>(
                sortBy: [SortDescriptor(\.weekday), SortDescriptor(\.periodOrder)]
            )
            let allSessions = try context.fetch(descriptor)
            
            // Group by weekday
            self.weekData = Dictionary(grouping: allSessions, by: { $0.weekday })
            
        } catch {
            AppLogger.error(error, message: "Failed to fetch weekly sessions")
        }
        
        isLoading = false
    }
    
    func sessions(for weekday: Int) -> [ClassSession] {
        return weekData[weekday] ?? []
    }
}
