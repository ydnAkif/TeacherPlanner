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
    @State private var startupError: String?

    @AppStorage(Constants.UI.Keys.appearanceMode) private var appearanceMode: Int = 0

    private var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

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
                    RootView(appEnvironment: appEnvironment)
                        .modelContainer(container)
                        .environment(\.isUITesting, Self.isUITesting)
                } else if let error = startupError {
                    startupErrorView(message: error)
                } else {
                    ProgressView("Başlatılıyor…")
                        .progressViewStyle(.circular)
                }
            }
            .preferredColorScheme(preferredColorScheme)
            .task {
                guard container == nil else { return }
                await initializeContainer()
            }
        }
    }

    // MARK: - Container Initialization

    private func initializeContainer() async {
        do {
            let newContainer = try makeContainer()
            container = newContainer
            appEnvironment = AppEnvironment(modelContext: newContainer.mainContext)

            if Self.shouldSeedData {
                try SampleDataSeeder.seed(newContainer)
            }
        } catch {
            // İlk deneme başarısız oldu — mevcut store bozuk olabilir.
            // Veritabanını silerek temiz bir başlangıç yap.
            AppLogger.warning(
                "TeacherPlannerApp: İlk container oluşturma başarısız (\(error.localizedDescription)), store sıfırlanıyor…"
            )

            do {
                ModelContainerFactory.eraseAllData()
                let freshContainer = try ModelContainerFactory.create()
                container = freshContainer
                appEnvironment = AppEnvironment(modelContext: freshContainer.mainContext)

                AppLogger.info("TeacherPlannerApp: Store sıfırlandı, temiz başlangıç yapıldı.")
            } catch let recoveryError {
                AppLogger.error(
                    recoveryError,
                    message: "TeacherPlannerApp: Kurtarma da başarısız"
                )
                startupError = recoveryError.localizedDescription
            }
        }
    }

    private func makeContainer() throws -> ModelContainer {
        if Self.isUITesting {
            return try ModelContainerFactory.createPreview()
        } else {
            return try ModelContainerFactory.create()
        }
    }

    // MARK: - Startup Error View

    private func startupErrorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("Uygulama Başlatılamadı")
                    .font(.title2.bold())
                Text(
                    "Veriler yüklenirken bir sorun oluştu. Lütfen uygulamayı silip yeniden yükleyin."
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }

            Text(message)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
