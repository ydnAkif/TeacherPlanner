//
//  CourseListViewModel.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 10.03.2026.
//

import Combine
import Foundation
import SwiftData

@MainActor
final class CourseListViewModel: ObservableObject {

    // MARK: - State
    @Published var appError: AppError?

    // MARK: - Dependencies
    private var repository: (any CourseRepositoryProtocol)?

    // MARK: - Setup
    func setup(repository: any CourseRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions
    func deleteCourse(_ course: Course) {
        Task {
            do {
                try await repository?.delete(course)
            } catch {
                AppLogger.error(error, message: "CourseListViewModel: deleteCourse failed")
                appError = AppError.from(error: error)
            }
        }
    }

    func deleteCourses(at offsets: IndexSet, in courses: [Course]) {
        Task {
            do {
                for index in offsets {
                    try await repository?.delete(courses[index])
                }
            } catch {
                AppLogger.error(error, message: "CourseListViewModel: deleteCourses failed")
                appError = AppError.from(error: error)
            }
        }
    }
}
