//
//  RootView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var semesters: [Semester]

    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if hasActiveSemester {
                mainContent
            } else {
                OnboardingView()
            }
        }
    }

    private var hasActiveSemester: Bool {
        semesters.contains { $0.isActive }
    }

    @ViewBuilder
    var mainContent: some View {
        #if os(macOS)
            NavigationSplitView {
                List(selection: $selectedTab) {
                    Label("Today", systemImage: "sun.max")
                        .tag(0)
                    Label("Schedule", systemImage: "calendar")
                        .tag(1)
                    Label("Courses", systemImage: "book")
                        .tag(2)
                    Label("Planner Items", systemImage: "checklist")
                        .tag(3)
                    Label("Semester", systemImage: "graduationcap")
                        .tag(4)
                    Label("Settings", systemImage: "gearshape")
                        .tag(5)
                }
                .navigationTitle("TeacherPlanner")
                .listStyle(.sidebar)
            } detail: {
                detailView
            }
        #else
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "sun.max")
                    }
                    .tag(0)

                WeeklyScheduleView()
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                    .tag(1)

                CourseListView()
                    .tabItem {
                        Label("Courses", systemImage: "book")
                    }
                    .tag(2)

                PlannerItemListView()
                    .tabItem {
                        Label("Planner Items", systemImage: "checklist")
                    }
                    .tag(3)

                SemesterSettingsView()
                    .tabItem {
                        Label("Semester", systemImage: "graduationcap")
                    }
                    .tag(4)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(5)
            }
        #endif
    }

    @ViewBuilder
    var detailView: some View {
        switch selectedTab {
        case 0:
            TodayView()
        case 1:
            WeeklyScheduleView()
        case 2:
            CourseListView()
        case 3:
            PlannerItemListView()
        case 4:
            SemesterSettingsView()
        case 5:
            SettingsView()
        default:
            Text("Select a section")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RootView()
}
