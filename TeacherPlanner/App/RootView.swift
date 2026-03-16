//
//  RootView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

struct RootView: View {
    /// AppEnvironment doğrudan parametre olarak alınır.
    /// Böylece @Environment okuma sırasında nil kalma riski ve
    /// buna bağlı kalıcı ProgressView donması tamamen ortadan kalkar.
    let appEnvironment: AppEnvironment

    @Environment(\.modelContext) private var modelContext
    @Query private var semesters: [Semester]

    /// @Query yavaş güncellenirse bile geçişin anında olması için explicit flag
    @State private var onboardingComplete = false

    var body: some View {
        Group {
            if hasActiveSemester || onboardingComplete {
                mainContent
            } else {
                OnboardingView {
                    onboardingComplete = true
                }
            }
        }
        // Alt view'ların @Environment(\.appEnvironment) ile okuyabilmesi için
        .environment(\.appEnvironment, appEnvironment)
    }

    // MARK: - Helpers

    private var hasActiveSemester: Bool {
        semesters.contains { $0.isActive }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        @Bindable var router = appEnvironment.router

        TabView(selection: $router.selectedTab) {
            TodayView()
                .tabItem {
                    Label(AppRouter.Tab.today.title, systemImage: AppRouter.Tab.today.icon)
                }
                .tag(AppRouter.Tab.today)

            PlannerItemListView()
                .tabItem {
                    Label(AppRouter.Tab.planner.title, systemImage: AppRouter.Tab.planner.icon)
                }
                .tag(AppRouter.Tab.planner)

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
    let container = try! ModelContainerFactory.createPreview()
    let env = AppEnvironment(modelContext: container.mainContext)
    RootView(appEnvironment: env)
        .modelContainer(container)
}
