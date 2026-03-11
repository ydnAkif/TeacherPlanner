//
//  TeacherPlannerApp.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

@main
struct TeacherPlannerApp: App {
    @State private var container: ModelContainer?
    @State private var appEnvironment: AppEnvironment?

    static var isUITesting: Bool {
        CommandLine.arguments.contains("--uitesting")
    }

    static var shouldSeedData: Bool {
        CommandLine.arguments.contains("--seed-data")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container, let appEnvironment {
                    RootView()
                        .modelContainer(container)
                        .environment(\.appEnvironment, appEnvironment)
                        .environment(\.isUITesting, Self.isUITesting)
                } else {
                    ProgressView()
                }
            }
            .task {
                guard container == nil else { return }
                do {
                    let newContainer: ModelContainer
                    if Self.isUITesting {
                        newContainer = try ModelContainerFactory.createPreview()
                    } else {
                        newContainer = try ModelContainerFactory.create()
                    }
                    container = newContainer
                    appEnvironment = AppEnvironment(modelContext: newContainer.mainContext)
                    
                    if Self.shouldSeedData {
                        try SampleDataSeeder.seed(newContainer)
                    }
                } catch {
                    fatalError("Model container oluşturulamadı: \(error)")
                }
            }
        }
    }
}
