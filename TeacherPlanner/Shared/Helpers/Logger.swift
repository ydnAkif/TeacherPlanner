import Foundation
import os

enum LogCategory: String {
    case app = "App"
    case data = "Data"
    case ui = "UI"
    case network = "Network"
    case widget = "Widget"
    case notifications = "Notifications"
}

/// Centralized logger using Apple's OSLog
struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.ydnakif.TeacherPlanner"
    
    private static func logger(for category: LogCategory) -> Logger {
        return Logger(subsystem: subsystem, category: category.rawValue)
    }
    
    static func info(_ message: String, category: LogCategory = .app) {
        logger(for: category).info("\(message, privacy: .public)")
    }
    
    static func warning(_ message: String, category: LogCategory = .app) {
        logger(for: category).warning("\(message, privacy: .public)")
    }
    
    static func debug(_ message: String, category: LogCategory = .app) {
        logger(for: category).debug("\(message, privacy: .public)")
    }
    
    static func error(_ error: Error, message: String? = nil, category: LogCategory = .app) {
        let errorMsg = message ?? "An error occurred"
        logger(for: category).error("\(errorMsg, privacy: .public): \(error.localizedDescription, privacy: .public)")
    }
    
    static func error(_ message: String, category: LogCategory = .app) {
        logger(for: category).error("\(message, privacy: .public)")
    }
    
    static func fault(_ message: String, category: LogCategory = .app) {
        logger(for: category).fault("\(message, privacy: .public)")
    }
}
