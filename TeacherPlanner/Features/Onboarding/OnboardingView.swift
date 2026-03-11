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
    @Environment(\.appEnvironment) private var appEnvironment
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
            ZStack {
                // Arka plan gradyanı
                LinearGradient(
                    colors: [AppColors.primary.opacity(0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        // Header Bölümü
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
                                
                                Text("Öğretmen Planlayıcı ile derslerinizi organize edin")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, AppSpacing.medium)

                        // Input Bölümü
                        VStack(spacing: AppSpacing.medium) {
                            onboardingCard(title: "Okul Bilgileri", icon: "school") {
                                VStack(alignment: .leading, spacing: AppSpacing.small) {
                                    Text("Okul Adı")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                    
                                    TextField("Örn: Atatürk Ortaokulu", text: $schoolName)
                                        .textFieldStyle(.plain)
                                        .padding(10)
                                        .background(Color.white)
                                        .cornerRadius(AppSpacing.cornerRadiusMedium)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }

                            onboardingCard(title: "Dönem Bilgileri", icon: "calendar") {
                                VStack(spacing: AppSpacing.medium) {
                                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                                        Text("Akademik Yıl")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.secondary)
                                        
                                        TextField("2025-2026", text: $academicYear)
                                            .textFieldStyle(.plain)
                                            .padding(10)
                                            .background(Color.white)
                                            .cornerRadius(AppSpacing.cornerRadiusMedium)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }

                                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                                        Text("Dönem Tipi")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.secondary)
                                        
                                        Picker("Dönem Tipi", selection: $semesterType) {
                                            ForEach(SemesterType.allCases, id: \.self) { type in
                                                Text(type.rawValue).tag(type)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                }
                            }
                            
                            // Özet Card
                            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                                Label("Özet", systemImage: "info.circle")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppColors.primary)
                                
                                HStack {
                                    Text("Oluşturulacak Dönem:")
                                        .font(.footnote)
                                    Spacer()
                                    Text(generatedSemesterName)
                                        .font(.footnote.bold())
                                        .foregroundStyle(AppColors.primary)
                                }
                                .padding(10)
                                .background(AppColors.primary.opacity(0.05))
                                .cornerRadius(AppSpacing.cornerRadiusMedium)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: 450)

                        // Devam Butonu
                        Button {
                            createSemester()
                        } label: {
                            HStack {
                                Text("Başlayalım")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? AppColors.primary : Color.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .cornerRadius(AppSpacing.cornerRadiusLarge)
                            .shadow(color: AppColors.primary.opacity(isFormValid ? 0.3 : 0), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isFormValid)
                        .frame(maxWidth: 450)
                        .padding(.horizontal)
                        .padding(.bottom, AppSpacing.large)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("")
            .sheet(isPresented: $showingPeriodSetup) {
                PeriodSetupView()
            }
        }
    }

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
        .cornerRadius(AppSpacing.cornerRadiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusXLarge)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
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

        Task {
            do {
                if let env = appEnvironment {
                    // MEBPreset için hala context gerekebilir, repository'ye taşınabilir ama şimdilik burada kalsın
                    MEBPresetProvider.applyMEBPreset(to: semester, in: modelContext)
                    try await env.semesterRepository.save(semester)
                    showingPeriodSetup = true
                }
            } catch {
                print("Error saving semester: \(error)")
            }
        }
    }
}

#Preview {
    OnboardingView()
}
