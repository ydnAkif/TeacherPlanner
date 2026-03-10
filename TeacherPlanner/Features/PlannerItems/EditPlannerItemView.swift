//
//  EditPlannerItemView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
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
    @State private var priority: Int = 2
    @State private var dueDate: Date = Date()
    @State private var selectedCourse: Course?

    @Query(sort: \Course.title) private var courses: [Course]

    let itemToEdit: PlannerItem?

    init(item: PlannerItem? = nil, type: PlannerItemType = .task) {
        self.itemToEdit = item
        self._type = State(initialValue: type)

        if let item = item {
            _title = State(initialValue: item.title)
            _details = State(initialValue: item.details ?? "")
            _type = State(initialValue: item.type)
            _priority = State(initialValue: item.priority)
            _dueDate = State(initialValue: item.dueDate ?? Date())
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
                        ForEach(PlannerItemType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    Picker("Öncelik", selection: $priority) {
                        Text("Yüksek").tag(1)
                        Text("Orta").tag(2)
                        Text("Düşük").tag(3)
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
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        save()
                        dismiss()
                    }
                }
            }
        }
    }

    private func save() {
        if let item = itemToEdit {
            // Mevcut item'ı güncelle
            item.title = title
            item.details = details.isEmpty ? nil : details
            item.type = type
            item.priority = priority
            item.dueDate = dueDate
            item.course = selectedCourse
        } else {
            // Yeni item oluştur
            let newItem = PlannerItem(
                title: title,
                details: details.isEmpty ? nil : details,
                type: type,
                dueDate: dueDate,
                priority: priority,
                course: selectedCourse
            )
            modelContext.insert(newItem)
        }

        try? modelContext.save()
    }
}

#Preview {
    EditPlannerItemView()
}
