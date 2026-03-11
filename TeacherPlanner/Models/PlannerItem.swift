//
//  PlannerItem.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

// MARK: - PlannerItemType

/// Planner item tipleri (note, homework, task vb.)
enum PlannerItemType: String, Codable, CaseIterable {
    case note = "note"
    case homework = "homework"
    case reminder = "reminder"
    case exam = "exam"
    case material = "material"
    case task = "task"

    var displayName: String {
        switch self {
        case .note: return "Not"
        case .homework: return "Ödev"
        case .reminder: return "Hatırlatma"
        case .exam: return "Sınav"
        case .material: return "Materyal"
        case .task: return "Görev"
        }
    }

    var systemImage: String {
        switch self {
        case .note: return "note.text"
        case .homework: return "pencil.tip"
        case .reminder: return "bell"
        case .exam: return "checkmark.seal"
        case .material: return "folder"
        case .task: return "checklist"
        }
    }
}

// MARK: - Priority

/// Görev önceliği — Int raw value SwiftData migration'ını korur
enum Priority: Int, Codable, CaseIterable {
    case high = 1
    case medium = 2
    case low = 3

    var displayName: String {
        switch self {
        case .high: return "Yüksek"
        case .medium: return "Orta"
        case .low: return "Düşük"
        }
    }

    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "blue"
        }
    }

    var badgeLabel: String {
        switch self {
        case .high: return "Y"
        case .medium: return "O"
        case .low: return "D"
        }
    }
}

// MARK: - PlannerItem

/// Task / Note / Hatırlatma birleşik modeli
@Model
final class PlannerItem {
    var id: UUID
    var title: String
    var details: String?
    var type: PlannerItemType
    var dueDate: Date?
    var priority: Priority
    var completed: Bool
    var createdAt: Date

    @Relationship(inverse: \Course.plannerItems)
    var course: Course?

    init(
        id: UUID = UUID(),
        title: String,
        details: String? = nil,
        type: PlannerItemType = .note,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        completed: Bool = false,
        createdAt: Date = Date(),
        course: Course? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.type = type
        self.dueDate = dueDate
        self.priority = priority
        self.completed = completed
        self.createdAt = createdAt
        self.course = course
    }

    /// Öncelik gösterimi (geriye dönük uyumluluk için)
    var priorityDisplay: String {
        priority.displayName
    }

    /// Vadesi geçmiş mi?
    var isOverdue: Bool {
        guard let dueDate else { return false }
        return !completed && Date() > dueDate
    }
}
