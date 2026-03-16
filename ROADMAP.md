# TeacherPlanner - RoadMap 🗺️

Projenin sadeleşme ve iPhone 13 odaklı gelişim planı.

---

## 📍 Mevcut Durum

Temel onboarding akışı kararlı hale getirildi. Uygulama sorunsuz başlıyor, veriler doğru kaydediliyor ve ana ekrana geçiş güvenilir. Sonraki odak: görsel kalite ve feature tamamlama.

---

## ✅ Tamamlananlar

### Altyapı & Mimari
- [x] Widget Extension kaldırıldı
- [x] Use Case katmanı (TodayOverviewUseCase, PlannerTaskUseCase, NotificationUseCase) kaldırıldı
- [x] Design system birleştirildi (`AppColors` + `AppSpacing`)
- [x] macOS `#if` blokları kaldırıldı (sadece iOS hedefi)
- [x] Swift 6 Concurrency uyumluluğu sağlandı
- [x] `setup()` anti-pattern kaldırıldı; ViewModel'ler `init` ile başlatılıyor

### Onboarding
- [x] Gerçek 3 adımlı onboarding akışı (Okul bilgisi → Dönem tarihleri → Ders saatleri)
- [x] `PeriodSetupView` — `sheet(item:)` tabanlı güvenilir edit akışı
- [x] Onboarding tamamlandığında ana ekrana geçiş için `onComplete` callback zinciri

### Kritik Hata Düzeltmeleri
- [x] **UI Donma Sorunu** — `finish()` metodu main thread'i blokluyor, ~130–180 gün döngüsü + 100+ SwiftData insert senkron çalışıyordu → `Task { @MainActor in }` + `Task.detached` ile asenkron hale getirildi
- [x] **Kalıcı Spinner Sorunu** — `RootView`, `@Environment` okuma sırasında `appEnvironment` nil geldiğinde ProgressView'da takılıyordu → `AppEnvironment` doğrudan parametre olarak geçildi, nil riski ortadan kaldırıldı
- [x] **Swift 6 Concurrency Hataları** — `MEBPresetProvider`, `HolidayProvider`, `WeekendRule` metodları `@MainActor` olarak yanlış çıkarımlandı → `nonisolated` ile düzeltildi
- [x] **SQLite Kurtarma Mekanizması** — Bozuk store durumunda `fatalError` yerine store sıfırlayıp yeniden başlatma, hata ekranı gösterme

### Performans
- [x] MEBPreset hesaplama arka plana taşındı (`Task.detached`)
- [x] `SkippedDayData` — SwiftData bağımsız, `Sendable` veri taşıyıcısı eklendi

---

## 🗓 Faz 2: iPhone 13 Odaklı Yeniden Tasarım (Aktif)

- [ ] **Ana Ekran (Today)** — `NextClassCard` premium hale getirilecek; kalan süre daha belirgin, renk entegrasyonu iyileştirilecek
- [ ] **TabBar Sadeleştirme** — 5 tab → 4 tab (Semester sekmesi Settings altına)
- [ ] **Navigasyon Dili** — Tüm ekranlar Türkçe'ye çekilecek (şu an bazı başlıklar İngilizce)
- [ ] **`.cornerRadius()` → `.clipShape`** — 30+ deprecated kullanım modernize edilecek

---

## 🛠 Faz 3: Feature Tamamlama

- [ ] **Ders Programı (Schedule)** — Haftalık görünüm optimizasyonu, tek elle kullanım
- [ ] **Görev Yönetimi** — Hızlı ekleme ve tamamlama deneyimi
- [ ] **Bildirimler** — Ders öncesi hatırlatıcıların kararlı çalışması
- [ ] **Onboarding Tarihleri** — Sabit MEB tarihleri yerine kullanıcıya DatePicker + tahmini başlangıç noktası

---

## 🔧 Teknik Borç (Öncelik Sırasıyla)

| # | Aksiyon | Etki | Durum |
|---|---------|------|-------|
| 1 | Widget kalıntıları (`appGroupIdentifier`, entitlements) temizle | Temizlik | Bekliyor |
| 2 | `PlannerItem.priority` → `enum Priority` | Doğruluk | Bekliyor |
| 3 | `Course.colorHex` String → `RawRepresentable` enum | Sağlamlık | Bekliyor |
| 4 | `Semester.isActive` çakışma koruması | Veri bütünlüğü | Bekliyor |
| 5 | `SchoolDayEngine.weekendRule` init parametresi kullanılmıyor (bug) | Düzeltme | Bekliyor |
| 6 | Repository pattern kaldırma (sadece `@Query` + `modelContext`) | Sadeleşme | Bekliyor |
| 7 | `AppError` — kullanılmayan network case'leri temizle | Temizlik | Bekliyor |
| 8 | `SchoolDayEngine.getActiveSemester()` — `AppEnvironment`'ta cache'le | Performans | Bekliyor |

---

## 📐 Mimari Notlar

```
App
├── TeacherPlannerApp   — Container başlatma, SQLite recovery
├── RootView            — AppEnvironment zorunlu parametre, onboarding/main geçişi
└── AppEnvironment      — DI konteyneri (SchoolDayEngine, Router, vb.)

Features/
├── Onboarding          — 3 adımlı akış, async finish() ile MEBPreset
├── Today               — ViewModel + loadData()
├── Schedule            — WeeklyScheduleBuilder
├── Courses             — CRUD
├── PlannerItems        — CRUD + QuickAdd
└── Settings            — Dönem yönetimi

Services/
├── Calendar/           — SchoolDayEngine, MEBPresetProvider (nonisolated), HolidayProvider
├── Schedule/           — NextClassCalculator, TodayScheduleProvider
└── Notifications/      — NotificationScheduler, NotificationManager
```

---

*Son güncelleme: Onboarding async fix, spinner fix, Swift 6 nonisolated düzeltmeleri.*