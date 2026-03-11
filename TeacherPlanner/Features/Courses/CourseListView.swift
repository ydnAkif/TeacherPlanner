//
//  CourseListView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct CourseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Course.title) private var courses: [Course]

    @State private var showingAddCourse = false
    @State private var appError: AppError?

    var body: some View {
        NavigationStack {
            Group {
                if courses.isEmpty {
                    emptyState
                } else {
                    courseList
                }
            }
            .navigationTitle("Dersler")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                EditCourseView()
            }
            .errorAlert(error: $appError)
        }
    }

    private var courseList: some View {
        List {
            ForEach(courses) { course in
                NavigationLink {
                    CourseDetailView(course: course)
                } label: {
                    CourseRow(course: course)
                }
            }
            .onDelete { offsets in
                deleteCourses(at: offsets)
            }
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "book",
            title: "Henüz Ders Yok",
            message: "Yeni ders eklemek için + butonuna tıklayın",
            actionLabel: "Ders Ekle",
            action: { showingAddCourse = true }
        )
    }

    // MARK: - Actions

    private func deleteCourse(_ course: Course) {
        modelContext.delete(course)
        let result = modelContext.saveResult("CourseListView: deleteCourse failed")
        if case .failure(let error) = result {
            appError = error
        }
    }

    private func deleteCourses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(courses[index])
        }
        let result = modelContext.saveResult("CourseListView: deleteCourses failed")
        if case .failure(let error) = result {
            appError = error
        }
    }
}

#Preview {
    CourseListView()
}
