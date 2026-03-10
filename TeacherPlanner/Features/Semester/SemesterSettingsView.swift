//
//  SemesterSettingsView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct SemesterSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var semesters: [Semester]

    @State private var showingAddSemester = false
    @State private var selectedSemester: Semester?
    @State private var showingSkippedDays = false

    var body: some View {
        NavigationStack {
            Group {
                if semesters.isEmpty {
                    emptyState
                } else {
                    semesterList
                }
            }
            .navigationTitle("Semester")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSemester = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSemester) {
                EditSemesterView()
            }
            .sheet(item: $selectedSemester) { semester in
                EditSemesterView(semester: semester)
            }
        }
    }

    private var semesterList: some View {
        List {
            Section("Dönemler") {
                ForEach(semesters.sorted { $0.startDate > $1.startDate }) { semester in
                    NavigationLink {
                        SkippedDaysView(semester: semester)
                    } label: {
                        SemesterRow(semester: semester)
                    }
                    .contextMenu {
                        Button(action: { selectedSemester = semester }) {
                            Label("Düzenle", systemImage: "pencil")
                        }
                    }
                }
            }

            Section("Hızlı Erişim") {
                NavigationLink {
                    PeriodListView()
                } label: {
                    Label("Ders Saatleri", systemImage: "clock")
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Dönem Yok", systemImage: "graduationcap")
                .font(.title2)
        } description: {
            Text("Yeni dönem eklemek için + butonuna tıklayın")
                .foregroundStyle(.secondary)
        }
    }

    private func deleteSemester(at indexSet: IndexSet) {
        for index in indexSet {
            let semester = semesters.sorted { $0.startDate > $1.startDate }[index]
            modelContext.delete(semester)
        }
        try? modelContext.save()
    }
}

/// Dönem satırı
struct SemesterRow: View {
    let semester: Semester

    var body: some View {
        HStack(spacing: 12) {
            // Aktif badge
            if semester.isActive {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(semester.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack {
                    Text(semester.startDate, style: .date)
                    Text("→")
                    Text(semester.endDate, style: .date)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Label(
                    "\(semester.skippedDays.count) tatil günü",
                    systemImage: "calendar.badge.exclamationmark"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Weekend rule
            Text(semester.weekendRule.displayName)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

extension WeekendRule {
    var displayName: String {
        switch self {
        case .saturdaySunday: return "Cmt-Paz"
        case .sundayOnly: return "Pazar"
        case .none: return "Yok"
        }
    }
}

#Preview {
    SemesterSettingsView()
}
