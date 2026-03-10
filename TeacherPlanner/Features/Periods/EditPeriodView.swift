//
//  EditPeriodView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

/// Ders saati ekleme/düzenleme ekranı
struct EditPeriodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let periodToEdit: PeriodDefinition?

    @State private var title: String = ""
    @State private var startTime: Date =
        Calendar.current.date(from: DateComponents(hour: 8, minute: 40)) ?? Date()
    @State private var endTime: Date =
        Calendar.current.date(from: DateComponents(hour: 9, minute: 20)) ?? Date()

    init(period: PeriodDefinition? = nil) {
        self.periodToEdit = period

        if let period = period {
            _title = State(initialValue: period.title)
            _startTime = State(initialValue: period.startTime)
            _endTime = State(initialValue: period.endTime)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Genel") {
                    TextField("Ders Adı (örn: 1. Ders)", text: $title)
                }

                Section("Zaman") {
                    DatePicker(
                        "Başlangıç", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Bitiş", selection: $endTime, displayedComponents: .hourAndMinute)

                    if startTime >= endTime {
                        Label(
                            "Bitiş saati başlangıçtan sonra olmalıdır",
                            systemImage: "exclamationmark.triangle"
                        )
                        .foregroundStyle(.red)
                        .font(.caption)
                    }
                }

                Section("Önizleme") {
                    HStack {
                        Text(title.isEmpty ? "Ders Adı" : title)
                        Spacer()
                        Text("\(timeString(from: startTime)) - \(timeString(from: endTime))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(periodToEdit == nil ? "Yeni Ders Saati" : "Düzenle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        save()
                        dismiss()
                    }
                    .disabled(title.isEmpty || startTime >= endTime)
                }
            }
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func save() {
        if let period = periodToEdit {
            period.title = title
            period.startTime = startTime
            period.endTime = endTime
        } else {
            // Yeni period için son orderIndex'i bul
            let descriptor = FetchDescriptor<PeriodDefinition>(
                sortBy: [SortDescriptor(\.orderIndex, order: .reverse)]
            )
            let periods = (try? modelContext.fetch(descriptor)) ?? []
            let nextOrder = (periods.first?.orderIndex ?? 0) + 1

            let newPeriod = PeriodDefinition(
                title: title,
                startTime: startTime,
                endTime: endTime,
                orderIndex: nextOrder
            )
            modelContext.insert(newPeriod)
        }

        try? modelContext.save()
    }
}

#Preview {
    EditPeriodView()
}
