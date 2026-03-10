import Foundation
import SwiftUI

/// Shared configuration constants across the application
enum Constants {
    /// App Group Identifier for sharing data with Widgets and intents
    static let appGroupIdentifier = "group.com.ydnakif.TeacherPlanner.shared"

    struct App {
        static let version = "0.3.0"
        static let build = "2026.03.09"
    }

    struct Notification {
        static let defaultReminderMinutesBefore: Int = 15
        static let reminderOptions: [Int] = [5, 10, 15, 30]

        struct Keys {
            static let enabled = "notificationsEnabled"
            static let minutesBefore = "reminderMinutesBefore"
        }
    }

    struct Engine {
        static let maxForwardDaysToSearch: Int = 365
    }

    struct UI {
        static let cornerRadius: CGFloat = 12.0

        struct Keys {
            static let appearanceMode = "appearanceMode"
        }
    }
}
