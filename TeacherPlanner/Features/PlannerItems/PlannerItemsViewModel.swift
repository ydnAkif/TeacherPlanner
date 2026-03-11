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
    @Published var appError: AppError?

    // MARK: - Dependencies
    private var repository: (any PlannerRepositoryProtocol)?

    // MARK: - Setup
    func setup(repository: any PlannerRepositoryProtocol) {
        self.repository = repository
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
        guard let repo = repository else { return }
        Task {
            let result = await repo.toggleCompleted(item)
            if case .failure(let error) = result {
                appError = error
            }
        }
    }

    func deleteItem(_ item: PlannerItem) {
        guard let repo = repository else { return }
        Task {
            let result = await repo.delete(item)
            if case .failure(let error) = result {
                appError = error
            }
        }
    }

    func deleteSelected(from items: [PlannerItem]) {
        guard let repo = repository else { return }
        let selected = items.filter { selectedItems.contains($0.id) }
        Task {
            for item in selected {
                let result = await repo.delete(item)
                if case .failure(let error) = result {
                    appError = error
                    return
                }
            }
            clearSelection()
        }
    }

    func completeSelected(from items: [PlannerItem]) {
        guard let repo = repository else { return }
        let selected = items.filter { selectedItems.contains($0.id) }
        Task {
            for item in selected {
                let result = await repo.toggleCompleted(item)
                if case .failure(let error) = result {
                    appError = error
                    return
                }
            }
            clearSelection()
        }
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
    private func placeholder() { }
}
