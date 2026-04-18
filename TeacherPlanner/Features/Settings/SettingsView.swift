//
//  SettingsView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftData
import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var appEnvironment

    @AppStorage(Constants.UI.Keys.appearanceMode) private var appearanceMode: Int = 0
    @StateObject private var viewModel = SettingsViewModel()

    private var appearanceModeLabel: String {
        switch appearanceMode {
        case 1: return "Açık"
        case 2: return "Koyu"
        default: return "Sistem"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("Bildirimler"),
                    footer: Text(
                        viewModel.notificationsEnabled && !viewModel.notificationPermissionGranted
                            ? "⚠️ Bildirimler açık ancak uygulama izinlerine sahip değil. Lütfen 'Bildirim İzni Ver' butonuyla izin verin."
                            : "")
                ) {
                    Toggle("Ders Bildirimleri", isOn: $viewModel.notificationsEnabled)

                    if viewModel.notificationsEnabled {
                        Picker("Hatırlatma Zamanı", selection: $viewModel.reminderMinutesBefore) {
                            ForEach(Constants.Notification.reminderOptions, id: \.self) { minutes in
                                Text("\(minutes) dakika önce").tag(minutes)
                            }
                        }

                        Button(action: viewModel.requestNotificationPermission) {
                            HStack {
                                Text(
                                    viewModel.notificationPermissionGranted
                                        ? "Bildirim İzni Verildi" : "Bildirim İzni Ver")
                                Spacer()
                                if viewModel.notificationPermissionGranted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }

                Section("Görünüm") {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        HStack {
                            Label("Tema", systemImage: "paintbrush")
                            Spacer()
                            Text(appearanceModeLabel)
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }
                }

                Section("Dönem") {
                    NavigationLink {
                        SemesterSettingsView()
                    } label: {
                        Label("Dönem Ayarları", systemImage: "graduationcap")
                    }

                    NavigationLink {
                        PeriodListView()
                    } label: {
                        Label("Ders Saatleri", systemImage: "clock")
                    }
                }

                Section("Veri Yönetimi") {
                    Button(role: .destructive) {
                        viewModel.showingResetAlert = true
                    } label: {
                        Label("Tüm Verileri Sil", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }

                    if viewModel.showingResetSuccess {
                        Label("Veriler silindi!", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }

                Section("Hakkında") {
                    LabeledContent("Versiyon", value: Constants.App.version)
                    LabeledContent("Build", value: Constants.App.build)
                }
            }
            .navigationTitle("Ayarlar")
            .task {
                await viewModel.checkNotificationPermission()
            }
            .onAppear {
                if let env = appEnvironment {
                    viewModel.setup(scheduler: env.notificationScheduler)
                }
            }
            .alert("Tüm Verileri Sil", isPresented: $viewModel.showingResetAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    viewModel.resetAllData(context: modelContext)
                }
            } message: {
                Text(
                    "Bu işlem tüm dönemleri, dersleri ve görevleri silecek. Bu işlem geri alınamaz!"
                )
            }
            .errorAlert(error: $viewModel.appError)
        }
    }
}

#Preview {
    SettingsView()
}
