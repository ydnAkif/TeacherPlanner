//
//  SkippedDaysView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct SkippedDaysView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let semester: Semester

    @State private var showingAddDay = false
    @State private var selectedDate: Date = Date()
    @State private var selectedType: SkipType = .manual
    @State private var reason: String = ""
    @State private var appError: AppError?

    var body: some View {
        NavigationStack {
            List {
                Section("Manuel Ekle") {
                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)

                    Picker("Tip", selection: $selectedType) {
                        ForEach(SkipType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    TextField("Sebep (Opsiyonel)", text: $reason)

                    HStack {
                        Button(action: addSkippedDay) {
                            Label("Ekle", systemImage: "plus.circle.fill")
                        }

                        Menu {
                            Button("Hafta Sonlarını Ekle", action: addWeekends)
                            Button("Tüm Pazartesileri Ekle", action: addAllMondays)
                        } label: {
                            Label("Toplu Ekle", systemImage: "calendar.badge.plus")
                        }
                    }
                }

                Section("Tatil Günleri (\(semester.skippedDays.count))") {
                    if semester.skippedDays.isEmpty {
                        Text("Henüz tatil günü eklenmedi")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(semester.skippedDays.sorted { $0.date < $1.date }) { skippedDay in
                            SkippedDayRow(skippedDay: skippedDay)
                                .swipeActions(edge: .trailing) {
                                    Button("Sil", role: .destructive) {
                                        deleteSkippedDay(skippedDay)
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Tatil Günleri")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") {
                        dismiss()
                    }
                }
            }
            .errorAlert(error: $appError)
        }
    }

    private func addSkippedDay() {
        let calendar = Calendar.current
        let dateOnly = calendar.startOfDay(for: selectedDate)
        let exists = semester.skippedDays.contains { day in
            calendar.startOfDay(for: day.date) == dateOnly
        }

        guard !exists else { return }

        let skippedDay = SkippedDay(
            date: selectedDate,
            reason: reason.isEmpty ? selectedType.displayName : reason,
            type: selectedType
        )
        skippedDay.semester = semester
        modelContext.insert(skippedDay)
        modelContext
            .saveResult("SkippedDaysView: add skipped day save failed")
            .onFailure { appError = $0 }
        reason = ""
    }

    private func deleteSkippedDay(_ skippedDay: SkippedDay) {
        modelContext.delete(skippedDay)
        modelContext
            .saveResult("SkippedDaysView: delete skipped day save failed")
            .onFailure { appError = $0 }
    }

    private func addSkippedDayIfNotExists(date: Date, type: SkipType, reason: String) {
        let calendar = Calendar.current
        let dateOnly = calendar.startOfDay(for: date)
        let exists = semester.skippedDays.contains { day in
            calendar.startOfDay(for: day.date) == dateOnly
        }

        if !exists {
            let skippedDay = SkippedDay(date: date, reason: reason, type: type)
            skippedDay.semester = semester
            modelContext.insert(skippedDay)
        }
    }

    private func addWeekends() {
        let calendar = Calendar.current
        var date = semester.startDate

        while date <= semester.endDate {
            let weekday = calendar.component(.weekday, from: date)
            if weekday == 1 || weekday == 7 {
                addSkippedDayIfNotExists(date: date, type: .weekend, reason: "Hafta Sonu")
            }
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        modelContext
            .saveResult("SkippedDaysView: add weekends save failed")
            .onFailure { appError = $0 }
    }

    private func addAllMondays() {
        let calendar = Calendar.current
        var date = semester.startDate

        while date <= semester.endDate {
            let weekday = calendar.component(.weekday, from: date)
            if weekday == 2 {
                addSkippedDayIfNotExists(date: date, type: .manual, reason: "Pazartesi Tatil")
            }
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        modelContext
            .saveResult("SkippedDaysView: add all mondays save failed")
            .onFailure { appError = $0 }
    }
}

struct SkippedDayRow: View {
    let skippedDay: SkippedDay

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dateFormatter.string(from: skippedDay.date))
                    .font(.body)
                    .fontWeight(.medium)

                Text(weekdayFormatter.string(from: skippedDay.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 100, alignment: .leading)

            Text(skippedDay.type.displayName)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(typeColor(skippedDay.type).opacity(0.2))
                .foregroundStyle(typeColor(skippedDay.type))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            if !skippedDay.reason.isEmpty {
                Text(skippedDay.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func typeColor(_ type: SkipType) -> Color {
        switch type {
        case .weekend: return .gray
        case .holiday: return .red
        case .semesterBreak: return .orange
        case .manual: return .blue
        }
    }
}

#Preview {
    SkippedDaysView(
        semester: Semester(
            name: "2025-2026 Güz Dönemi",
            startDate: Date(),
            endDate: Date()
        )
    )
}
