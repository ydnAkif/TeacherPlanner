import Foundation
import SwiftData

/// Course verilerine erişim soyutlaması
@MainActor
protocol CourseRepositoryProtocol {
    func fetchAll() async -> Result<[Course], AppError>
    @discardableResult
    func save(_ course: Course) async -> Result<Void, AppError>
    @discardableResult
    func delete(_ course: Course) async -> Result<Void, AppError>
}

@MainActor
final class CourseRepository: CourseRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async -> Result<[Course], AppError> {
        let descriptor = FetchDescriptor<Course>(
            sortBy: [SortDescriptor(\Course.title)]
        )

        return modelContext.fetchResult(
            descriptor,
            failureMessage: "CourseRepository: fetchAll failed"
        )
    }
    
    @discardableResult
    func save(_ course: Course) async -> Result<Void, AppError> {
        modelContext.insert(course)
        return modelContext.saveResult("CourseRepository: save failed")
    }
    
    @discardableResult
    func delete(_ course: Course) async -> Result<Void, AppError> {
        modelContext.delete(course)
        return modelContext.saveResult("CourseRepository: delete failed")
    }
}
