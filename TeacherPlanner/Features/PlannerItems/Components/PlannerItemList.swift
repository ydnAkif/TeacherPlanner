//
//  PlannerItemList.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

struct PlannerItemList: View {
    @Environment(\.modelContext) private var modelContext

    let items: [PlannerItem]
    @ObservedObject var viewModel: PlannerItemsViewModel

    @State private var itemToEdit: PlannerItem?

    var body: some View {
        let groups = viewModel.groupedItems(from: items)

        if groups.isEmpty {
            emptyState
        } else {
            List {
                ForEach(groups, id: \.group) { entry in
                    Section {
                        ForEach(entry.items) { item in
                            PlannerItemRow(
                                item: item,
                                onToggle: {
                                    viewModel.toggleCompleted(item, in: modelContext)
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(for: item)
                                } else {
                                    itemToEdit = item
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.toggleCompleted(item, in: modelContext)
                                } label: {
                                    Label(
                                        item.completed ? "Geri Al" : "Tamamla",
                                        systemImage: item.completed
                                            ? "arrow.uturn.backward.circle"
                                            : "checkmark.circle"
                                    )
                                }
                                .tint(item.completed ? .orange : .green)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteItem(item, in: modelContext)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }

                                Button {
                                    itemToEdit = item
                                } label: {
                                    Label("Düzenle", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .overlay {
                                if viewModel.isEditing {
                                    selectionOverlay(for: item)
                                }
                            }
                        }
                    } header: {
                        GroupSectionHeader(group: entry.group, count: entry.items.count)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .sheet(item: $itemToEdit) { item in
                EditPlannerItemView(item: item)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Sonuç Bulunamadı", systemImage: "magnifyingglass")
        } description: {
            Text("Arama veya filtre kriterlerinizi değiştirin")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Selection Overlay

    @ViewBuilder
    private func selectionOverlay(for item: PlannerItem) -> some View {
        let isSelected = viewModel.selectedItems.contains(item.id)

        RoundedRectangle(cornerRadius: 8)
            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title2)
            .foregroundStyle(isSelected ? .blue : .secondary)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

// MARK: - Group Section Header

private struct GroupSectionHeader: View {
    let group: ItemGroup
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: group.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(group.color)

            Text(group.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(group.color)

            Spacer()

            Text("\(count)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(group.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(group.color.opacity(0.15))
                .clipShape(Capsule())
        }
        .textCase(nil)
    }
}
