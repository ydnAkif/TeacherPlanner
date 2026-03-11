//
//  ModelContainerFactory.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

struct ModelContainerFactory {

    private static var schema: Schema {
        Schema([
            Semester.self,
            SkippedDay.self,
            Course.self,
            PeriodDefinition.self,
            ClassSession.self,
            PlannerItem.self,
        ])
    }

    static func create() throws -> ModelContainer {
        let storeURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("TeacherPlanner.sqlite")

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            allowsSave: true
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Preview / UI-test için memory-only container
    static func createPreview() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Tüm verileri temizler (geliştirme yardımcısı)
    static func eraseAllData() {
        let storeURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("TeacherPlanner.sqlite")

        let relatedURLs = [
            storeURL,
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm"),
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal"),
        ]

        for url in relatedURLs {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                AppLogger.warning(
                    "ModelContainerFactory.eraseAllData: \(url.lastPathComponent) silinemedi — \(error.localizedDescription)"
                )
            }
        }

        Logger.info("ModelContainerFactory: Tüm veriler temizlendi.")
    }
}
