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
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var selectedCourse: Course?
    @State private var appError: AppError?

    /// Ön doldurulmuş due date (örn: QuickAddBar'dan "bugün" olarak gelindiğinde)
    private let prefillDueDate: Date?

    @Query(sort: \Course.title) private var courses: [Course]

    let itemToEdit: PlannerItem?

    init(item: PlannerItem? = nil, type: PlannerItemType = .task, prefillDueDate: Date? = nil) {
        self.itemToEdit = item
        self.prefillDueDate = prefillDueDate
        self._type = State(initialValue: type)

        if let item {
            _title = State(initialValue: item.title)
            _details = State(initialValue: item.details ?? "")
            _type = State(initialValue: item.type)
            _priority = State(initialValue: item.priority)
            _hasDueDate = State(initialValue: item.dueDate != nil)
            _dueDate = State(initialValue: item.dueDate ?? Date())
            _selectedCourse = State(initialValue: item.course)
        } else if let prefill = prefillDueDate {
            _hasDueDate = State(initialValue: true)
            _dueDate = State(initialValue: prefill)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Detaylar
                Section("Detaylar") {
                    TextField("Başlık", text: $title)

                    ZStack(alignment: .topLeading) {
                        if details.isEmpty {
                            Text("Açıklama (opsiyonel)")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $details)
                            .frame(minHeight: 80)
                    }

                    Picker("Tip", selection: $type) {
                        ForEach(PlannerItemType.allCases, id: \.self) { t in
                            Label(t.displayName, systemImage: t.systemImage).tag(t)
                        }
                    }

                    Picker("Öncelik", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            HStack {
                                priorityIndicator(for: p)
                                Text(p.displayName)
                            }
                            .tag(p)
                        }
                    }
                }

                // MARK: - Zaman
                Section {
                    Toggle(isOn: $hasDueDate.animation()) {
                        Label("Vade Tarihi", systemImage: "calendar")
                    }

                    if hasDueDate {
                        DatePicker(
                            "Tarih",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                } header: {
                    Text("Zaman")
                } footer: {
                    if !hasDueDate {
                        Text("Tarih belirlenmezse görev tarihsiz olarak kaydedilir.")
                            .font(.caption)
                    }
                }

                // MARK: - Ders
                Section("Ders (Opsiyonel)") {
                    Picker("Ders", selection: $selectedCourse) {
                        Label("Seçilmedi", systemImage: "xmark.circle")
                            .tag(nil as Course?)
                        ForEach(courses) { course in
                            Label(course.title, systemImage: course.symbolName)
                                .tag(course as Course?)
                        }
                    }
                }
            }
            .navigationTitle(itemToEdit == nil ? "Yeni Görev" : "Düzenle")
            .navigationBarTitleDisplayMode(.inline)
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
                    .fontWeight(.semibold)
                }
            }
            .errorAlert(error: $appError)
        }
    }

    // MARK: - Priority indicator

    @ViewBuilder
    private func priorityIndicator(for p: Priority) -> some View {
        switch p {
        case .high:
            Image(systemName: "exclamationmark.3")
                .foregroundStyle(.red)
        case .medium:
            Image(systemName: "exclamationmark.2")
                .foregroundStyle(.orange)
        case .low:
            Image(systemName: "exclamationmark")
                .foregroundStyle(.blue)
        }
    }

    // MARK: - Save

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedDetails = details.trimmingCharacters(in: .whitespaces)
        let resolvedDate: Date? = hasDueDate ? dueDate : nil

        if let item = itemToEdit {
            item.title = trimmedTitle
            item.details = trimmedDetails.isEmpty ? nil : trimmedDetails
            item.type = type
            item.priority = priority
            item.dueDate = resolvedDate
            item.course = selectedCourse
        } else {
            let newItem = PlannerItem(
                title: trimmedTitle,
                details: trimmedDetails.isEmpty ? nil : trimmedDetails,
                type: type,
                dueDate: resolvedDate,
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

// MARK: - Preview

#Preview("Yeni görev") {
    EditPlannerItemView()
        .modelContainer(try! ModelContainerFactory.createPreview())
}

#Preview("Düzenle") {
    let item = PlannerItem(
        title: "Sınav soruları hazırla",
        details: "6. sınıf matematik ara sınav",
        type: .exam,
        dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
        priority: .high
    )
    return EditPlannerItemView(item: item)
        .modelContainer(try! ModelContainerFactory.createPreview())
}

#Preview("Not ekle") {
    EditPlannerItemView(type: .note)
        .modelContainer(try! ModelContainerFactory.createPreview())
}
