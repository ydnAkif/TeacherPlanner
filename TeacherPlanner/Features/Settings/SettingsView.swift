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

    @StateObject private var viewModel = SettingsViewModel()

    @AppStorage(Constants.Notification.Keys.enabled) private var notificationsEnabled = true
    @AppStorage(Constants.Notification.Keys.minutesBefore) private var reminderMinutesBefore = Constants.Notification.defaultReminderMinutesBefore
    @AppStorage(Constants.UI.Keys.appearanceMode) private var appearanceMode = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Bildirimler") {
                    Toggle("Ders Bildirimleri", isOn: $notificationsEnabled)

                    if notificationsEnabled {
                        Picker("Hatırlatma Zamanı", selection: $reminderMinutesBefore) {
                            ForEach(Constants.Notification.reminderOptions, id: \.self) { minutes in
                                Text("\(minutes) dakika önce").tag(minutes)
                            }
                        }

                        Button(action: viewModel.requestNotificationPermission) {
                            HStack {
                                Text("Bildirim İzni Ver")
                                Spacer()
                                if viewModel.notificationPermissionGranted {
                                    Label("Verildi", systemImage: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Label("Verilmedi", systemImage: "exclamationmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }

                Section("Görünüm") {
                    Picker("Tema", selection: $appearanceMode) {
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
                viewModel.setup(modelContext: modelContext)
            }
            .alert("Tüm Verileri Sil", isPresented: $viewModel.showingResetAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("Bu işlem tüm dönemleri, dersleri ve görevleri silecek. Bu işlem geri alınamaz!")
            }
            .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Tamam") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    SettingsView()
}
