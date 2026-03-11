import Foundation
import SwiftUI

/// Shared configuration constants across the application
enum Constants {

    struct App {
        static let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.3.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
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
