//
//  EditPlannerItemView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

/// Planner item ekleme/düzenleme ekranı
struct EditPlannerItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var type: PlannerItemType = .task
    @State private var priority: Priority = .medium
    @State private var dueDate: Date = Date()
    @State private var selectedCourse: Course?
    @State private var appError: AppError?

    @Query(sort: \Course.title) private var courses: [Course]

    let itemToEdit: PlannerItem?

    init(item: PlannerItem? = nil, type: PlannerItemType = .task) {
        self.itemToEdit = item
        self._type = State(initialValue: type)

        if let item {
            _title = State(initialValue: item.title)
            _details = State(initialValue: item.details ?? "")
            _type = State(initialValue: item.type)
            _priority = State(initialValue: item.priority)
            _dueDate = State(initialValue: item.dueDate ?? Date())
            _selectedCourse = State(initialValue: item.course)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detaylar") {
                    TextField("Başlık", text: $title)

                    TextEditor(text: $details)
                        .frame(minHeight: 80)

                    Picker("Tip", selection: $type) {
                        ForEach(PlannerItemType.allCases, id: \.self) { t in
                            Label(t.displayName, systemImage: t.systemImage).tag(t)
                        }
                    }

                    Picker("Öncelik", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                }

                Section("Zaman") {
                    DatePicker("Vade", selection: $dueDate, displayedComponents: .date)
                }

                Section("Ders (Opsiyonel)") {
                    Picker("Ders", selection: $selectedCourse) {
                        Text("Seçilmedi").tag(nil as Course?)
                        ForEach(courses) { course in
                            Text(course.title).tag(course as Course?)
                        }
                    }
                }
            }
            .navigationTitle(itemToEdit == nil ? "Yeni Görev" : "Düzenle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        save()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .errorAlert(error: $appError)
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedDetails = details.trimmingCharacters(in: .whitespaces)

        if let item = itemToEdit {
            item.title = trimmedTitle
            item.details = trimmedDetails.isEmpty ? nil : trimmedDetails
            item.type = type
            item.priority = priority
            item.dueDate = dueDate
            item.course = selectedCourse
        } else {
            let newItem = PlannerItem(
                title: trimmedTitle,
                details: trimmedDetails.isEmpty ? nil : trimmedDetails,
                type: type,
                dueDate: dueDate,
                priority: priority,
                course: selectedCourse
            )
            modelContext.insert(newItem)
        }

        modelContext
            .saveResult("EditPlannerItemView: save failed")
            .onFailure { appError = $0 }
    }
}

#Preview {
    EditPlannerItemView()
}
