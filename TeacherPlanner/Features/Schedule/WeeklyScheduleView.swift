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

    @State private var viewData: WeeklyViewData?
    @State private var isLoading = false
    @State private var appError: AppError?

    @State private var selectedCell: WeeklyCell?
    @State private var selectedPeriod: PeriodDefinition?
    @State private var showingEditSession = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && viewData == nil {
                    ProgressView("Yükleniyor...")
                } else if let data = viewData {
                    ScheduleGridView(
                        data: data,
                        onCellTap: { cell, period in
                            selectedCell = cell
                            selectedPeriod = period
                            showingEditSession = true
                        },
                        onDeleteSession: { session in
                            deleteSession(session)
                        }
                    )
                } else {
                    emptyState
                }
            }
            .navigationTitle("Program")
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
            .sheet(isPresented: $showingEditSession) {
                if let cell = selectedCell, let period = selectedPeriod {
                    EditClassSessionView(weekday: cell.weekday, period: period)
                }
            }
            .errorAlert(error: $appError)
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

    // MARK: - Actions

    @MainActor
    private func loadData() async {
        guard let builder = appEnvironment?.weeklyScheduleBuilder else { return }
        isLoading = true
        viewData = builder.buildWeeklyView()
        isLoading = false
    }

    private func deleteSession(_ session: ClassSession) {
        modelContext.delete(session)
        do {
            try modelContext.save()
            Task { await loadData() }
        } catch {
            appError = AppError.from(error: error)
        }
    }
}

#Preview {
    WeeklyScheduleView()
}
