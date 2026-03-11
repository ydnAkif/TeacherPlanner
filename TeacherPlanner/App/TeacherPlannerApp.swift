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
    @State private var appEnvironment: AppEnvironment?

    init() {
        // TEMPORARY: Verileri temizlemek için alttaki satırı bir kez çalıştırıp sonra yorum satırı yapın
        // ModelContainerFactory.eraseAllData()

        do {
            container = try ModelContainerFactory.create()

            // Sample data yükle (ilk açılışta)
            // try SampleDataSeeder.seed(container)
        } catch {
            fatalError("Model container oluşturulamadı: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .task {
                    if appEnvironment == nil {
                        appEnvironment = AppEnvironment(modelContext: container.mainContext)
                    }
                }
                .environment(\.appEnvironment, appEnvironment)
        }
    }
}
