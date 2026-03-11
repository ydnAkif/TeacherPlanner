import Foundation
import SwiftData

/// Course verilerine erişim soyutlaması
@MainActor
protocol CourseRepositoryProtocol {
    func fetchAll() async throws -> [Course]
    func save(_ course: Course) async throws
    func delete(_ course: Course) async throws
}

@MainActor
final class CourseRepository: CourseRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [Course] {
        let descriptor = FetchDescriptor<Course>(
            sortBy: [SortDescriptor(\Course.title)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func save(_ course: Course) async throws {
        modelContext.insert(course)
        try modelContext.save()
    }
    
    func delete(_ course: Course) async throws {
        modelContext.delete(course)
        try modelContext.save()
    }
}
