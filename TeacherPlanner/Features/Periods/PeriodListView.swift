//
//  PeriodListView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

/// Ders saatleri listesi
struct PeriodListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PeriodDefinition.orderIndex) private var periods: [PeriodDefinition]

    @State private var showingAddPeriod = false

    var body: some View {
        NavigationStack {
            Group {
                if periods.isEmpty {
                    emptyState
                } else {
                    periodList
                }
            }
            .navigationTitle("Ders Saatleri")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPeriod = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPeriod) {
                EditPeriodView()
            }
        }
    }

    private var periodList: some View {
        List {
            ForEach(periods) { period in
                PeriodRow(period: period)
            }
            // onMove şimdilik devre dışı (SwiftData reorder desteği için)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Ders Saati Yok", systemImage: "clock")
                .font(.title2)
        } description: {
            Text("Ders saatlerini eklemek için + butonuna tıklayın")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PeriodListView()
}
