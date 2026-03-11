import Foundation
import SwiftData

/// PlannerItem verilerine erişim soyutlaması
@MainActor
protocol PlannerRepositoryProtocol {
    func fetchTodayItems() async throws -> [PlannerItem]
    func fetchAllItems(searchText: String, type: PlannerItemType?) async throws -> [PlannerItem]
    func save(_ item: PlannerItem) async throws
    func delete(_ item: PlannerItem) async throws
    func toggleCompleted(_ item: PlannerItem) async throws
}

@MainActor
final class PlannerRepository: PlannerRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchTodayItems() async throws -> [PlannerItem] {
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
        
        return try modelContext.fetch(descriptor)
    }
    
    func fetchAllItems(searchText: String = "", type: PlannerItemType? = nil) async throws -> [PlannerItem] {
        // More complex filtering would go here if not using @Query
        let descriptor = FetchDescriptor<PlannerItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let items = try modelContext.fetch(descriptor)
        
        return items.filter { item in
            let matchesSearch = searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
            let matchesType = type == nil || item.type == type
            return matchesSearch && matchesType
        }
    }
    
    func save(_ item: PlannerItem) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    
    func delete(_ item: PlannerItem) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func toggleCompleted(_ item: PlannerItem) async throws {
        item.completed.toggle()
        try modelContext.save()
    }
}
