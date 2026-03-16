//
//  PlannerItemListView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

struct PlannerItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlannerItem.createdAt, order: .reverse) private var items: [PlannerItem]

    @StateObject private var viewModel = PlannerItemsViewModel()
    @State private var showingAddItem = false
    @State private var addItemType: PlannerItemType = .task

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
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Başlık veya açıklama ara...")
            .toolbar { toolbar }
            .sheet(isPresented: $showingAddItem) {
                EditPlannerItemView(type: addItemType)
            }
            .overlay(alignment: .bottomTrailing) { addButton }
            .errorAlert(error: $viewModel.appError)
            .safeAreaInset(edge: .bottom) {
                // FAB için boşluk bırak
                Color.clear.frame(height: 80)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                // Tip filtresi
                Section("Filtrele") {
                    Picker("Tip", selection: $viewModel.selectedType) {
                        Label("Tümü", systemImage: "tray.full")
                            .tag(nil as PlannerItemType?)
                        ForEach(PlannerItemType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.systemImage)
                                .tag(type as PlannerItemType?)
                        }
                    }
                }

                // Tamamlananları göster
                Section {
                    Button {
                        withAnimation {
                            viewModel.showCompleted.toggle()
                        }
                    } label: {
                        Label(
                            viewModel.showCompleted
                                ? "Tamamlananları Gizle" : "Tamamlananları Göster",
                            systemImage: viewModel.showCompleted
                                ? "eye.slash.circle"
                                : "checkmark.circle"
                        )
                    }
                }

                Divider()

                // Seçim modu
                Section {
                    Button {
                        viewModel.isEditing.toggle()
                        if !viewModel.isEditing {
                            viewModel.selectedItems.removeAll()
                        }
                    } label: {
                        Label(
                            viewModel.isEditing ? "Seçimi Bitir" : "Seç",
                            systemImage: viewModel.isEditing
                                ? "checkmark.circle.fill"
                                : "checkmark.circle"
                        )
                    }

                    if viewModel.isEditing && !viewModel.selectedItems.isEmpty {
                        Button {
                            viewModel.completeSelected(from: items, in: modelContext)
                        } label: {
                            Label(
                                "Seçilenleri Tamamla (\(viewModel.selectedItems.count))",
                                systemImage: "checkmark.circle"
                            )
                        }

                        Button(role: .destructive) {
                            viewModel.deleteSelected(from: items, in: modelContext)
                        } label: {
                            Label(
                                "Seçilenleri Sil (\(viewModel.selectedItems.count))",
                                systemImage: "trash"
                            )
                        }
                    }
                }
            } label: {
                filterIcon
            }
        }
    }

    // MARK: - Filter Icon (active filter indicator)

    private var filterIcon: some View {
        let isFiltered = viewModel.selectedType != nil || viewModel.showCompleted
        return Image(
            systemName: isFiltered
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle"
        )
        .foregroundStyle(isFiltered ? .blue : .primary)
        .overlay(alignment: .topTrailing) {
            if overdueCount > 0 {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .offset(x: 3, y: -3)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: "checklist",
            title: "Henüz Görev Yok",
            message: "Yeni görev, ödev veya not eklemek için + butonunu kullanın",
            actionLabel: "Görev Ekle",
            action: {
                addItemType = .task
                showingAddItem = true
            }
        )
    }

    // MARK: - Add FAB

    private var addButton: some View {
        Menu {
            ForEach(PlannerItemType.allCases, id: \.self) { type in
                Button {
                    addItemType = type
                    showingAddItem = true
                } label: {
                    Label(type.displayName, systemImage: type.systemImage)
                }
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .blue.opacity(0.4), radius: 8, y: 4)

                if pendingCount > 0 {
                    Text("\(pendingCount)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(.red)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .padding(.trailing)
        .padding(.bottom, 8)
    }

    // MARK: - Computed

    private var pendingCount: Int {
        viewModel.pendingCount(from: items)
    }

    private var overdueCount: Int {
        viewModel.overdueCount(from: items)
    }
}

// MARK: - Preview

#Preview {
    PlannerItemListView()
        .modelContainer(try! ModelContainerFactory.createPreview())
}
