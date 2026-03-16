//
//  PeriodSetupView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

// MARK: - Editing State (Identifiable, sheet(item:) için)

private struct EditingPeriod: Identifiable {
    let id: UUID
    var index: Int
    var title: String
    var startTime: Date
    var endTime: Date
}

// MARK: - PeriodSetupView

struct PeriodSetupView: View {
    @Environment(\.modelContext) private var modelContext

    let semesterName: String
    let startDate: Date
    let endDate: Date
    let weekendRule: WeekendRule
    let onComplete: () -> Void

    // MARK: State

    @State private var periods: [PeriodRow] = []
    @State private var editingPeriod: EditingPeriod? = nil
    @State private var isSaving = false
    @State private var saveError: AppError?

    // MARK: In-memory model

    struct PeriodRow: Identifiable {
        let id: UUID
        var title: String
        var startTime: Date
        var endTime: Date
        var orderIndex: Int
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

            List {
                Section {
                    ForEach(Array(periods.enumerated()), id: \.element.id) { index, row in
                        periodRow(index: index, row: row)
                    }
                    .onDelete { offsets in
                        periods.remove(atOffsets: offsets)
                        reindex()
                    }
                }

                Section {
                    Button {
                        addNewPeriod()
                    } label: {
                        Label("Yeni Ders Saati Ekle", systemImage: "plus.circle.fill")
                            .foregroundStyle(AppColors.primary)
                    }
                }
            }
            .listStyle(.insetGrouped)

            finishButton
                .padding(.horizontal)
                .padding(.vertical, 12)
        }
        .background(
            LinearGradient(
                colors: [AppColors.primary.opacity(0.04), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Ders Saatleri")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Tamamla", action: finish)
                    .fontWeight(.semibold)
                    .disabled(periods.isEmpty || isSaving)
            }
        }
        // sheet(item:) — isPresented: Bool'dan daha güvenilir
        .sheet(item: $editingPeriod) { ep in
            editSheet(for: ep)
        }
        .errorAlert(error: $saveError)
        .onAppear {
            if periods.isEmpty {
                periods = defaultPeriods()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            stepDots(current: 3, total: 3)

            VStack(spacing: 4) {
                Text("Ders Saatlerini Ayarla")
                    .font(.title2.bold())
                Text(semesterName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 4)
    }

    private func stepDots(current: Int, total: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= current ? AppColors.primary : AppColors.primary.opacity(0.2))
                    .frame(width: step == current ? 24 : 12, height: 6)
            }
        }
    }

    // MARK: - Period Row

    private func periodRow(index: Int, row: PeriodRow) -> some View {
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
                .foregroundStyle(AppColors.primary.opacity(0.5))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            editingPeriod = EditingPeriod(
                id: row.id,
                index: index,
                title: row.title,
                startTime: row.startTime,
                endTime: row.endTime
            )
        }
    }

    // MARK: - Edit Sheet

    @ViewBuilder
    private func editSheet(for ep: EditingPeriod) -> some View {
        EditPeriodSheetView(
            initialTitle: ep.title,
            initialStart: ep.startTime,
            initialEnd: ep.endTime,
            onSave: { newTitle, newStart, newEnd in
                if let idx = periods.firstIndex(where: { $0.id == ep.id }) {
                    periods[idx].title = newTitle
                    periods[idx].startTime = newStart
                    periods[idx].endTime = newEnd
                }
                editingPeriod = nil
            },
            onCancel: {
                editingPeriod = nil
            }
        )
    }

    // MARK: - Bottom Button

    private var finishButton: some View {
        Button(action: finish) {
            HStack(spacing: 10) {
                if isSaving {
                    ProgressView().tint(.white).scaleEffect(0.9)
                    Text("Kaydediliyor…").fontWeight(.bold)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Kurulumu Tamamla").fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(periods.isEmpty || isSaving ? Color.gray.opacity(0.3) : AppColors.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: AppColors.primary.opacity(periods.isEmpty || isSaving ? 0 : 0.3),
                radius: 10, x: 0, y: 5
            )
        }
        .disabled(periods.isEmpty || isSaving)
    }

    // MARK: - Actions

    private func addNewPeriod() {
        let calendar = Calendar.current
        let base = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        let nextIndex = periods.count + 1

        let lastEnd = periods.last?.endTime
        let suggestedStart: Date
        if let lastEnd {
            suggestedStart = calendar.date(byAdding: .minute, value: 10, to: lastEnd) ?? lastEnd
        } else {
            suggestedStart = calendar.date(bySettingHour: 8, minute: 40, second: 0, of: base)!
        }
        let suggestedEnd =
            calendar.date(byAdding: .minute, value: 40, to: suggestedStart) ?? suggestedStart

        let newRow = PeriodRow(
            id: UUID(),
            title: "\(nextIndex). Ders",
            startTime: suggestedStart,
            endTime: suggestedEnd,
            orderIndex: nextIndex
        )
        periods.append(newRow)

        // Yeni eklenen satırı hemen düzenlemeye aç
        editingPeriod = EditingPeriod(
            id: newRow.id,
            index: periods.count - 1,
            title: newRow.title,
            startTime: newRow.startTime,
            endTime: newRow.endTime
        )
    }

    private func reindex() {
        for i in periods.indices {
            periods[i].orderIndex = i + 1
        }
    }

    /// Arka plan hesaplaması ile kayıt — UI donmasını önler.
    /// Tatil/hafta sonu günleri `Task.detached` içinde hesaplanır,
    /// SwiftData insertionları ise main thread'e döndükten sonra yapılır.
    private func finish() {
        guard !periods.isEmpty, !isSaving else { return }
        isSaving = true

        // @State property'lerini Task'a geçmeden önce yerel değişkenlere kopyala
        let capturedPeriods = periods
        let capturedSemesterName = semesterName
        let capturedStart = startDate
        let capturedEnd = endDate
        let capturedWeekendRule = weekendRule

        Task { @MainActor in
            // Loading göstergesinin render edilmesi için bir runloop fırsatı ver
            await Task.yield()

            // 1. Semester oluştur
            let semester = Semester(
                name: capturedSemesterName,
                startDate: capturedStart,
                endDate: capturedEnd,
                weekendRule: capturedWeekendRule,
                isActive: true
            )
            modelContext.insert(semester)

            // 2. Ders saatlerini ekle
            for row in capturedPeriods {
                let def = PeriodDefinition(
                    id: row.id,
                    title: row.title,
                    startTime: row.startTime,
                    endTime: row.endTime,
                    orderIndex: row.orderIndex
                )
                modelContext.insert(def)
            }

            // 3. Tatil/hafta sonu günlerini arka planda hesapla (CPU-yoğun, Sendable)
            //    Task.detached → main thread'i bloklamaz, UI tepkili kalır
            let skippedDayData = await Task.detached(priority: .userInitiated) {
                MEBPresetProvider.computeSkippedDays(
                    start: capturedStart,
                    end: capturedEnd,
                    weekendRule: capturedWeekendRule
                )
            }.value

            // 4. Hesaplanan günleri main thread'de ekle (hızlı, bellekte)
            for dayData in skippedDayData {
                let skippedDay = SkippedDay(
                    date: dayData.date,
                    reason: dayData.reason,
                    type: dayData.type
                )
                skippedDay.semester = semester
                modelContext.insert(skippedDay)
            }

            // 5. WeekendRule'u .none yap (artık SkippedDay'ler üzerinden yönetilecek)
            semester.weekendRule = .none

            // 6. Hepsini kaydet
            let result = modelContext.saveResult("PeriodSetupView: finish failed")

            isSaving = false

            switch result {
            case .failure(let error):
                saveError = error
            case .success:
                // RootView'daki onboardingComplete = true tetiklenir
                onComplete()
            }
        }
    }

    // MARK: - Helpers

    private func timeRangeString(start: Date, end: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }

    // MARK: - Default Periods (MEB standart)

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
            PeriodRow(
                id: UUID(), title: "7. Ders", startTime: t(14, 40), endTime: t(15, 20),
                orderIndex: 7),
        ]
    }
}

