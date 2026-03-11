//
//  PlannerItemListView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct PlannerItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var appEnvironment
    @Query(sort: \PlannerItem.createdAt, order: .reverse) private var items: [PlannerItem]

    @StateObject private var viewModel = PlannerItemsViewModel()
    @State private var showingAddItem = false

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    PlannerItemList(items: items, viewModel: viewModel)
                }
            }
            .navigationTitle("Görevler")
            .searchable(text: $viewModel.searchText, prompt: "Ara...")
            .toolbar { toolbar }
            .sheet(isPresented: $showingAddItem) { EditPlannerItemView() }
            .overlay(alignment: .bottomTrailing) { addButton }
            .errorAlert(error: $viewModel.appError)
            .onAppear {
                if let env = appEnvironment {
                    viewModel.setup(useCase: env.plannerTaskUseCase)
                }
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Picker("Filtre", selection: $viewModel.selectedType) {
                    Text("Tümü").tag(nil as PlannerItemType?)
                    ForEach(PlannerItemType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type as PlannerItemType?)
                    }
                }

                Divider()

                Button(viewModel.isEditing ? "Bitti" : "Seç") {
                    viewModel.isEditing.toggle()
                    if !viewModel.isEditing { viewModel.selectedItems.removeAll() }
                }

                if viewModel.isEditing && !viewModel.selectedItems.isEmpty {
                    Button(role: .destructive) {
                        viewModel.deleteSelected(from: items)
                    } label: {
                        Label("Sil (\(viewModel.selectedItems.count))", systemImage: "trash")
                    }

                    Button {
                        viewModel.completeSelected(from: items)
                    } label: {
                        Label("Tamamla", systemImage: "checkmark.circle")
                    }
                }
            } label: {
                Image(systemName: viewModel.isEditing
                    ? "checkmark.circle.fill"
                    : "line.3.horizontal.decrease.circle")
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            icon: "checklist",
            title: "Henüz Görev Yok",
            message: "Yeni görev veya not eklemek için + butonuna tıklayın",
            actionLabel: "Görev Ekle",
            action: { showingAddItem = true }
        )
    }

    // MARK: - Add Button
    private var addButton: some View {
        Button(action: { showingAddItem = true }) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)
        }
        .padding()
    }
}

#Preview {
    PlannerItemListView()
}
