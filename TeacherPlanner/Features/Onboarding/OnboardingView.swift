//
//  OnboardingView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var schoolName: String = ""
    @State private var academicYear: String = Self.currentAcademicYear()
    @State private var semesterType: SemesterType = .guz
    @State private var startDate: Date = Self.defaultStartDate(for: .guz)
    @State private var endDate: Date = Self.defaultEndDate(for: .guz)

    enum SemesterType: String, CaseIterable {
        case guz = "Güz Dönemi"
        case bahar = "Bahar Dönemi"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppColors.primary.opacity(0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        headerSection
                        formSection
                        nextButton
                    }
                    .padding(.horizontal)
                    .padding(.bottom, AppSpacing.large)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(spacing: AppSpacing.xxSmall) {
                Text("Hoş Geldiniz")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Birkaç adımda kurulumu tamamlayın")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Adım göstergesi
            stepIndicator(current: 1, total: 2)
        }
        .padding(.top, AppSpacing.medium)
    }

    // MARK: - Step Indicator

    private func stepIndicator(current: Int, total: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step == current ? AppColors.primary : AppColors.primary.opacity(0.2))
                    .frame(width: step == current ? 24 : 12, height: 6)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: AppSpacing.medium) {
            onboardingCard(title: "Okul Bilgileri", icon: "building.2") {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    fieldLabel("Okul Adı")
                    styledTextField("Örn: Atatürk Ortaokulu", text: $schoolName)
                }
            }

            onboardingCard(title: "Dönem Bilgileri", icon: "calendar") {
                VStack(spacing: AppSpacing.medium) {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        fieldLabel("Akademik Yıl")
                        styledTextField("2025-2026", text: $academicYear)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        fieldLabel("Dönem Tipi")
                        Picker("Dönem Tipi", selection: $semesterType) {
                            ForEach(SemesterType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: semesterType) { _, newType in
                            startDate = Self.defaultStartDate(for: newType)
                            endDate = Self.defaultEndDate(for: newType)
                        }
                    }
                }
            }

            onboardingCard(title: "Dönem Tarihleri", icon: "calendar.badge.clock") {
                VStack(spacing: AppSpacing.small) {
                    HStack {
                        Image(systemName: "play.circle")
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 20)
                        DatePicker(
                            "Başlangıç",
                            selection: $startDate,
                            in: Date.distantPast...endDate,
                            displayedComponents: .date
                        )
                    }

                    Divider()

                    HStack {
                        Image(systemName: "stop.circle")
                            .foregroundStyle(.red.opacity(0.8))
                            .frame(width: 20)
                        DatePicker(
                            "Bitiş",
                            selection: $endDate,
                            in: startDate...Date.distantFuture,
                            displayedComponents: .date
                        )
                    }

                    if endDate <= startDate {
                        Label(
                            "Bitiş tarihi başlangıçtan sonra olmalı",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }
                }
            }

            summaryCard
        }
        .frame(maxWidth: 450)
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
            Label("Özet", systemImage: "info.circle")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primary)

            VStack(spacing: 6) {
                summaryRow(label: "Dönem:", value: generatedSemesterName)
                summaryRow(
                    label: "Başlangıç:",
                    value: startDate.formatted(date: .abbreviated, time: .omitted))
                summaryRow(
                    label: "Bitiş:",
                    value: endDate.formatted(date: .abbreviated, time: .omitted))
                summaryRow(label: "Süre:", value: durationText)
            }
            .padding(10)
            .background(AppColors.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
        }
        .padding(.horizontal)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.footnote.bold())
                .foregroundStyle(AppColors.primary)
        }
    }

    // MARK: - Next Button

    private var nextButton: some View {
        NavigationLink {
            PeriodSetupView(
                semesterName: generatedSemesterName,
                startDate: startDate,
                endDate: endDate,
                onComplete: saveSemester
            )
        } label: {
            HStack {
                Text("Devam Et")
                    .fontWeight(.bold)
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? AppColors.primary : Color.gray.opacity(0.3))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
            .shadow(
                color: AppColors.primary.opacity(isFormValid ? 0.3 : 0),
                radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(!isFormValid)
        .frame(maxWidth: 450)
        .padding(.horizontal)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func onboardingCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: icon)
                    .foregroundStyle(AppColors.primary)
                Text(title)
                    .font(.headline)
            }
            content()
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusXLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusXLarge)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
    }

    private func styledTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .textFieldStyle(.plain)
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !schoolName.trimmingCharacters(in: .whitespaces).isEmpty
            && !academicYear.trimmingCharacters(in: .whitespaces).isEmpty
            && endDate > startDate
    }

    private var generatedSemesterName: String {
        "\(academicYear) \(semesterType.rawValue)"
    }

    private var durationText: String {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let weeks = days / 7
        return "\(weeks) hafta (\(days) gün)"
    }

    // MARK: - Default Dates

    private static func defaultStartDate(for type: SemesterType) -> Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        switch type {
        case .guz:
            return calendar.date(from: DateComponents(year: year, month: 9, day: 8)) ?? Date()
        case .bahar:
            return calendar.date(from: DateComponents(year: year + 1, month: 2, day: 9)) ?? Date()
        }
    }

    private static func defaultEndDate(for type: SemesterType) -> Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        switch type {
        case .guz:
            return calendar.date(from: DateComponents(year: year + 1, month: 1, day: 23)) ?? Date()
        case .bahar:
            return calendar.date(from: DateComponents(year: year + 1, month: 6, day: 19)) ?? Date()
        }
    }

    private static func currentAcademicYear() -> String {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let startYear = month >= 9 ? year : year - 1
        return "\(startYear)-\(startYear + 1)"
    }

    // MARK: - Save

    private func saveSemester(periods: [PeriodDefinition]) {
        let semester = Semester(
            name: generatedSemesterName,
            startDate: startDate,
            endDate: endDate,
            weekendRule: .saturdaySunday,
            isActive: true
        )
        MEBPresetProvider.applyMEBPreset(to: semester, in: modelContext)
        modelContext.insert(semester)
        for period in periods {
            modelContext.insert(period)
        }
        modelContext.saveResult("OnboardingView: saveSemester failed")
    }
}

#Preview {
    OnboardingView()
        .modelContainer(try! ModelContainerFactory.createPreview())
}
