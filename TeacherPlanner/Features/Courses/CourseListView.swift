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

    @StateObject private var viewModel = CourseListViewModel()
    @State private var showingAddCourse = false

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
            .errorAlert(error: $viewModel.appError)
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
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
                viewModel.deleteCourses(at: offsets, in: courses)
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
}

#Preview {
    CourseListView()
}
