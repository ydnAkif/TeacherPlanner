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

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Bildirimler"), footer: Text(viewModel.notificationsEnabled && !viewModel.notificationPermissionGranted ? "⚠️ Bildirimler açık ancak uygulama izinlerine sahip değil. Lütfen 'Bildirim İzni Ver' butonuyla izin verin." : "")) {
                    Toggle("Ders Bildirimleri", isOn: $viewModel.notificationsEnabled)

                    if viewModel.notificationsEnabled {
                        Picker("Hatırlatma Zamanı", selection: $viewModel.reminderMinutesBefore) {
                            ForEach(Constants.Notification.reminderOptions, id: \.self) { minutes in
                                Text("\(minutes) dakika önce").tag(minutes)
                            }
                        }

                        Button(action: viewModel.requestNotificationPermission) {
                            HStack {
                                Text(viewModel.notificationPermissionGranted ? "Bildirim İzni Verildi" : "Bildirim İzni Ver")
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
                    Picker("Tema", selection: $viewModel.appearanceMode) {
                        Text("Sistem").tag(0)
                        Text("Açık").tag(1)
                        Text("Koyu").tag(2)
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
                    viewModel.setup(
                        modelContext: modelContext,
                        scheduler: env.notificationScheduler
                    )
                }
            }
            .alert("Tüm Verileri Sil", isPresented: $viewModel.showingResetAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("Bu işlem tüm dönemleri, dersleri ve görevleri silecek. Bu işlem geri alınamaz!")
            }
            .errorAlert(error: $viewModel.appError)
        }
    }
}

#Preview {
    SettingsView()
}
