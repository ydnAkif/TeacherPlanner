//
//  OnboardingView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var schoolName: String = ""
    @State private var academicYear: String = "2025-2026"
    @State private var semesterType: SemesterType = .guz
    @State private var showingPeriodSetup = false

    enum SemesterType: String, CaseIterable {
        case guz = "Güz Dönemi"
        case bahar = "Bahar Dönemi"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Okul Bilgileri") {
                    TextField("Okul Adı", text: $schoolName)
                }

                Section("Dönem Bilgileri") {
                    TextField("Akademik Yıl", text: $academicYear)

                    Picker("Dönem Tipi", selection: $semesterType) {
                        ForEach(SemesterType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                Section("Özet") {
                    HStack {
                        Text("Dönem Adı")
                        Spacer()
                        Text(generatedSemesterName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Hoş Geldiniz")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Devam") {
                        createSemester()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingPeriodSetup) {
                PeriodSetupView()
            }
        }
    }

    private var isFormValid: Bool {
        !schoolName.isEmpty && !academicYear.isEmpty
    }

    private var generatedSemesterName: String {
        "\(academicYear) \(semesterType.rawValue)"
    }

    private func createSemester() {
        let calendar = Calendar.current
        let year = Int(academicYear.prefix(4)) ?? 2025

        let startDate: Date
        let endDate: Date

        if semesterType == .guz {
            startDate = calendar.date(from: DateComponents(year: year, month: 9, day: 8)) ?? Date()
            endDate =
                calendar.date(from: DateComponents(year: year + 1, month: 1, day: 23)) ?? Date()
        } else {
            startDate =
                calendar.date(from: DateComponents(year: year + 1, month: 2, day: 9)) ?? Date()
            endDate =
                calendar.date(from: DateComponents(year: year + 1, month: 6, day: 19)) ?? Date()
        }

        let semester = Semester(
            name: generatedSemesterName,
            startDate: startDate,
            endDate: endDate,
            weekendRule: .saturdaySunday,
            isActive: true
        )

        modelContext.insert(semester)
        MEBPresetProvider.applyMEBPreset(to: semester, in: modelContext)

        do {
            try modelContext.save()
            showingPeriodSetup = true
        } catch {
            print("Error saving semester: \(error)")
        }
    }
}

#Preview {
    OnboardingView()
}
