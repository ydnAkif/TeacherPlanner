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
    @Published var appError: AppError?

    // Settings
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Constants.Notification.Keys.enabled)
            updateNotifications()
        }
    }
    
    @Published var reminderMinutesBefore: Int {
        didSet {
            UserDefaults.standard.set(reminderMinutesBefore, forKey: Constants.Notification.Keys.minutesBefore)
            updateNotifications()
        }
    }
    
    @Published var appearanceMode: Int {
        didSet {
            UserDefaults.standard.set(appearanceMode, forKey: Constants.UI.Keys.appearanceMode)
        }
    }

    // MARK: - Dependencies
    private var modelContext: ModelContext?
    private var notificationUseCase: (any NotificationUseCaseProtocol)?
    private var scheduler: (any NotificationScheduling)?

    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Constants.Notification.Keys.enabled)
        // Set default if not exists
        if UserDefaults.standard.object(forKey: Constants.Notification.Keys.enabled) == nil {
            self.notificationsEnabled = true
        }
        
        let savedMinutes = UserDefaults.standard.integer(forKey: Constants.Notification.Keys.minutesBefore)
        self.reminderMinutesBefore = savedMinutes == 0 ? Constants.Notification.defaultReminderMinutesBefore : savedMinutes
        
        self.appearanceMode = UserDefaults.standard.integer(forKey: Constants.UI.Keys.appearanceMode)
    }

    // MARK: - Setup
    func setup(
        modelContext: ModelContext,
        notificationUseCase: any NotificationUseCaseProtocol,
        scheduler: any NotificationScheduling
    ) {
        self.modelContext = modelContext
        self.notificationUseCase = notificationUseCase
        self.scheduler = scheduler
    }

    // MARK: - Notification Permission
    func checkNotificationPermission() async {
        guard let scheduler = scheduler else { return }
        notificationPermissionGranted = await scheduler.requestPermission()
    }

    func requestNotificationPermission() {
        Task {
            if let scheduler = scheduler {
                notificationPermissionGranted = await scheduler.requestPermission()
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
            appError = AppError.from(error: error)
        }
    }

    private func updateNotifications() {
        Task {
            if notificationsEnabled {
                await scheduler?.rescheduleAllNotifications()
            } else {
                await scheduler?.cancelAllNotifications()
            }
        }
    }
}
