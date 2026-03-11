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
            await repository?.delete(course)
        }
    }

    func deleteCourses(at offsets: IndexSet, in courses: [Course]) {
        Task {
            for index in offsets {
                await repository?.delete(courses[index])
            }
        }
    }
}
