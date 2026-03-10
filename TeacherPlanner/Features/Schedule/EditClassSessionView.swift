//
//  EditClassSessionView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct EditClassSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let sessionToEdit: ClassSession?
    let weekday: Int
    let period: PeriodDefinition?

    @State private var selectedCourse: Course?
    @State private var room: String = ""
    @State private var notes: String = ""
    @State private var showingSuccessMessage = false
    @State private var conflictError: String?

    @Query(sort: \Course.title) private var courses: [Course]

    init(session: ClassSession? = nil, weekday: Int, period: PeriodDefinition? = nil) {
        self.sessionToEdit = session
        self.weekday = weekday
        self.period = period

        if let session = session {
            _selectedCourse = State(initialValue: session.course)
            _room = State(initialValue: session.room ?? "")
            _notes = State(initialValue: session.notes ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ders") {
                    Picker("Ders Seç", selection: $selectedCourse) {
                        Text("Seçilmedi").tag(nil as Course?)
                        ForEach(courses) { course in
                            Text(course.title).tag(course as Course?)
                        }
                    }
                }

                Section("Detaylar") {
                    TextField("Oda No (Opsiyonel)", text: $room)
                    TextField("Notlar (Opsiyonel)", text: $notes, axis: .vertical)
                }

                Section("Özet") {
                    HStack {
                        Text("Gün")
                        Spacer()
                        Text(weekdayName)
                            .foregroundStyle(.secondary)
                    }

                    if let period = period {
                        HStack {
                            Text("Ders Saati")
                            Spacer()
                            Text(
                                "\(period.title) (\(period.startTimeString)-\(period.endTimeString))"
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(sessionToEdit == nil ? "Ders Ata" : "Dersi Düzenle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .disabled(selectedCourse == nil)
                }
            }
            .alert("Ders Kaydedildi", isPresented: $showingSuccessMessage) {
                Button("Tamam") { dismiss() }
            }
            .alert("Çakışma", isPresented: .constant(conflictError != nil)) {
                Button("Tamam") {
                    conflictError = nil
                }
            } message: {
                Text(conflictError ?? "")
            }
        }
    }

    private var weekdayName: String {
        Weekday.fromCalendarWeekday(weekday)?.displayName ?? "Bilinmiyor"
    }

    private func save() {
        // Çakışma kontrolü - basitleştirilmiş
        if let period = period, selectedCourse != nil {
            let descriptor = FetchDescriptor<ClassSession>()

            if let allSessions = try? modelContext.fetch(descriptor) {
                for existingSession in allSessions {
                    if existingSession.weekday == weekday
                        && existingSession.periodOrder == period.orderIndex
                        && existingSession.id != sessionToEdit?.id
                    {
                        conflictError =
                            "Bu saatte zaten \(existingSession.course?.title ?? "bir ders") dersi var"
                        return
                    }
                }
            }
        }

        if let session = sessionToEdit {
            session.course = selectedCourse
            session.room = room.isEmpty ? nil : room
            session.notes = notes.isEmpty ? nil : notes
        } else if let period = period {
            let newSession = ClassSession(
                weekday: weekday,
                periodOrder: period.orderIndex,
                course: selectedCourse,
                period: period,
                room: room.isEmpty ? nil : room,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(newSession)
        }
        try? modelContext.save()
        showingSuccessMessage = true
    }
}

#Preview {
    EditClassSessionView(weekday: 2, period: nil)
}
