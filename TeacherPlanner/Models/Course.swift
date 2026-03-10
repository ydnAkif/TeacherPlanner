//
//  Course.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData
import SwiftUI

/// Ders tanımı (örn: 5-C Fen Bilimleri, 6-B Matematik)
@Model
final class Course {
    var id: UUID
    var title: String
    var colorHex: String
    var symbolName: String
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \ClassSession.course)
    var sessions: [ClassSession]

    @Relationship(deleteRule: .cascade)
    var plannerItems: [PlannerItem]

    init(
        id: UUID = UUID(),
        title: String,
        colorHex: String = "#007AFF",
        symbolName: String = "book",
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.notes = notes
        self.sessions = []
        self.plannerItems = []
    }

    /// SwiftUI Color oluştur
    var color: SwiftUI.Color {
        Color(hex: colorHex) ?? .blue
    }
}
