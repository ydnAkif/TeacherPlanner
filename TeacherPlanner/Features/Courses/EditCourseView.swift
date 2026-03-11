//
//  EditCourseView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

/// Ders ekleme/düzenleme ekranı
struct EditCourseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let courseToEdit: Course?

    @State private var title: String = ""
    @State private var colorHex: String = "#007AFF"
    @State private var symbolName: String = "book.fill"
    @State private var notes: String = ""

    @State private var showingColorPicker = false
    @State private var showingSymbolPicker = false
    @State private var appError: AppError?

    // Renk seçenekleri
    private let colorOptions: [(hex: String, name: String)] = [
        ("#FF3B30", "Kırmızı"),
        ("#FF9500", "Turuncu"),
        ("#FFCC00", "Sarı"),
        ("#34C759", "Yeşil"),
        ("#007AFF", "Mavi"),
        ("#5856D6", "Mor"),
        ("#AF52DE", "Menekşe"),
        ("#FF2D55", "Pembe"),
        ("#8E8E93", "Gri"),
    ]

    // İkon seçenekleri
    private let symbolOptions: [String] = [
        "book.fill", "book", "pencil.tip", "pencil",
        "flask.fill", "flask", "atom", "number.circle.fill",
        "character.book.closed.fill", "globe", "paintbrush.fill",
        "music.note", "sportscourt.fill", "tv.fill",
    ]

    init(course: Course? = nil) {
        self.courseToEdit = course

        if let course = course {
            _title = State(initialValue: course.title)
            _colorHex = State(initialValue: course.colorHex)
            _symbolName = State(initialValue: course.symbolName)
            _notes = State(initialValue: course.notes ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Genel") {
                    TextField("Ders Adı", text: $title)

                    TextField("Notlar (Opsiyonel)", text: $notes, axis: .vertical)
                }

                Section("Görünüm") {
                    Button(action: { showingColorPicker = true }) {
                        HStack {
                            Text("Renk")
                            Spacer()
                            Circle()
                                .fill(Color(hex: colorHex) ?? .blue)
                                .frame(width: 24, height: 24)
                        }
                    }

                    Button(action: { showingSymbolPicker = true }) {
                        HStack {
                            Text("İkon")
                            Spacer()
                            Image(systemName: symbolName)
                                .font(.title2)
                                .foregroundStyle(Color(hex: colorHex) ?? .blue)
                        }
                    }
                }

                Section("Önizleme") {
                    CoursePreviewCard(
                        title: title.isEmpty ? "Ders Adı" : title,
                        colorHex: colorHex,
                        symbolName: symbolName
                    )
                }
            }
            .navigationTitle(courseToEdit == nil ? "Yeni Ders" : "Düzenle")
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
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerSheet(
                    selectedColor: $colorHex,
                    colors: colorOptions
                )
            }
            .sheet(isPresented: $showingSymbolPicker) {
                SymbolPickerSheet(
                    selectedSymbol: $symbolName,
                    symbols: symbolOptions
                )
            }
            .errorAlert(error: $appError)
        }
    }

    private func save() {
        if let course = courseToEdit {
            course.title = title
            course.colorHex = colorHex
            course.symbolName = symbolName
            course.notes = notes.isEmpty ? nil : notes
        } else {
            let newCourse = Course(
                title: title,
                colorHex: colorHex,
                symbolName: symbolName,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(newCourse)
        }

        modelContext
            .saveResult("EditCourseView: save failed")
            .onSuccess { _ in
                Logger.info("Course saved successfully: \(title)")
                dismiss()
            }
            .onFailure { appError = $0 }
    }
}

/// Renk seçici sheet
struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: String
    let colors: [(hex: String, name: String)]

    var body: some View {
        NavigationStack {
            List {
                ForEach(colors, id: \.hex) { color in
                    Button(action: {
                        selectedColor = color.hex
                        dismiss()
                    }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: color.hex) ?? .gray)
                                .frame(width: 32, height: 32)

                            Text(color.name)

                            Spacer()

                            if selectedColor == color.hex {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Renk Seç")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// İkon seçici sheet
struct SymbolPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSymbol: String
    let symbols: [String]

    var body: some View {
        NavigationStack {
            List {
                ForEach(symbols, id: \.self) { symbol in
                    Button(action: {
                        selectedSymbol = symbol
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: symbol)
                                .font(.title2)
                                .frame(width: 32)

                            Text(symbol)

                            Spacer()

                            if selectedSymbol == symbol {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("İkon Seç")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Önizleme kartı
struct CoursePreviewCard: View {
    let title: String
    let colorHex: String
    let symbolName: String

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: colorHex) ?? .blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: symbolName)
                        .foregroundStyle(.white)
                )

            Text(title)
                .font(.body)

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    EditCourseView()
}
