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

            SettingsView()
                .tabItem {
                    Label(AppRouter.Tab.settings.title, systemImage: AppRouter.Tab.settings.icon)
                }
                .tag(AppRouter.Tab.settings)
        }
    }
}

#Preview {
    RootView()
}
