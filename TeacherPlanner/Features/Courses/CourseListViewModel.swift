//
//  CourseListViewModel.swift
//  TeacherPlanner
//

import Combine
import Foundation
import SwiftData

@MainActor
final class CourseListViewModel: ObservableObject {

    // MARK: - State
    @Published var appError: AppError?

    // MARK: - Dependencies
    private var modelContext: ModelContext?

    // MARK: - Setup
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Actions
    func deleteCourse(_ course: Course) {
        guard let context = modelContext else { return }
        context.delete(course)
        let result = context.saveResult("CourseListViewModel: deleteCourse failed")
        if case .failure(let error) = result {
            appError = error
        }
    }

    func deleteCourses(at offsets: IndexSet, in courses: [Course]) {
        guard let context = modelContext else { return }
        for index in offsets {
            context.delete(courses[index])
        }
        let result = context.saveResult("CourseListViewModel: deleteCourses failed")
        if case .failure(let error) = result {
            appError = error
        }
    }
}
