//
//  PlannerItemsViewModel.swift
//  TeacherPlanner
//

import Combine
import Foundation
import SwiftData

@MainActor
final class PlannerItemsViewModel: ObservableObject {

    // MARK: - Filter & UI State
    @Published var searchText: String = ""
    @Published var selectedType: PlannerItemType?
    @Published var isEditing: Bool = false
    @Published var selectedItems: Set<UUID> = []
    @Published var appError: AppError?

    // MARK: - Filtering
    func filteredItems(from items: [PlannerItem]) -> [PlannerItem] {
        items.filter { item in
            let matchesSearch =
                searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
            let matchesType = selectedType == nil || item.type == selectedType
            return matchesSearch && matchesType
        }
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
