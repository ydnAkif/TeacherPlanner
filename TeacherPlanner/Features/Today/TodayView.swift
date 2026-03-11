//
//  TodayView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var appEnvironment
    @StateObject private var viewModel = TodayViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && !viewModel.isInitialized {
                    loadingView
                } else {
                    contentView(viewModel: viewModel)
                }
            }
            .navigationTitle("Today")
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                if let env = appEnvironment {
                    await viewModel.setup(
                        modelContext: modelContext,
                        overviewUseCase: env.todayOverviewUseCase,
                        taskUseCase: env.plannerTaskUseCase
                    )
                }
            }
            .errorAlert(error: $viewModel.appError)
        }
    }

    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                SkeletonRect(height: 80, cornerRadius: AppSpacing.cornerRadiusLarge)
                    .padding(.horizontal)

                SkeletonRect(height: 120, cornerRadius: AppSpacing.cornerRadiusMedium)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    SkeletonText(width: 150, height: 20)
                        .padding(.horizontal)
                    SkeletonRect(height: 200, cornerRadius: AppSpacing.cornerRadiusMedium)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 8) {
                    SkeletonText(width: 100, height: 20)
                        .padding(.horizontal)
                    SkeletonRect(height: 150, cornerRadius: AppSpacing.cornerRadiusMedium)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func contentView(viewModel: TodayViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                dateHeader(viewModel: viewModel)

                if let nextClass = viewModel.nextClassResult {
                    NextClassCard(result: nextClass)
                        .padding(.horizontal)
                }

                if viewModel.hasTodayClasses {
                    todayClassesSection(viewModel: viewModel)
                } else if let semester = viewModel.activeSemester {
                    noClassesToday(semester: semester)
                }

                plannerItemsSection(viewModel: viewModel)

                QuickAddBar()
                    .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.loadData()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }

    private func dateHeader(viewModel: TodayViewModel) -> some View {
        VStack(spacing: 4) {
            Text(viewModel.dateDisplay)
                .font(.title2)
                .fontWeight(.semibold)

            if let semester = viewModel.activeSemester {
                Label(semester.name, systemImage: "graduationcap")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cornerRadiusLarge)
        .padding(.horizontal)
    }

    private func todayClassesSection(viewModel: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bugünkü Dersler")
                .font(.headline)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.todayClasses.indices, id: \.self) { index in
                    let (session, period) = viewModel.todayClasses[index]
                    let isCurrent = viewModel.currentClass?.session.id == session.id

                    TodayClassRow(
                        session: session,
                        period: period,
                        isCurrentClass: isCurrent
                    )
                    .padding(.horizontal)

                    if index < viewModel.todayClasses.count - 1 {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(AppColors.cardBackground)
            .cornerRadius(AppSpacing.cornerRadiusMedium)
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func noClassesToday(semester: Semester) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Bugün Ders Yok")
                .font(.headline)

            Text("Tatil gününün tadını çıkar! 🎉")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cornerRadiusMedium)
        .padding(.horizontal)
    }

    private func plannerItemsSection(viewModel: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Görevler")
                    .font(.headline)
                    .padding(.horizontal)

                Spacer()

                if !viewModel.todayPlannerItems.isEmpty {
                    Text("\(viewModel.todayPlannerItems.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.secondary.opacity(0.2))
                        .cornerRadius(4)
                        .padding(.trailing, 16)
                }
            }

            if viewModel.todayPlannerItems.isEmpty {
                Text("Bugün görev yok")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.todayPlannerItems) { item in
                        PlannerItemRow(
                            item: item,
                            onToggle: {
                                viewModel.toggleCompleted(item)
                            }
                        )
                        .padding(.horizontal)

                        if item.id != viewModel.todayPlannerItems.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
                .cornerRadius(AppSpacing.cornerRadiusMedium)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    TodayView()
}
