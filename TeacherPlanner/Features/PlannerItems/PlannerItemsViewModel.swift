//
//  PlannerItemsViewModel.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 10.03.2026.
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
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private var modelContext: ModelContext?

    // MARK: - Setup
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Filtering
    func filteredItems(from items: [PlannerItem]) -> [PlannerItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
            let matchesType = selectedType == nil || item.type == selectedType
            return matchesSearch && matchesType
        }
    }

    // MARK: - Actions
    func toggleCompleted(_ item: PlannerItem) {
        item.completed.toggle()
        save()
    }

    func deleteItem(_ item: PlannerItem) {
        guard let context = modelContext else { return }
        context.delete(item)
        save()
    }

    func deleteSelected(from items: [PlannerItem]) {
        guard let context = modelContext else { return }
        items.filter { selectedItems.contains($0.id) }.forEach {
            context.delete($0)
        }
        save()
        clearSelection()
    }

    func completeSelected(from items: [PlannerItem]) {
        items.filter { selectedItems.contains($0.id) }.forEach {
            $0.completed = true
        }
        save()
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

    // MARK: - Private Helpers
    private func save() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            AppLogger.error(error, message: "PlannerItemsViewModel: save failed")
            errorMessage = "Görev kaydedilemedi. Lütfen tekrar deneyin."
        }
    }
}
