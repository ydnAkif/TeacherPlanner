//
//  PeriodSetupView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

struct PeriodSetupView: View {
    @Environment(\.modelContext) private var modelContext

    let semesterName: String
    let startDate: Date
    let endDate: Date
    let onComplete: ([PeriodDefinition]) -> Void

    @State private var periods: [PeriodRow] = []
    @State private var editingIndex: Int? = nil

    // Geçici düzenleme state'i
    @State private var editTitle: String = ""
    @State private var editStart: Date = Date()
    @State private var editEnd: Date = Date()

    // MARK: - Yardımcı model (SwiftData'ya gitmeden önce in-memory tutar)
    struct PeriodRow: Identifiable {
        let id: UUID
        var title: String
        var startTime: Date
        var endTime: Date
        var orderIndex: Int
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primary.opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal)
                    .padding(.top, 8)

                List {
                    ForEach(Array(periods.enumerated()), id: \.element.id) { index, row in
                        periodRow(index: index, row: row)
                    }
                    .onDelete { offsets in
                        periods.remove(atOffsets: offsets)
                        reindex()
                    }

                    Section {
                        Button(action: addNewPeriod) {
                            Label("Yeni Ders Saati Ekle", systemImage: "plus.circle.fill")
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                }
                .listStyle(.insetGrouped)

                finishButton
                    .padding()
            }
        }
        .navigationTitle("Ders Saatleri")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Tamamla") {
                    finish()
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(
            isPresented: Binding(
                get: { editingIndex != nil },
                set: { if !$0 { editingIndex = nil } }
            )
        ) {
            editSheet
        }
        .onAppear {
            if periods.isEmpty {
                periods = defaultPeriods()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            stepIndicator(current: 2, total: 2)

            VStack(spacing: 4) {
                Text("Ders Saatlerini Ayarla")
                    .font(.title2.bold())
                Text(semesterName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 8)
    }

    private func stepIndicator(current: Int, total: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= current ? AppColors.primary : AppColors.primary.opacity(0.2))
                    .frame(width: step == current ? 24 : 12, height: 6)
            }
        }
    }

    // MARK: - Satır

    private func periodRow(index: Int, row: PeriodRow) -> some View {
        Button {
            editingIndex = index
            editTitle = row.title
            editStart = row.startTime
            editEnd = row.endTime
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(timeRangeString(start: row.startTime, end: row.endTime))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundStyle(AppColors.primary.opacity(0.6))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    periods.remove(at: index)
                    reindex()
                }
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }

    // MARK: - Düzenleme Sheet

    private var editSheet: some View {
        NavigationStack {
            Form {
                Section("Ders Adı") {
                    TextField("Örn: 1. Ders", text: $editTitle)
                }

                Section("Saatler") {
                    DatePicker(
                        "Başlangıç",
                        selection: $editStart,
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "Bitiş",
                        selection: $editEnd,
                        in: editStart...,
                        displayedComponents: .hourAndMinute
                    )

                    if editEnd <= editStart {
                        Label(
                            "Bitiş saati başlangıçtan sonra olmalı",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }
                }

                Section {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text("Süre: \(durationMinutes(start: editStart, end: editEnd)) dakika")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(editTitle.isEmpty ? "Ders Saati" : editTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        editingIndex = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveEdit()
                    }
                    .disabled(
                        editTitle.trimmingCharacters(in: .whitespaces).isEmpty
                            || editEnd <= editStart
                    )
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Alt Buton

    private var finishButton: some View {
        Button(action: finish) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Kurulumu Tamamla")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(periods.isEmpty ? Color.gray.opacity(0.3) : AppColors.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: AppColors.primary.opacity(periods.isEmpty ? 0 : 0.3),
                radius: 10, x: 0, y: 5
            )
        }
        .buttonStyle(.plain)
        .disabled(periods.isEmpty)
    }

    // MARK: - Aksiyonlar

    private func saveEdit() {
        guard let idx = editingIndex else { return }
        periods[idx].title = editTitle.trimmingCharacters(in: .whitespaces)
        periods[idx].startTime = editStart
        periods[idx].endTime = editEnd
        editingIndex = nil
    }

    private func addNewPeriod() {
        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        let nextIndex = periods.count + 1

        // Son ders saatinin bitişinden 10 dk sonra başlat
        let lastEnd = periods.last?.endTime
        let suggestedStart: Date
        if let lastEnd = lastEnd {
            suggestedStart = calendar.date(byAdding: .minute, value: 10, to: lastEnd) ?? lastEnd
        } else {
            suggestedStart = calendar.date(bySettingHour: 8, minute: 40, second: 0, of: baseDate)!
        }
        let suggestedEnd =
            calendar.date(byAdding: .minute, value: 40, to: suggestedStart) ?? suggestedStart

        periods.append(
            PeriodRow(
                id: UUID(),
                title: "\(nextIndex). Ders",
                startTime: suggestedStart,
                endTime: suggestedEnd,
                orderIndex: nextIndex
            ))

        // Hemen düzenleme modunu aç
        editingIndex = periods.count - 1
        editTitle = periods.last!.title
        editStart = periods.last!.startTime
        editEnd = periods.last!.endTime
    }

    private func reindex() {
        for i in periods.indices {
            periods[i].orderIndex = i + 1
        }
    }

    private func finish() {
        let defs = periods.map { row in
            PeriodDefinition(
                id: row.id,
                title: row.title,
                startTime: row.startTime,
                endTime: row.endTime,
                orderIndex: row.orderIndex
            )
        }
        onComplete(defs)
    }

    // MARK: - Yardımcılar

    private func timeRangeString(start: Date, end: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }

    private func durationMinutes(start: Date, end: Date) -> Int {
        max(0, Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0)
    }

    // MARK: - Varsayılan saatler

    private func defaultPeriods() -> [PeriodRow] {
        let c = Calendar.current
        let base = c.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        func t(_ h: Int, _ m: Int) -> Date {
            c.date(bySettingHour: h, minute: m, second: 0, of: base)!
        }
        return [
            PeriodRow(
                id: UUID(), title: "1. Ders", startTime: t(8, 40), endTime: t(9, 20), orderIndex: 1),
            PeriodRow(
                id: UUID(), title: "2. Ders", startTime: t(9, 30), endTime: t(10, 10), orderIndex: 2
            ),
            PeriodRow(
                id: UUID(), title: "3. Ders", startTime: t(10, 25), endTime: t(11, 5), orderIndex: 3
            ),
            PeriodRow(
                id: UUID(), title: "4. Ders", startTime: t(11, 15), endTime: t(11, 55),
                orderIndex: 4),
            PeriodRow(
                id: UUID(), title: "5. Ders", startTime: t(13, 0), endTime: t(13, 40), orderIndex: 5
            ),
            PeriodRow(
                id: UUID(), title: "6. Ders", startTime: t(13, 50), endTime: t(14, 30),
                orderIndex: 6),
        ]
    }
}

#Preview {
    NavigationStack {
        PeriodSetupView(
            semesterName: "2025-2026 Güz Dönemi",
            startDate: Date(),
            endDate: Date(),
            onComplete: { _ in }
        )
    }
}
