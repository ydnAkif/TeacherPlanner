//
//  SettingsViewModel.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 10.03.2026.
//

import Combine
import Foundation
import SwiftData
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - State
    @Published var notificationPermissionGranted = false
    @Published var showingResetAlert = false
    @Published var showingResetSuccess = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private var modelContext: ModelContext?

    // MARK: - Setup
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Notification Permission
    func checkNotificationPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationPermissionGranted = settings.authorizationStatus == .authorized
    }

    func requestNotificationPermission() {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                notificationPermissionGranted = granted
            } catch {
                AppLogger.error(error, message: "SettingsViewModel: notification permission failed")
                errorMessage = "Bildirim izni alınamadı."
            }
        }
    }

    // MARK: - Data Reset
    func resetAllData() {
        guard let context = modelContext else { return }
        do {
            try context.delete(model: Semester.self)
            try context.delete(model: Course.self)
            try context.delete(model: PeriodDefinition.self)
            try context.delete(model: ClassSession.self)
            try context.delete(model: PlannerItem.self)
            try context.delete(model: SkippedDay.self)
            try context.save()

            showingResetSuccess = true
            Task {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                showingResetSuccess = false
            }
        } catch {
            AppLogger.error(error, message: "SettingsViewModel: data reset failed")
            errorMessage = "Veriler silinemedi: \(error.localizedDescription)"
        }
    }
}
