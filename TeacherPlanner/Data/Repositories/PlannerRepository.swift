import Foundation
import SwiftData

/// PlannerItem verilerine erişim soyutlaması
@MainActor
protocol PlannerRepositoryProtocol {
    func fetchTodayItems() async -> Result<[PlannerItem], AppError>
    func fetchAllItems(searchText: String, type: PlannerItemType?) async -> Result<[PlannerItem], AppError>
    func save(_ item: PlannerItem) async -> Result<Void, AppError>
    func delete(_ item: PlannerItem) async -> Result<Void, AppError>
    func toggleCompleted(_ item: PlannerItem) async -> Result<Void, AppError>
}

@MainActor
final class PlannerRepository: PlannerRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchTodayItems() async -> Result<[PlannerItem], AppError> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        // SwiftData Predicates can't use complex expressions like Date() inside them directly if they change.
        // So we use local variables.
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

        return modelContext.fetchResult(
            descriptor,
            failureMessage: "PlannerRepository: fetchTodayItems failed"
        )
    }
    
    func fetchAllItems(searchText: String = "", type: PlannerItemType? = nil) async -> Result<[PlannerItem], AppError> {
        // More complex filtering would go here if not using @Query
        let descriptor = FetchDescriptor<PlannerItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let result = modelContext.fetchResult(
            descriptor,
            failureMessage: "PlannerRepository: fetchAllItems failed"
        )

        return result.map { items in
            items.filter { item in
            let matchesSearch = searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
                let matchesType = type == nil || item.type == type
                return matchesSearch && matchesType
            }
        }
    }
    
    func save(_ item: PlannerItem) async -> Result<Void, AppError> {
        modelContext.insert(item)
        return modelContext.saveResult("PlannerRepository: save failed")
    }
    
    func delete(_ item: PlannerItem) async -> Result<Void, AppError> {
        modelContext.delete(item)
        return modelContext.saveResult("PlannerRepository: delete failed")
    }
    
    func toggleCompleted(_ item: PlannerItem) async -> Result<Void, AppError> {
        item.completed.toggle()
        return modelContext.saveResult("PlannerRepository: toggleCompleted failed")
    }
}
