import Foundation
import SwiftData

/// Planner item işlemleri için Use Case uygulaması
@MainActor
final class PlannerTaskUseCase: PlannerTaskUseCaseProtocol {
    private let repository: any PlannerRepositoryProtocol
    
    init(repository: any PlannerRepositoryProtocol) {
        self.repository = repository
    }
    
    func toggleCompleted(_ item: PlannerItem) async throws {
        try await repository.toggleCompleted(item)
        // Burada bildirimleri güncelleme gibi ek mantıklar gelebilir
    }
    
    func deleteItem(_ item: PlannerItem) async throws {
        try await repository.delete(item)
    }
    
    func fetchTodayItems() async throws -> [PlannerItem] {
        try await repository.fetchTodayItems()
    }
}
