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
    @Published var errorMessage: String?

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
        save()
    }

    func deleteCourses(at offsets: IndexSet, in courses: [Course]) {
        guard let context = modelContext else { return }
        for index in offsets {
            context.delete(courses[index])
        }
        save()
    }

    // MARK: - Private Helpers
    private func save() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            AppLogger.error(error, message: "CourseListViewModel: save failed")
            errorMessage = "Ders kaydedilemedi. Lütfen tekrar deneyin."
        }
    }
}