// MARK: - EditPeriodSheetView

/// sheet(item:) ile sunulan bağımsız edit ekranı.
/// State tamamen kendi içinde — PeriodSetupView'a bağımlılık yok.
private struct EditPeriodSheetView: View {
    let initialTitle: String
    let initialStart: Date
    let initialEnd: Date
    let onSave: (String, Date, Date) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var startTime: Date
    @State private var endTime: Date

    init(
        initialTitle: String,
        initialStart: Date,
        initialEnd: Date,
        onSave: @escaping (String, Date, Date) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialTitle = initialTitle
        self.initialStart = initialStart
        self.initialEnd = initialEnd
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: initialTitle)
        _startTime = State(initialValue: initialStart)
        _endTime = State(initialValue: initialEnd)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && endTime > startTime
    }

    private var durationMinutes: Int {
        max(0, Calendar.current.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ders Adı") {
                    TextField("Örn: 1. Ders", text: $title)
                        .autocorrectionDisabled()
                }

                Section("Saatler") {
                    DatePicker(
                        "Başlangıç",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "Bitiş",
                        selection: $endTime,
                        displayedComponents: .hourAndMinute
                    )

                    if endTime <= startTime {
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
                        Text("Süre: \(durationMinutes) dakika")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(title.isEmpty ? "Ders Saati" : title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        onSave(
                            title.trimmingCharacters(in: .whitespaces),
                            startTime,
                            endTime
                        )
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PeriodSetupView(
            semesterName: "2025-2026 Bahar Dönemi",
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 9))!,
            endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 19))!,
            weekendRule: .saturdaySunday,
            onComplete: {}
        )
    }
    .modelContainer(try! ModelContainerFactory.createPreview())
}
