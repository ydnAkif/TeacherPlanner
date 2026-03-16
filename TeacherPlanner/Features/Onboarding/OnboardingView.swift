//
//  OnboardingView.swift
//  TeacherPlanner
//

import SwiftData
import SwiftUI

// MARK: - Ana Onboarding koordinatörü

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    /// RootView'dan gelen tamamlama callback'i
    let onComplete: () -> Void

    // Adım 1 state
    @State private var schoolName: String = ""
    @State private var academicYear: String = Self.currentAcademicYear()
    @State private var semesterType: SemesterType = .guz

    // Adım 2 state
    @State private var startDate: Date = Self.defaultStartDate(for: .guz)
    @State private var endDate: Date = Self.defaultEndDate(for: .guz)

    enum SemesterType: String, CaseIterable {
        case guz = "Güz Dönemi"
        case bahar = "Bahar Dönemi"
    }

    var body: some View {
        NavigationStack {
            OnboardingStep1View(
                schoolName: $schoolName,
                academicYear: $academicYear,
                semesterType: $semesterType,
                startDate: $startDate,
                endDate: $endDate,
                onSave: onComplete
            )
        }
    }

    // MARK: - Static helpers

    static func defaultStartDate(for type: SemesterType) -> Date {
        let cal = Calendar.current
        let year = cal.component(.year, from: Date())
        switch type {
        case .guz:
            return cal.date(from: DateComponents(year: year, month: 9, day: 8)) ?? Date()
        case .bahar:
            return cal.date(from: DateComponents(year: year + 1, month: 2, day: 9)) ?? Date()
        }
    }

    static func defaultEndDate(for type: SemesterType) -> Date {
        let cal = Calendar.current
        let year = cal.component(.year, from: Date())
        switch type {
        case .guz:
            return cal.date(from: DateComponents(year: year + 1, month: 1, day: 23)) ?? Date()
        case .bahar:
            return cal.date(from: DateComponents(year: year + 1, month: 6, day: 19)) ?? Date()
        }
    }

    static func currentAcademicYear() -> String {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let start = month >= 9 ? year : year - 1
        return "\(start)-\(start + 1)"
    }
}

// MARK: - Adım 1: Okul & Dönem bilgileri

struct OnboardingStep1View: View {
    @Binding var schoolName: String
    @Binding var academicYear: String
    @Binding var semesterType: OnboardingView.SemesterType
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onSave: () -> Void

    private var isValid: Bool {
        !schoolName.trimmingCharacters(in: .whitespaces).isEmpty
            && !academicYear.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            background
            ScrollView {
                VStack(spacing: 24) {
                    header

                    card(title: "Okul Bilgileri", icon: "building.2") {
                        VStack(alignment: .leading, spacing: 8) {
                            label("Okul Adı")
                            field("Örn: Atatürk Ortaokulu", text: $schoolName)
                        }
                    }

                    card(title: "Dönem Bilgileri", icon: "calendar") {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                label("Akademik Yıl")
                                field("2025-2026", text: $academicYear)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                label("Dönem Tipi")
                                Picker("Dönem Tipi", selection: $semesterType) {
                                    ForEach(OnboardingView.SemesterType.allCases, id: \.self) {
                                        Text($0.rawValue).tag($0)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: semesterType) { _, newType in
                                    startDate = OnboardingView.defaultStartDate(for: newType)
                                    endDate = OnboardingView.defaultEndDate(for: newType)
                                }
                            }
                        }
                    }

                    NavigationLink {
                        OnboardingStep2View(
                            semesterType: semesterType,
                            academicYear: academicYear,
                            startDate: $startDate,
                            endDate: $endDate,
                            onSave: onSave
                        )
                    } label: {
                        nextButtonLabel(title: "Devam Et", enabled: isValid)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isValid)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sub-views

    private var background: some View {
        LinearGradient(
            colors: [AppColors.primary.opacity(0.05), .clear],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(AppColors.primary)
            }
            Text("Hoş Geldiniz")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("Önce okul ve dönem bilgilerini girin")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            stepDots(current: 1)
        }
        .padding(.top, 16)
    }
}

// MARK: - Adım 2: Tarih seçimi + Özet

struct OnboardingStep2View: View {
    let semesterType: OnboardingView.SemesterType
    let academicYear: String
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onSave: () -> Void

