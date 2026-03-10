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
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainerFactory.create()

            // Sample data yükle (ilk açılışta)
            try SampleDataSeeder.seed(container)
        } catch {
            fatalError("Model container oluşturulamadı: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
        }
    }
}
