import Foundation
import SwiftData

/// Semester verilerine erişim soyutlaması
@MainActor
protocol SemesterRepositoryProtocol {
    func fetchActiveSemester() async throws -> Semester?
    func fetchAll() async throws -> [Semester]
    func save(_ semester: Semester) async throws
    func delete(_ semester: Semester) async throws
    func setActive(_ semester: Semester) async throws
}

@MainActor
final class SemesterRepository: SemesterRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchActiveSemester() async throws -> Semester? {
        let descriptor = FetchDescriptor<Semester>(
            predicate: #Predicate { $0.isActive }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func fetchAll() async throws -> [Semester] {
        let descriptor = FetchDescriptor<Semester>(
            sortBy: [SortDescriptor(\Semester.startDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func save(_ semester: Semester) async throws {
        modelContext.insert(semester)
        try modelContext.save()
    }
    
    func delete(_ semester: Semester) async throws {
        modelContext.delete(semester)
        try modelContext.save()
    }
    
    func setActive(_ semester: Semester) async throws {
        let semesters = try await fetchAll()
        for s in semesters {
            s.isActive = (s.id == semester.id)
        }
        try modelContext.save()
    }
}
