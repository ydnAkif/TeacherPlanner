import Foundation
import SwiftData

/// Semester verilerine erişim soyutlaması
@MainActor
protocol SemesterRepositoryProtocol {
    func fetchActiveSemester() async -> Result<Semester?, AppError>
    func fetchAll() async -> Result<[Semester], AppError>
    @discardableResult
    func save(_ semester: Semester) async -> Result<Void, AppError>
    @discardableResult
    func delete(_ semester: Semester) async -> Result<Void, AppError>
    @discardableResult
    func setActive(_ semester: Semester) async -> Result<Void, AppError>
}

@MainActor
final class SemesterRepository: SemesterRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchActiveSemester() async -> Result<Semester?, AppError> {
        let descriptor = FetchDescriptor<Semester>(
            predicate: #Predicate { $0.isActive }
        )

        let result = modelContext.fetchResult(
            descriptor,
            failureMessage: "SemesterRepository: fetchActiveSemester failed"
        )

        return result.map { $0.first }
    }
    
    func fetchAll() async -> Result<[Semester], AppError> {
        let descriptor = FetchDescriptor<Semester>(
            sortBy: [SortDescriptor(\Semester.startDate, order: .reverse)]
        )

        return modelContext.fetchResult(
            descriptor,
            failureMessage: "SemesterRepository: fetchAll failed"
        )
    }
    
    @discardableResult
    func save(_ semester: Semester) async -> Result<Void, AppError> {
        modelContext.insert(semester)
        return modelContext.saveResult("SemesterRepository: save failed")
    }
    
    @discardableResult
    func delete(_ semester: Semester) async -> Result<Void, AppError> {
        modelContext.delete(semester)
        return modelContext.saveResult("SemesterRepository: delete failed")
    }
    
    @discardableResult
    func setActive(_ semester: Semester) async -> Result<Void, AppError> {
        let allResult = await fetchAll()

        switch allResult {
        case .failure(let error):
            return .failure(error)
        case .success(let semesters):
            for s in semesters {
                s.isActive = (s.id == semester.id)
            }
            return modelContext.saveResult("SemesterRepository: setActive failed")
        }
    }
}
