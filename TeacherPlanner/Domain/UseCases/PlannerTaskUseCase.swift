import Foundation
import SwiftData

/// Planner item işlemleri için Use Case uygulaması
@MainActor
final class PlannerTaskUseCase: PlannerTaskUseCaseProtocol {
    private let repository: any PlannerRepositoryProtocol
    
    init(repository: any PlannerRepositoryProtocol) {
        self.repository = repository
    }
    
    func toggleCompleted(_ item: PlannerItem) async -> Result<Void, AppError> {
        await repository.toggleCompleted(item)
    }
    
    func deleteItem(_ item: PlannerItem) async -> Result<Void, AppError> {
        await repository.delete(item)
    }
    
    func fetchTodayItems() async -> Result<[PlannerItem], AppError> {
        await repository.fetchTodayItems()
    }
}
