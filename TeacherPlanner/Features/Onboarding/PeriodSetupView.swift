//
//  PeriodSetupView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct PeriodSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var periods: [PeriodDefinition] = []

    var body: some View {
        NavigationStack {
            List {
                Section("Ders Saatleri") {
                    ForEach($periods) { $period in
                        PeriodEditRow(period: $period)
                    }
                }

                Section {
                    Button(action: addNewPeriod) {
                        Label("Yeni Ders Saati Ekle", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Ders Saatleri")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Varsayılanları Kullan") {
                        savePeriods()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamamla") {
                        savePeriods()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if periods.isEmpty {
                    periods = defaultPeriods()
                }
            }
        }
    }

    private func defaultPeriods() -> [PeriodDefinition] {
        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!

        return [
            PeriodDefinition(
                title: "1. Ders",
                startTime: calendar.date(bySettingHour: 8, minute: 40, second: 0, of: baseDate)!,
                endTime: calendar.date(bySettingHour: 9, minute: 20, second: 0, of: baseDate)!,
                orderIndex: 1),
            PeriodDefinition(
                title: "2. Ders",
                startTime: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: baseDate)!,
                endTime: calendar.date(bySettingHour: 10, minute: 10, second: 0, of: baseDate)!,
                orderIndex: 2),
            PeriodDefinition(
                title: "3. Ders",
                startTime: calendar.date(bySettingHour: 10, minute: 25, second: 0, of: baseDate)!,
                endTime: calendar.date(bySettingHour: 11, minute: 5, second: 0, of: baseDate)!,
                orderIndex: 3),
            PeriodDefinition(
                title: "4. Ders",
                startTime: calendar.date(bySettingHour: 11, minute: 15, second: 0, of: baseDate)!,
                endTime: calendar.date(bySettingHour: 11, minute: 55, second: 0, of: baseDate)!,
                orderIndex: 4),
            PeriodDefinition(
                title: "5. Ders",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: baseDate)!,
                endTime: calendar.date(bySettingHour: 13, minute: 40, second: 0, of: baseDate)!,
                orderIndex: 5),
            PeriodDefinition(
                title: "6. Ders",
                startTime: calendar.date(bySettingHour: 13, minute: 50, second: 0, of: baseDate)!,
                endTime: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: baseDate)!,
                orderIndex: 6),
        ]
    }

    private func addNewPeriod() {
        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        let nextIndex = periods.count + 1

        let newPeriod = PeriodDefinition(
            title: "\(nextIndex). Ders",
            startTime: calendar.date(
                bySettingHour: 8 + nextIndex, minute: 40, second: 0, of: baseDate)!,
            endTime: calendar.date(
                bySettingHour: 9 + nextIndex, minute: 20, second: 0, of: baseDate)!,
            orderIndex: nextIndex
        )
        periods.append(newPeriod)
    }

    private func savePeriods() {
        for period in periods {
            modelContext.insert(period)
        }
        try? modelContext.save()
    }
}

struct PeriodEditRow: View {
    @Binding var period: PeriodDefinition

    var body: some View {
        HStack {
            TextField("Ders Adı", text: $period.title)
            Text("\(period.startTimeString) - \(period.endTimeString)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PeriodSetupView()
}