    private var semesterName: String { "\(academicYear) \(semesterType.rawValue)" }

    private var durationText: String {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return "\(days / 7) hafta (\(days) gün)"
    }

    private var isValid: Bool { endDate > startDate }

    var body: some View {
        ZStack {
            background
            ScrollView {
                VStack(spacing: 24) {
                    header

                    card(title: "Dönem Tarihleri", icon: "calendar.badge.clock") {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "play.circle")
                                    .foregroundStyle(AppColors.primary)
                                    .frame(width: 20)
                                DatePicker(
                                    "Başlangıç", selection: $startDate,
                                    in: Date.distantPast...endDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                            }
                            Divider()
                            HStack {
                                Image(systemName: "stop.circle")
                                    .foregroundStyle(.red.opacity(0.8))
                                    .frame(width: 20)
                                DatePicker(
                                    "Bitiş", selection: $endDate,
                                    in: startDate...Date.distantFuture,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                            }
                            if !isValid {
                                Label(
                                    "Bitiş tarihi başlangıçtan sonra olmalı",
                                    systemImage: "exclamationmark.triangle"
                                )
                                .font(.caption)
                                .foregroundStyle(.orange)
                            }
                        }
                    }

                    // Özet kartı
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Özet", systemImage: "info.circle")
                            .font(.caption.bold())
                            .foregroundStyle(AppColors.primary)
                        VStack(spacing: 6) {
                            summaryRow("Dönem:", semesterName)
                            summaryRow(
                                "Başlangıç:",
                                startDate.formatted(date: .abbreviated, time: .omitted))
                            summaryRow(
                                "Bitiş:", endDate.formatted(date: .abbreviated, time: .omitted))
                            summaryRow("Süre:", durationText)
                        }
                        .padding(10)
                        .background(AppColors.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)

                    NavigationLink {
                        PeriodSetupView(
                            semesterName: semesterName,
                            startDate: startDate,
                            endDate: endDate,
                            weekendRule: .saturdaySunday,
                            onComplete: onSave
                        )
                    } label: {
                        nextButtonLabel(title: "Ders Saatlerine Geç", enabled: isValid)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isValid)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var background: some View {
        LinearGradient(
            colors: [AppColors.primary.opacity(0.05), .clear],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.primary)
            }
            Text("Dönem Tarihleri")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("Dönemin başlangıç ve bitiş tarihlerini ayarlayın")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            stepDots(current: 2)
        }
        .padding(.top, 16)
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.footnote).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.footnote.bold()).foregroundStyle(AppColors.primary)
        }
    }
}

// MARK: - Paylaşılan yardımcılar (free functions, her iki view kullanır)

private func card<Content: View>(
    title: String,
    icon: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: 14) {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(AppColors.primary)
            Text(title).font(.headline)
        }
        content()
    }
    .padding()
    .background(Color.white.opacity(0.6))
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 18))
    .overlay(
        RoundedRectangle(cornerRadius: 18)
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
    )
    .padding(.horizontal)
}

private func label(_ text: String) -> some View {
    Text(text)
        .font(.caption.weight(.medium))
        .foregroundStyle(.secondary)
}

private func field(_ placeholder: String, text: Binding<String>) -> some View {
    TextField(placeholder, text: text)
        .textFieldStyle(.plain)
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
}

private func nextButtonLabel(title: String, enabled: Bool) -> some View {
    HStack {
        Text(title).fontWeight(.bold)
        Image(systemName: "arrow.right")
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(enabled ? AppColors.primary : Color.gray.opacity(0.3))
    .foregroundStyle(.white)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .shadow(color: AppColors.primary.opacity(enabled ? 0.3 : 0), radius: 10, x: 0, y: 5)
}

private func stepDots(current: Int, total: Int = 3) -> some View {
    HStack(spacing: 8) {
        ForEach(1...total, id: \.self) { step in
            Capsule()
                .fill(step <= current ? AppColors.primary : AppColors.primary.opacity(0.2))
                .frame(width: step == current ? 24 : 12, height: 6)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onComplete: {})
        .modelContainer(try! ModelContainerFactory.createPreview())
}
