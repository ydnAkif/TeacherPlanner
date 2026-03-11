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
    private var useCase: (any PlannerTaskUseCaseProtocol)?

    // MARK: - Setup
    func setup(useCase: any PlannerTaskUseCaseProtocol) {
        self.useCase = useCase
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
        guard let useCase = useCase else { return }
        Task {
            do {
                try await useCase.toggleCompleted(item)
            } catch {
                appError = AppError.from(error: error)
            }
        }
    }

    func deleteItem(_ item: PlannerItem) {
        guard let useCase = useCase else { return }
        Task {
            do {
                try await useCase.deleteItem(item)
            } catch {
                appError = AppError.from(error: error)
            }
        }
    }

    func deleteSelected(from items: [PlannerItem]) {
        guard let useCase = useCase else { return }
        let selected = items.filter { selectedItems.contains($0.id) }
        Task {
            do {
                for item in selected {
                    try await useCase.deleteItem(item)
                }
                clearSelection()
            } catch {
                appError = AppError.from(error: error)
            }
        }
    }

    func completeSelected(from items: [PlannerItem]) {
        guard let useCase = useCase else { return }
        let selected = items.filter { selectedItems.contains($0.id) }
        Task {
            do {
                for item in selected {
                    try await useCase.toggleCompleted(item)
                }
                clearSelection()
            } catch {
                appError = AppError.from(error: error)
            }
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
