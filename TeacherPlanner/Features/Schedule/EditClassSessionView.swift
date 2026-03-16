//
//  EditClassSessionView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

struct EditClassSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let sessionToEdit: ClassSession?
    let weekday: Int
    let preselectedPeriod: PeriodDefinition?
    let preselectedCourse: Course?

    @State private var selectedCourse: Course?
    @State private var selectedPeriod: PeriodDefinition?
    @State private var selectedWeekday: Int
    @State private var room: String = ""
    @State private var notes: String = ""
    @State private var conflictError: String?
    @State private var appError: AppError?

    @Query(sort: \Course.title) private var courses: [Course]
    @Query(sort: \PeriodDefinition.orderIndex) private var periods: [PeriodDefinition]

    // Genel amaçlı init — haftalık programdan hücreye tıklandığında
    init(session: ClassSession? = nil, weekday: Int, period: PeriodDefinition? = nil) {
        self.sessionToEdit = session
        self.weekday = weekday
        self.preselectedPeriod = period
        self.preselectedCourse = nil
        _selectedWeekday = State(initialValue: weekday)

        if let session = session {
            _selectedCourse = State(initialValue: session.course)
            _selectedPeriod = State(initialValue: session.period)
            _selectedWeekday = State(initialValue: session.weekday)
            _room = State(initialValue: session.room ?? "")
            _notes = State(initialValue: session.notes ?? "")
        } else if let period = period {
            _selectedPeriod = State(initialValue: period)
        }
    }

    // Dersten açıldığında — course önceden biliniyor
    init(course: Course, weekday: Int = 2) {
        self.sessionToEdit = nil
        self.weekday = weekday
        self.preselectedPeriod = nil
        self.preselectedCourse = course
        _selectedWeekday = State(initialValue: weekday)
        _selectedCourse = State(initialValue: course)
        _selectedPeriod = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Ders seçimi (course önceden seçiliyse göster, değiştirilemez)
                Section("Ders") {
                    if preselectedCourse != nil {
                        // Ders detayından açıldı — dersi göster, değiştirme
                        HStack {
                            if let color = Color(hex: selectedCourse?.colorHex ?? "") {
                                Circle()
                                    .fill(color)
                                    .frame(width: 12, height: 12)
                            }
                            Text(selectedCourse?.title ?? "—")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: selectedCourse?.symbolName ?? "book")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    } else {
                        Picker("Ders Seç", selection: $selectedCourse) {
                            Text("Seçilmedi").tag(nil as Course?)
                            ForEach(courses) { course in
                                Label(course.title, systemImage: course.symbolName)
                                    .tag(course as Course?)
                            }
                        }
                    }
                }

                // MARK: - Gün seçimi
                Section("Gün") {
                    Picker("Gün", selection: $selectedWeekday) {
                        ForEach(Weekday.allCases, id: \.rawValue) { day in
                            Text(day.displayName).tag(day.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // MARK: - Ders saati seçimi
                Section("Ders Saati") {
                    if periods.isEmpty {
                        Label(
                            "Henüz ders saati tanımlanmamış. Ayarlar > Ders Saatleri bölümünden ekleyin.",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.caption)
                        .foregroundStyle(.orange)
                    } else {
                        Picker("Ders Saati Seç", selection: $selectedPeriod) {
                            Text("Seçilmedi").tag(nil as PeriodDefinition?)
                            ForEach(periods) { period in
                                Text(
                                    "\(period.title)  \(period.startTimeString)–\(period.endTimeString)"
                                )
                                .tag(period as PeriodDefinition?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                // MARK: - Ek bilgiler
                Section("Detaylar (Opsiyonel)") {
                    TextField("Oda No", text: $room)
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                // MARK: - Çakışma uyarısı
                if let conflict = conflictError {
                    Section {
                        Label(conflict, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(sessionToEdit == nil ? "Ders Ata" : "Dersi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .errorAlert(error: $appError)
            .onAppear {
                // preselectedPeriod varsa uygula (init'te state set edilebiliyor
                // ama @Query ile gelen periods listesi onAppear'da hazır olur)
                if selectedPeriod == nil, let pre = preselectedPeriod {
                    selectedPeriod = pre
                }
            }
        }
    }

    // MARK: - Validation

    private var isValid: Bool {
        selectedCourse != nil && selectedPeriod != nil
    }

    // MARK: - Save

    private func save() {
        guard let course = selectedCourse, let period = selectedPeriod else { return }

        conflictError = nil

        // Çakışma kontrolü
        let descriptor = FetchDescriptor<ClassSession>()
        let allSessions = modelContext.fetchResult(
            descriptor,
            failureMessage: "EditClassSessionView: conflict fetch failed"
        ).get(or: [])

        for existing in allSessions {
            guard existing.id != sessionToEdit?.id else { continue }
            if existing.weekday == selectedWeekday
                && existing.periodOrder == period.orderIndex
            {
                conflictError =
                    "\(Weekday.fromCalendarWeekday(selectedWeekday)?.displayName ?? "Bu gün") \(period.title) saatinde zaten \(existing.course?.title ?? "bir ders") var"
                return
            }
        }

        if let session = sessionToEdit {
            // Düzenleme
            session.course = course
            session.period = period
            session.weekday = selectedWeekday
            session.periodOrder = period.orderIndex
            session.room = room.isEmpty ? nil : room
            session.notes = notes.isEmpty ? nil : notes
        } else {
            // Yeni kayıt
            let newSession = ClassSession(
                weekday: selectedWeekday,
                periodOrder: period.orderIndex,
                course: course,
                period: period,
                room: room.isEmpty ? nil : room,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(newSession)
        }

        modelContext
            .saveResult("EditClassSessionView: save failed")
            .onFailure { appError = $0 }

        dismiss()
    }
}

// MARK: - Preview

#Preview("Haftalık Programdan") {
    EditClassSessionView(weekday: 2, period: nil)
        .modelContainer(try! ModelContainerFactory.createPreview())
}

#Preview("Ders Detayından") {
    let course = Course(title: "5-C Fen Bilimleri", colorHex: "#FF9500", symbolName: "flask.fill")
    return EditClassSessionView(course: course)
        .modelContainer(try! ModelContainerFactory.createPreview())
}
