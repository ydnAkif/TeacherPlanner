# TeacherPlanner 🍎

Öğretmenler için ders planlama, takip ve organizasyon uygulaması — SwiftUI + SwiftData.

> [!IMPORTANT]
> Bu proje **iPhone 13** hedefiyle geliştirilmektedir. Onboarding akışı kararlı hale getirildi; şu an Faz 2 (görsel kalite + feature tamamlama) aşamasındadır.

---

## 🎯 Hedefler

- **Mükemmel UI/UX** — iPhone 13 form faktörüne tam uyumlu, akıcı ve şık arayüz
- **Minimum Karmaşıklık** — Tek bakışta bugünkü dersler, görevler ve sonraki ders
- **Kararlı Veri Katmanı** — SwiftData ile hızlı ve güvenilir veri yönetimi

---

## 🏗 Mimari

**MVVM** + SwiftData, sade servis katmanı.

```
App
├── TeacherPlannerApp   — SQLite container başlatma, kurtarma mekanizması
├── RootView            — AppEnvironment zorunlu parametre; onboarding ↔ main geçişi
└── AppEnvironment      — Dependency Injection konteyneri

Features/
├── Onboarding          — 3 adımlı akış; async finish() → MEBPreset arka planda
├── Today               — TodayViewModel + loadData()
├── Schedule            — WeeklyScheduleBuilder
├── Courses             — CRUD
├── PlannerItems        — CRUD + QuickAddBar
└── Settings            — Dönem yönetimi

Services/
├── Calendar/
│   ├── SchoolDayEngine        — Öğretim günü hesaplama
│   ├── MEBPresetProvider      — MEB tatil/ara tatil preset (nonisolated)
│   └── HolidayProvider        — TC resmi tatilleri (nonisolated)
├── Schedule/
│   ├── NextClassCalculator    — Sonraki ders hesaplama
│   └── TodayScheduleProvider  — Bugünkü ders listesi
└── Notifications/
    ├── NotificationScheduler
    └── NotificationManager

Models/
├── Semester, SkippedDay, WeekendRule
├── Course, ClassSession, PeriodDefinition
└── PlannerItem
```

---

## 🚀 Başlangıç

1. Xcode 16+ ile projeyi açın
2. Hedef: **iPhone 13** (iOS 18+)
3. `Cmd + R`

İlk çalıştırmada onboarding akışı başlar:
- **Adım 1** — Okul adı ve akademik yıl
- **Adım 2** — Dönem başlangıç / bitiş tarihleri
- **Adım 3** — Ders saatleri (MEB standart saatleri önceden dolu gelir)

---

## ⚡ Son Düzeltmeler

| Sorun | Çözüm |
|-------|-------|
| "Kurulumu Tamamla" ekranı donuyordu | `finish()` → `Task { @MainActor }` + `Task.detached` ile MEBPreset arka plana taşındı |
| Onboarding sonrası kalıcı spinner | `AppEnvironment` `@Environment`'tan değil, doğrudan parametre olarak `RootView`'a geçiliyor |
| SQLite bozulması → sonsuz yükleme | Container oluşturmada `fatalError` yerine store silip yeniden deneme mekanizması |
| Swift 6 concurrency hataları | `MEBPresetProvider`, `HolidayProvider`, `WeekendRule` metodları `nonisolated` yapıldı |

---

## 🔧 Bilinen Teknik Borç

- `PlannerItem.priority` `Int` yerine `enum Priority` olmalı
- `Semester.isActive` — birden fazla aktif dönem için koruma yok
- `SchoolDayEngine` init'indeki `weekendRule` parametresi kullanılmıyor (dead code)
- Widget kalıntıları: `appGroupIdentifier` ve entitlements temizlenmedi
- 30+ deprecated `.cornerRadius()` kullanımı (Faz 2'de düzeltilecek)
- TabBar 5 sekme → 4 sekmeye indirilecek

---

## 📁 Önemli Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `.agent/rules.md` | Geliştirme kuralları ve kalıcı kararlar |
| `ROADMAP.md` | Faz planı ve teknik borç listesi |
| `Advices.md` | Uzman analizi ve mimari tavsiyeler |

---

*Geliştirme notları için [.agent/rules.md](.agent/rules.md) — Yol haritası için [ROADMAP.md](ROADMAP.md)*