//
//  SkipType.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation

/// Bir günün neden skip edildiğini belirtir
enum SkipType: String, Codable, CaseIterable {
    /// Hafta sonu
    case weekend

    /// Resmi tatil
    case holiday

    /// Dönem arası tatil
    case semesterBreak

    /// Kullanıcı manuel ekledi
    case manual

    var displayName: String {
        switch self {
        case .weekend:
            return "Hafta Sonu"
        case .holiday:
            return "Resmi Tatil"
        case .semesterBreak:
            return "Dönem Tatili"
        case .manual:
            return "Manuel"
        }
    }
}
