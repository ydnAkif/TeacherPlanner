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
    @State private var selectedPeriod: PeriodDefinition?
    @State private var showingEditSession = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && !viewModel.isInitialized {
                    ProgressView("Yükleniyor...")
                } else if let data = viewModel.viewData {
                    ScheduleGridView(
                        data: data,
                        onCellTap: { cell, period in
                            selectedCell = cell
                            selectedPeriod = period
                            showingEditSession = true
                        },
                        onDeleteSession: { session in
                            viewModel.deleteSession(session)
                        }
                    )
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
                if let cell = selectedCell, let period = selectedPeriod {
                    EditClassSessionView(weekday: cell.weekday, period: period)
                }
            }
            .errorAlert(error: $viewModel.appError)
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
}

#Preview {
    WeeklyScheduleView()
}
