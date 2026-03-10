//
//  PlannerItem.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

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
        case .note:
            return "Not"
        case .homework:
            return "Ödev"
        case .reminder:
            return "Hatırlatma"
        case .exam:
            return "Sınav"
        case .material:
            return "Materyal"
        case .task:
            return "Görev"
        }
    }

    var systemImage: String {
        switch self {
        case .note:
            return "note.text"
        case .homework:
            return "pencil.tip"
        case .reminder:
            return "bell"
        case .exam:
            return "checkmark.seal"
        case .material:
            return "folder"
        case .task:
            return "checklist"
        }
    }
}

/// Task / Note / Hatırlatma birleşik modeli
@Model
final class PlannerItem {
    var id: UUID
    var title: String
    var details: String?
    var type: PlannerItemType
    var dueDate: Date?
    var priority: Int  // 1-3 arası (1: yüksek, 2: orta, 3: düşük)
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
        priority: Int = 2,
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

    /// Öncelik gösterimi
    var priorityDisplay: String {
        switch priority {
        case 1: return "Yüksek"
        case 2: return "Orta"
        case 3: return "Düşük"
        default: return "-"
        }
    }

    /// Vadesi geçmiş mi?
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !completed && Date() > dueDate
    }
}
