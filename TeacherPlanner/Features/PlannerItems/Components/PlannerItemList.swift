//
//  PlannerItemList.swift
//  TeacherPlanner
//
//  Created by Antigravity on 11.03.2026.
//

import SwiftData
import SwiftUI

struct PlannerItemList: View {
    @Environment(\.modelContext) private var modelContext

    let items: [PlannerItem]
    @ObservedObject var viewModel: PlannerItemsViewModel

    var body: some View {
        List {
            let filtered = viewModel.filteredItems(from: items)
            if filtered.isEmpty {
                ContentUnavailableView {
                    Label("Sonuç Bulunamadı", systemImage: "magnifyingglass")
                } description: {
                    Text("Arama kriterlerinizi değiştirin")
                }
            } else {
                ForEach(filtered) { item in
                    PlannerItemRow(
                        item: item,
                        onToggle: {
                            viewModel.toggleCompleted(item, in: modelContext)
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteItem(item, in: modelContext)
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.isEditing {
                            viewModel.toggleSelection(for: item)
                        }
                    }
                    .overlay {
                        if viewModel.isEditing {
                            selectionOverlay(for: item)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func selectionOverlay(for item: PlannerItem) -> some View {
        let isSelected = viewModel.selectedItems.contains(item.id)
        RoundedRectangle(cornerRadius: 8)
            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title2)
            .foregroundStyle(.blue)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}
