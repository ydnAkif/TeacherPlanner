//
//  Logger.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 11.03.2026.
//

import Foundation
import OSLog

/// Backward-compatible alias used across the app.
typealias AppLogger = Logger

/// Merkezi logging utility
/// Debug, info, warning, error level'larında loglama yapar
enum Logger {
    
    // MARK: - Log Levels
    
    enum Level: Int {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }
    
    // MARK: - Properties
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.teacherplanner.app"
    private static let logger = OSLog(subsystem: subsystem, category: "App")
    
    /// Basit file-based logging için queue
    private static let fileQueue = DispatchQueue(label: "Logger.FileQueue")
    
    /// Log dosyası konumu (Caches klasörü altında)
    private static var logFileURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("TeacherPlanner.log")
    }
    
    /// Minimum log level (debug/release göre değişir)
    private static var minLevel: Level {
        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }
    
    /// Log formatında timestamp oluştur
    private static var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
    
    /// Dosya adını sadeleştir (sadece son kısmı al)
    private static func fileName(_ file: String) -> String {
        (file as NSString).lastPathComponent
    }
    
    // MARK: - Public Methods
    
    /// Debug log
    static func debug(_ message: String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }
    
    /// Info log
    static func info(_ message: String,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }
    
    /// Warning log
    static func warning(_ message: String,
                       file: String = #file,
                       function: String = #function,
                       line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }
    
    /// Error log
    static func error(_ error: Error?,
                     message: String = "",
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        let errorMessage = message.isEmpty ? "" : "\(message) - "
        let errorDescription = error?.localizedDescription ?? "Unknown error"
        log(.error, "\(errorMessage)Error: \(errorDescription)", file: file, function: function, line: line)
    }
    
    /// Error log (String message ile)
    static func error(_ message: String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    /// Generic log method
    private static func log(_ level: Level,
                           _ message: String,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line) {
        // Minimum level kontrolü
        guard level.rawValue >= minLevel.rawValue else { return }
        
        let fileInfo = "\(fileName(file)):\(line)"
        let logMessage = "\(level.emoji) [\(timestamp)] [\(level)] \(fileInfo) - \(message)"
        
        #if DEBUG
        // Debug modda console'a da yazdır
        print(logMessage)
        #endif
        
        // OSLog ile logla
        os_log("%{public}@", log: logger, type: level.osLogType, logMessage)
        
        // File-based logging (opsiyonel, tüm build tiplerinde)
        fileQueue.async {
            guard let url = logFileURL else { return }
            let line = logMessage + "\n"
            if FileManager.default.fileExists(atPath: url.path) {
                if let handle = try? FileHandle(forWritingTo: url) {
                    defer { try? handle.close() }
                    _ = try? handle.seekToEnd()
                    if let data = line.data(using: .utf8) {
                        try? handle.write(contentsOf: data)
                    }
                }
            } else {
                try? line.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}
