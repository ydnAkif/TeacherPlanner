//
//  ModelContainerFactory.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

struct ModelContainerFactory {
    static func create() throws -> ModelContainer {
        let schema = Schema([
            Semester.self,
            SkippedDay.self,
            Course.self,
            PeriodDefinition.self,
            ClassSession.self,
            PlannerItem.self,
        ])

        let sharedStoreURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier
        )?.appendingPathComponent("TeacherPlanner.sqlite")
        
        // Fallback for tests or missing entitlements
        let fallbackURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TeacherPlanner.sqlite")
        
        let configuration = ModelConfiguration(
            schema: schema,
            url: sharedStoreURL ?? fallbackURL,
            allowsSave: true
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Preview için memory-only container
    static func createPreview() throws -> ModelContainer {
        let schema = Schema([
            Semester.self,
            SkippedDay.self,
            Course.self,
            PeriodDefinition.self,
            ClassSession.self,
            PlannerItem.self,
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Tüm verileri temizler (Geliştirme için helper)
    static func eraseAllData() {
        let sharedStoreURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier
        )?.appendingPathComponent("TeacherPlanner.sqlite")
        
        let fallbackURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TeacherPlanner.sqlite")
        
        let urls = [sharedStoreURL, fallbackURL].compactMap { $0 }
        
        for url in urls {
            let shmURL = url.deletingPathExtension().appendingPathExtension("sqlite-shm")
            let walURL = url.deletingPathExtension().appendingPathExtension("sqlite-wal")
            
            do { try FileManager.default.removeItem(at: url) }
            catch { AppLogger.warning("ModelContainerFactory: removeItem failed: \(error.localizedDescription)") }
            do { try FileManager.default.removeItem(at: shmURL) }
            catch { AppLogger.warning("ModelContainerFactory: removeItem failed: \(error.localizedDescription)") }
            do { try FileManager.default.removeItem(at: walURL) }
            catch { AppLogger.warning("ModelContainerFactory: removeItem failed: \(error.localizedDescription)") }
        }
        Logger.info("ModelContainerFactory: Tüm veriler temizlendi.")
    }
}
