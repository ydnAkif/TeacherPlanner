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
    @Environment(\.appEnvironment) private var appEnvironment
    @Query private var semesters: [Semester]

    var body: some View {
        Group {
            if hasActiveSemester {
                if let env = appEnvironment {
                    mainContent(env)
                } else {
                    ProgressView()
                }
            } else {
                OnboardingView()
            }
        }
    }

    private var hasActiveSemester: Bool {
        semesters.contains { $0.isActive }
    }

    @ViewBuilder
    private func mainContent(_ env: AppEnvironment) -> some View {
        @Bindable var router = env.router
        
        #if os(macOS)
            NavigationSplitView {
                List(selection: $router.selectedTab) {
                    ForEach(AppRouter.Tab.allCases, id: \.self) { tab in
                        Label(tab.title, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .navigationTitle("TeacherPlanner")
                .listStyle(.sidebar)
            } detail: {
                detailView(router.selectedTab)
            }
        #else
            TabView(selection: $router.selectedTab) {
                TodayView()
                    .tabItem {
                        Label(AppRouter.Tab.today.title, systemImage: AppRouter.Tab.today.icon)
                    }
                    .tag(AppRouter.Tab.today)

                WeeklyScheduleView()
                    .tabItem {
                        Label(AppRouter.Tab.schedule.title, systemImage: AppRouter.Tab.schedule.icon)
                    }
                    .tag(AppRouter.Tab.schedule)

                CourseListView()
                    .tabItem {
                        Label(AppRouter.Tab.courses.title, systemImage: AppRouter.Tab.courses.icon)
                    }
                    .tag(AppRouter.Tab.courses)

                PlannerItemListView()
                    .tabItem {
                        Label(AppRouter.Tab.planner.title, systemImage: AppRouter.Tab.planner.icon)
                    }
                    .tag(AppRouter.Tab.planner)

                SemesterSettingsView()
                    .tabItem {
                        Label(AppRouter.Tab.semester.title, systemImage: AppRouter.Tab.semester.icon)
                    }
                    .tag(AppRouter.Tab.semester)

                SettingsView()
                    .tabItem {
                        Label(AppRouter.Tab.settings.title, systemImage: AppRouter.Tab.settings.icon)
                    }
                    .tag(AppRouter.Tab.settings)
            }
        #endif
    }

    @ViewBuilder
    private func detailView(_ selectedTab: AppRouter.Tab) -> some View {
        switch selectedTab {
        case .today:
            TodayView()
        case .schedule:
            WeeklyScheduleView()
        case .courses:
            CourseListView()
        case .planner:
            PlannerItemListView()
        case .semester:
            SemesterSettingsView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    RootView()
}
