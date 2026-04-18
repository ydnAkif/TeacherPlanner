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

    @State private var viewModel: TodayViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    contentView(viewModel: vm)
                        .refreshable {
                            await vm.loadData()
                        }
                } else {
                    loadingView
                }
            }
            .navigationTitle("Bugün")
            .task {
                guard viewModel == nil, let env = appEnvironment else { return }
                let vm = TodayViewModel(
                    modelContext: modelContext,
                    schoolDayEngine: env.schoolDayEngine,
                    nextClassCalculator: env.nextClassCalculator,
                    todayScheduleProvider: env.todayScheduleProvider
                )
                viewModel = vm
                await vm.loadData()
            }
            .errorAlert(
                error: Binding(
                    get: { viewModel?.appError },
                    set: { viewModel?.appError = $0 }
                ))
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
                TodayDateHeader(
                    dateDisplay: viewModel.dateDisplay,
                    semesterName: viewModel.activeSemester?.name
                )

                if let nextClass = viewModel.nextClassResult {
                    NextClassCard(result: nextClass)
                        .padding(.horizontal)
                }

                if viewModel.hasTodayClasses {
                    TodayClassesSection(
                        classes: viewModel.todayClasses,
                        currentClassId: viewModel.currentClass?.session.id
                    )
                } else if viewModel.activeSemester != nil {
                    NoClassesView()
                }

                TodayPlannerSection(
                    items: viewModel.todayPlannerItems,
                    onToggle: { item in
                        viewModel.toggleCompleted(item)
                    }
                )

                QuickAddBar(onItemAdded: {
                    viewModel.refreshPlannerItems()
                })
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    TodayView()
}
