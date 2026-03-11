//
//  EditSemesterView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct EditSemesterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let semesterToEdit: Semester?

    @State private var name: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var weekendRule: WeekendRule = .saturdaySunday
    @State private var applyMEBPreset: Bool = true
    @State private var showingSuccessMessage = false
    @State private var appError: AppError?

    init(semester: Semester? = nil) {
        self.semesterToEdit = semester

        if let semester = semester {
            _name = State(initialValue: semester.name)
            _startDate = State(initialValue: semester.startDate)
            _endDate = State(initialValue: semester.endDate)
            _weekendRule = State(initialValue: semester.weekendRule)
        } else {
            let calendar = Calendar.current
            _startDate = State(
                initialValue: calendar.date(from: DateComponents(year: 2025, month: 9, day: 8))
                    ?? Date())
            _endDate = State(
                initialValue: calendar.date(from: DateComponents(year: 2026, month: 1, day: 23))
                    ?? Date())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Genel") {
                    TextField("Dönem Adı", text: $name)
                        
                }

                Section("Tarihler") {
                    DatePicker("Başlangıç", selection: $startDate, displayedComponents: .date)
                    DatePicker("Bitiş", selection: $endDate, displayedComponents: .date)

                    if startDate >= endDate {
                        Label(
                            "Bitiş tarihi başlangıçtan sonra olmalıdır",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.caption)
                        .foregroundStyle(.red)
                    }
                }

                Section("Hafta Sonu") {
                    Picker("Hafta Sonu Kuralı", selection: $weekendRule) {
                        Text("Cumartesi-Pazar").tag(WeekendRule.saturdaySunday)
                        Text("Sadece Pazar").tag(WeekendRule.sundayOnly)
                        Text("Yok").tag(WeekendRule.none)
                    }
                }

                if semesterToEdit == nil {
                    Section("Otomatik Ekleme") {
                        Toggle("MEB Tatil Günlerini Ekle", isOn: $applyMEBPreset)

                        if applyMEBPreset {
                            Label(
                                "Resmi tatiller ve ara tatiller otomatik eklenecek",
                                systemImage: "info.circle"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Özet") {
                    HStack {
                        Text("Toplam Gün")
                        Spacer()
                        Text("\(totalDays) gün")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Hafta")
                        Spacer()
                        Text("\(totalWeeks) hafta")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(semesterToEdit == nil ? "Yeni Dönem" : "Düzenle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        save()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Dönem Kaydedildi", isPresented: $showingSuccessMessage) {
                Button("Tamam") {
                    dismiss()
                }
            } message: {
                Text("'\(name)' dönemi başarıyla kaydedildi.")
            }
            .errorAlert(error: $appError)
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty && startDate < endDate
    }

    private var totalDays: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    private var totalWeeks: Int {
        return totalDays / 7
    }

    private func save() {
        if let semester = semesterToEdit {
            semester.name = name
            semester.startDate = startDate
            semester.endDate = endDate
            semester.weekendRule = weekendRule
        } else {
            // Mevcut aktif semester'ı bul ve pasif yap
            let activeDescriptor = FetchDescriptor<Semester>(
                predicate: #Predicate { $0.isActive }
            )
            let fetchResult = modelContext.fetchResult(
                activeDescriptor,
                failureMessage: "EditSemesterView: active semester fetch failed"
            )
            if case .failure(let error) = fetchResult {
                appError = error
            }
            for activeSemester in fetchResult.get(or: []) {
                activeSemester.isActive = false
            }

            let newSemester = Semester(
                name: name,
                startDate: startDate,
                endDate: endDate,
                weekendRule: weekendRule,
                isActive: true
            )
            modelContext.insert(newSemester)

            // MEB preset uygula
            if applyMEBPreset {
                MEBPresetProvider.applyMEBPreset(to: newSemester, in: modelContext)
            }
        }

        modelContext
            .saveResult("EditSemesterView: save failed")
            .onFailure { appError = $0 }
        showingSuccessMessage = true
    }
}


#Preview {
    EditSemesterView()
}
