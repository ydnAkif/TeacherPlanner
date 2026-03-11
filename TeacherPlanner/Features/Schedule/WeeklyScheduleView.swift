//
//  WeeklyScheduleView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct WeeklyScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var appEnvironment
    @StateObject private var viewModel = WeeklyScheduleViewModel()
    
    @State private var selectedCell: WeeklyCell?
    @State private var showingEditSession = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && !viewModel.isInitialized {
                    ProgressView("Yükleniyor...")
                } else if let data = viewModel.viewData {
                    scheduleGrid(data)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Weekly Schedule")
            .task {
                if let env = appEnvironment {
                    viewModel.setup(modelContext: modelContext, builder: env.weeklyScheduleBuilder)
                }
            }
            .refreshable { await viewModel.loadData() }
            .sheet(isPresented: $showingEditSession) {
                if let cell = selectedCell, let period = viewModel.viewData?.rows.first?.period {
                    EditClassSessionView(weekday: cell.weekday, period: period)
                }
            }
            .errorAlert(error: $viewModel.appError)
        }
    }

    private func scheduleGrid(_ data: WeeklyViewData) -> some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                headerRow(data)

                ForEach(data.rows.indices, id: \.self) { index in
                    let row = data.rows[index]
                    ScheduleRowView(
                        row: row,
                        onCellTap: { cell in
                            selectedCell = cell
                            showingEditSession = true
                        },
                        onDeleteSession: { session in
                            viewModel.deleteSession(session)
                        })

                    if index < data.rows.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "calendar.badge.exclamationmark",
            title: "Program Yok",
            message: "Henüz haftalık program eklenmedi",
            actionLabel: nil,
            action: nil
        )
    }

    private func headerRow(_ data: WeeklyViewData) -> some View {
        HStack(spacing: 0) {
            Text("Period")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 80)
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)

            ForEach(data.weekdays, id: \.self) { weekday in
                Text(Weekday.fromCalendarWeekday(weekday)?.shortName ?? "")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppColors.cardBackground)
            }
        }
    }
}

struct ScheduleRowView: View {
    let row: WeeklyRow
    let onCellTap: (WeeklyCell) -> Void
    let onDeleteSession: (ClassSession) -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.period.title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("\(row.period.startTimeString)-\(row.period.endTimeString)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            ForEach(row.cells.indices, id: \.self) { index in
                let cell = row.cells[index]
                ScheduleCellView(
                    cell: cell,
                    onTap: {
                        onCellTap(cell)
                    },
                    onDelete: {
                        if let session = cell.session {
                            onDeleteSession(session)
                        }
                    }
                )
                .frame(maxWidth: .infinity)

                if index < row.cells.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WeeklyScheduleView()
}
