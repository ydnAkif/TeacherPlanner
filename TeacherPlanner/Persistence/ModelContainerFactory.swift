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
}
