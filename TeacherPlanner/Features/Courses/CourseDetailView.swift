//
//  CourseDetailView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct CourseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let course: Course

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingAddSession = false
    @State private var isLoading = true
    @State private var appError: AppError?

    var body: some View {
        ScrollView {
            if isLoading {
                loadingView
            } else {
                LazyVStack(spacing: 16) {
                    CourseHeaderCard(course: course)
                        .padding(.horizontal)

                    if let notes = course.notes, !notes.isEmpty {
                        notesSection(notes: notes)
                    }

                    scheduleSection

                    plannerItemsSection
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Ders Detay")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Dersler") { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Düzenle", systemImage: "pencil")
                    }
                    Button(action: { showingAddSession = true }) {
                        Label("Ders Ata", systemImage: "calendar.badge.plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCourseView(course: course)
        }
        .sheet(isPresented: $showingAddSession) {
            EditClassSessionView(course: course)
        }
        .alert("Dersi Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) { deleteCourse() }
        } message: {
            Text("'\(course.title)' dersini silmek istediğinize emin misiniz?")
        }
        .errorAlert(error: $appError)
        .task {
            isLoading = false
        }
    }

    private var loadingView: some View {
        LazyVStack(spacing: 16) {
            SkeletonRect(height: 150, cornerRadius: AppSpacing.cornerRadiusLarge)
                .padding(.horizontal)

            SkeletonRect(height: 100, cornerRadius: AppSpacing.cornerRadiusMedium)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonText(width: 150, height: 20)
                    .padding(.horizontal)
                SkeletonRect(height: 200, cornerRadius: AppSpacing.cornerRadiusMedium)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }

    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notlar")
                .font(.headline)
                .padding(.horizontal)

            Text(notes)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
                .padding(.horizontal)
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Haftalık Program")
                    .font(.headline)
                    .padding(.horizontal)

                Spacer()

                if !course.sessions.isEmpty {
                    Text("\(course.sessions.count) ders")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(.trailing, 16)
                }
            }

            if course.sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("Bu derse ait programlanmış ders yok")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Button(action: { showingAddSession = true }) {
                        Label("Ders Ata", systemImage: "plus.circle.fill")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(course.sessions.sorted { $0.weekday < $1.weekday }), id: \.id) {
                        session in
                        CourseSessionRow(session: session)
                            .padding(.horizontal)

                        if session.id != course.sessions.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
                .padding(.horizontal)
            }
        }
    }

    private var plannerItemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İlgili Görevler")
                .font(.headline)
                .padding(.horizontal)

            if course.plannerItems.isEmpty {
                Text("Bu derse ait görev yok")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(course.plannerItems.sorted { $0.createdAt > $1.createdAt }) { item in
                        PlannerItemRow(item: item, onToggle: {})
                            .padding(.horizontal)

                        if item.id != course.plannerItems.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
                .padding(.horizontal)
            }
        }
    }

    private func deleteCourse() {
        modelContext.delete(course)
        modelContext
            .saveResult("CourseDetailView: course delete failed")
            .onFailure { appError = $0 }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CourseDetailView(
            course: Course(
                title: "5-C Fen Bilimleri",
                colorHex: "#FF9500",
                symbolName: "flask.fill",
                notes: "Deney günleri: Çarşamba"
            )
        )
    }
}
