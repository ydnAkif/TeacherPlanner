//
//  PlannerItemsViewModel.swift
//  TeacherPlanner
//

import Combine
import Foundation
import SwiftData
import SwiftUI

// MARK: - ItemGroup

/// Planner item'larının tarihsel grupları
enum ItemGroup: String, CaseIterable {
    case overdue
    case today
    case thisWeek
    case later
    case noDate
    case completed

    var title: String {
        switch self {
        case .overdue: return "Vadesi Geçmiş"
        case .today: return "Bugün"
        case .thisWeek: return "Bu Hafta"
        case .later: return "Gelecek"
        case .noDate: return "Tarihsiz"
        case .completed: return "Tamamlandı"
        }
    }

    var icon: String {
        switch self {
        case .overdue: return "exclamationmark.circle"
        case .today: return "sun.max"
        case .thisWeek: return "calendar"
        case .later: return "calendar.badge.plus"
        case .noDate: return "tray"
        case .completed: return "checkmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .overdue: return .red
        case .today: return .orange
        case .thisWeek: return .blue
        case .later: return .purple
        case .noDate: return .secondary
        case .completed: return .green
        }
    }
}

// MARK: - ViewModel

@MainActor
final class PlannerItemsViewModel: ObservableObject {

    // MARK: - Filter & UI State
    @Published var searchText: String = ""
    @Published var selectedType: PlannerItemType?
    @Published var isEditing: Bool = false
    @Published var selectedItems: Set<UUID> = []
    @Published var showCompleted: Bool = false
    @Published var appError: AppError?

    // MARK: - Filtering

    func filteredItems(from items: [PlannerItem]) -> [PlannerItem] {
        items.filter { item in
            let matchesSearch =
                searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
                || (item.details?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesType = selectedType == nil || item.type == selectedType
            let matchesCompleted = showCompleted || !item.completed
            return matchesSearch && matchesType && matchesCompleted
        }
    }

    // MARK: - Grouping

    /// Filtrelenmiş item'ları tarihsel gruplara böler
    func groupedItems(from items: [PlannerItem]) -> [(group: ItemGroup, items: [PlannerItem])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: today)!

        let filtered = filteredItems(from: items)

        var overdue: [PlannerItem] = []
        var todayItems: [PlannerItem] = []
        var thisWeekItems: [PlannerItem] = []
        var laterItems: [PlannerItem] = []
        var noDateItems: [PlannerItem] = []
        var completedItems: [PlannerItem] = []

        for item in filtered {
            if item.completed {
                completedItems.append(item)
            } else if let dueDate = item.dueDate {
                let dueDateStart = calendar.startOfDay(for: dueDate)
                if dueDateStart < today {
                    overdue.append(item)
                } else if dueDateStart < tomorrow {
                    todayItems.append(item)
                } else if dueDateStart < weekEnd {
                    thisWeekItems.append(item)
                } else {
                    laterItems.append(item)
                }
            } else {
                noDateItems.append(item)
            }
        }

        // Her grup kendi içinde due date'e göre sıralı
        let sortByDue: (PlannerItem, PlannerItem) -> Bool = { a, b in
            switch (a.dueDate, b.dueDate) {
            case (let lhs?, let rhs?): return lhs < rhs
            case (nil, _?): return false
            case (_?, nil): return true
            case (nil, nil): return a.createdAt < b.createdAt
            }
        }

        var result: [(group: ItemGroup, items: [PlannerItem])] = []

        if !overdue.isEmpty { result.append((.overdue, overdue.sorted(by: sortByDue))) }
        if !todayItems.isEmpty { result.append((.today, todayItems.sorted(by: sortByDue))) }
        if !thisWeekItems.isEmpty {
            result.append((.thisWeek, thisWeekItems.sorted(by: sortByDue)))
        }
        if !laterItems.isEmpty { result.append((.later, laterItems.sorted(by: sortByDue))) }
        if !noDateItems.isEmpty {
            result.append((.noDate, noDateItems.sorted { $0.createdAt < $1.createdAt }))
        }

        if showCompleted && !completedItems.isEmpty {
            result.append((.completed, completedItems.sorted { $0.createdAt > $1.createdAt }))
        }

        return result
    }

    /// Tüm aktif (tamamlanmamış) görev sayısı
    func pendingCount(from items: [PlannerItem]) -> Int {
        items.filter { !$0.completed }.count
    }

    /// Vadesi geçmiş görev sayısı
    func overdueCount(from items: [PlannerItem]) -> Int {
        items.filter { $0.isOverdue }.count
    }

    // MARK: - Actions

    func toggleCompleted(_ item: PlannerItem, in context: ModelContext) {
        item.completed.toggle()
        let result = context.saveResult("PlannerItemsViewModel: toggleCompleted failed")
        if case .failure(let error) = result {
            appError = error
        }
    }

    func deleteItem(_ item: PlannerItem, in context: ModelContext) {
        context.delete(item)
        let result = context.saveResult("PlannerItemsViewModel: deleteItem failed")
        if case .failure(let error) = result {
            appError = error
        }
    }

    func deleteSelected(from items: [PlannerItem], in context: ModelContext) {
        let selected = items.filter { selectedItems.contains($0.id) }
        for item in selected {
            context.delete(item)
        }
        let result = context.saveResult("PlannerItemsViewModel: deleteSelected failed")
        if case .failure(let error) = result {
            appError = error
        }
        clearSelection()
    }

    func completeSelected(from items: [PlannerItem], in context: ModelContext) {
        let selected = items.filter { selectedItems.contains($0.id) }
        for item in selected {
            item.completed = true
        }
        let result = context.saveResult("PlannerItemsViewModel: completeSelected failed")
        if case .failure(let error) = result {
            appError = error
        }
        clearSelection()
    }

    func toggleSelection(for item: PlannerItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }

    func clearSelection() {
        selectedItems.removeAll()
        isEditing = false
    }
}
