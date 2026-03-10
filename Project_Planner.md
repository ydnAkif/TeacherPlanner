# Project Planner

## Proje Özeti

Bu proje, öğretmenin kendi günlük kullanımına odaklanan sade, hızlı ve native hissi veren bir **Teacher Planner** uygulamasıdır.

İlk hedef:
- hangi gün hangi dersin olduğunu hızlı görmek
- bugünkü dersleri takip etmek
- sıradaki dersi görmek
- derse ait kısa not / görev eklemek
- widget üzerinden uygulamayı açmadan bilgi almak

Bu uygulama ilk aşamada:
- satılmak zorunda değil
- çok büyük bir platform olmayacak
- AI, Notion benzeri karmaşık yapı, öğrenci yönetimi gibi ağır özellikler içermeyecek
- kişisel kullanım öncelikli olacak

Temel yaklaşım:
- **basit ama güvenilir**
- **offline-first**
- **native**
- **widget odaklı**
- **öğretmen kullanımına uygun**
- **gereksiz özellik şişkinliğinden uzak**

---

## Ürün Vizyonu

Uygulamanın öz cümlesi:

> Dersimi, notumu ve haftamı tek bakışta göreyim.

Ana kullanım senaryosu:
1. Uygulamayı aç
2. Bugünkü dersleri gör
3. Sıradaki dersi gör
4. Gerekirse not / görev ekle
5. Haftalık planı kontrol et
6. Tatil günlerinde yanlış bildirim alma

---

## İlk Sürüm (V1) Hedefi

V1 kapsamında yalnızca aşağıdaki çekirdek yapı yapılacak:

### Dahil Olanlar
- Semester oluşturma
- Başlangıç / bitiş tarihi
- Weekend auto-skip
- Türkiye / MEB tatil preset mantığı
- Manuel skipped day ekleme / kaldırma
- Period-based weekly schedule
- Course oluşturma
- Class session atama
- Today ekranı
- Weekly Schedule ekranı
- Basit task / note sistemi
- Bildirimler
- Widgetlar

### Şimdilik Dahil Olmayanlar
- öğrenci listesi
- yoklama
- not sistemi
- kazanım / öğrenme çıktısı
- AI planner
- ekip paylaşımı
- Notion benzeri editör
- Calendar / Reminders entegrasyonu
- çok karmaşık biweekly / rotating schedule yapısı

---

## Teknoloji Kararları

### Platform
İlk hedef:
- macOS

Sonraki aşamalar:
- iPadOS
- iOS

### UI
- SwiftUI

### Veri Katmanı
- SwiftData

### Sync
İlk sürüm:
- local-first

Sonraki aşama:
- CloudKit (opsiyonel)

### Widget
- WidgetKit

### Bildirim
- UserNotifications

---

## Mimari Yaklaşım

Mimari sade tutulacak:

- Models
- Views
- Features
- Services
- Persistence
- Widgets
- Resources

MVVM benzeri sade bir yapı kullanılabilir; aşırı soyutlama yapılmayacak.

Amaç:
- okunabilir proje
- hızlı geliştirme
- sonradan büyütülebilir yapı

---

## Çekirdek Veri Modelleri

### 1. Semester
Bir eğitim dönemini temsil eder.

Alanlar:
- id
- name
- startDate
- endDate
- weekendRule
- skippedDays

### 2. SkippedDay
Ders yapılmayan günler.

Alanlar:
- id
- date
- reason
- type

`type` örnekleri:
- weekend
- holiday
- semesterBreak
- manual

### 3. Course
Ders / sınıf birleşik mantıkla tutulabilir.

Örnek:
- 5-C Fen Bilimleri
- 6-B Fen Bilimleri

Alanlar:
- id
- title
- colorHex
- symbolName
- notes

### 4. PeriodDefinition
Ders saatlerini tanımlar.

Alanlar:
- id
- title
- startTime
- endTime
- orderIndex

Örnek:
- 1. Ders / 08:40–09:20
- 2. Ders / 09:30–10:10

### 5. ClassSession
Bir gün ve period içine bir dersi bağlar.

Alanlar:
- id
- weekday
- course
- period
- room
- notes

Örnek:
- Monday + 2nd Period + 6-A Fen

### 6. PlannerItem
İlk sürümde task ve note birleşik mantıkta tutulabilir.

Alanlar:
- id
- title
- details
- type
- dueDate
- priority
- completed
- course

`type` örnekleri:
- note
- homework
- reminder
- exam
- material
- task

---

## Semester / School Day Engine

Bu projenin kritik parçası budur.

Temel fonksiyon:

`isInstructionalDay(date)`

Bu fonksiyon şunları kontrol eder:
1. tarih semester içinde mi
2. hafta sonu mu
3. skipped day mi
4. resmi tatil / ara tatil mi
5. manuel olarak kapatılmış gün mü

Bu `false` ise:
- ders bildirimi gitmez
- widgetta ders görünmez
- bugünkü ders listesine eklenmez

### Kurallar
- semester başlangıç ve bitiş aralığı dışı günler pasif
- Cumartesi ve Pazar varsayılan skipped
- Türkiye/MEB preset yüklenebilirse resmi tatil ve ara tatiller eklenir
- kullanıcı manuel olarak gün ekleyebilir / kaldırabilir

---

## Schedule Engine

İlk sürümde Sigma Planner benzeri çözüm kullanılacak.

### V1 schedule tipi
- weekly
- period-based

Desteklenmeyecek:
- rotating A/B days
- complex block schedules
- alternating week rules

### Mantık
Önce period tanımlanır:
- 1. Ders
- 2. Ders
- 3. Ders

Sonra haftalık eşleştirme yapılır:
- Pazartesi 1. Ders -> 6-A Fen
- Salı 3. Ders -> 5-C Fen

Bu yapı ile:
- weekly grid kolay çizilir
- next class kolay hesaplanır
- today ekranı kolay oluşturulur
- widget üretimi kolaylaşır

---

## Ekran Ağacı

### 1. Today
Amaç:
- bugünkü dersleri görmek
- sıradaki dersi görmek
- bugünkü task/note listesini görmek

İçerik:
- tarih
- active semester
- today classes
- next class
- today planner items
- quick add

### 2. Weekly Schedule
Amaç:
- haftalık grid görünümü

İçerik:
- Mon–Fri sütunları
- period satırları
- course blokları
- renkli kartlar

### 3. Courses
Amaç:
- dersleri listelemek
- yeni ders eklemek
- mevcut dersi düzenlemek

### 4. Course Detail
Amaç:
- seçili dersin detayını görmek

İçerik:
- ders başlığı
- renk / ikon
- notlar
- bağlı sessionlar
- ilgili planner itemlar

### 5. Planner Items
Amaç:
- not / görev listesi
- filtreleme

### 6. Semester Settings
Amaç:
- dönem tarihleri
- skipped day mantığı
- weekend rule
- MEB preset

### 7. Period Settings
Amaç:
- ders saatlerini tanımlamak

### 8. App Settings
Amaç:
- appearance
- notification preferences
- widget defaults
- local backup / export (ileride)

---

## Widget Planı

İlk sürümde hedef widgetlar:

### 1. Next Class Widget
- sıradaki ders
- saat
- ders adı

### 2. Today Classes Widget
- bugün olan derslerin listesi

### 3. Today Notes/Tasks Widget
- bugüne ait planner itemlar

### 4. Weekly Snapshot Widget
- küçük haftalık özet

Öncelik sırası:
1. Next Class
2. Today Classes
3. Today Notes
4. Weekly Snapshot

---

## Bildirim Planı

Bildirim mantığı doğrudan schedule’a değil, school day engine’e bağlı olacak.

Akış:
1. bugünün tarihi alınır
2. aktif semester bulunur
3. `isInstructionalDay(today)` kontrol edilir
4. o güne ait class sessionlar alınır
5. kullanıcı ayarına göre bildirim üretilir

Kurallar:
- skipped day ise bildirim yok
- semester dışı ise bildirim yok
- hafta sonu ise bildirim yok
- geçersiz günlerde widget da boş / uygun mesaj göstermeli

---

## Gelecek Sürümler İçin Açık Kapılar

V1’e dahil değil ama mimari bunlara kapalı olmayacak:

### V1.5 / V2
- CloudKit sync
- export / import
- .ics export
- Apple Calendar entegrasyonu
- reminder export
- ders bazlı daha güçlü filtreleme

### V2+
- lesson note ayrıştırma
- kazanım / öğrenme çıktısı
- yoklama
- öğrenci listesi
- ölçme değerlendirme
- AI destekli lesson helper
- Notion benzeri gelişmiş içerik alanları

---

## Proje Klasör Yapısı

Önerilen Xcode proje yapısı:

```text
TeacherPlanner/
├── App/
│   ├── TeacherPlannerApp.swift
│   ├── AppEnvironment.swift
│   └── RootView.swift
│
├── Models/
│   ├── Semester.swift
│   ├── SkippedDay.swift
│   ├── Course.swift
│   ├── PeriodDefinition.swift
│   ├── ClassSession.swift
│   ├── PlannerItem.swift
│   ├── WeekendRule.swift
│   ├── SkipType.swift
│   ├── PlannerItemType.swift
│   └── Weekday.swift
│
├── Features/
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── TodayViewModel.swift
│   │   ├── Components/
│   │   │   ├── NextClassCard.swift
│   │   │   ├── TodayClassRow.swift
│   │   │   └── QuickAddBar.swift
│   │
│   ├── Schedule/
│   │   ├── WeeklyScheduleView.swift
│   │   ├── WeeklyScheduleViewModel.swift
│   │   ├── Components/
│   │   │   ├── ScheduleGrid.swift
│   │   │   ├── ScheduleCell.swift
│   │   │   └── CourseBlockView.swift
│   │
│   ├── Courses/
│   │   ├── CourseListView.swift
│   │   ├── CourseDetailView.swift
│   │   ├── EditCourseView.swift
│   │   └── Components/
│   │       ├── CourseRow.swift
│   │       └── CourseHeaderCard.swift
│   │
│   ├── PlannerItems/
│   │   ├── PlannerItemListView.swift
│   │   ├── EditPlannerItemView.swift
│   │   └── Components/
│   │       ├── PlannerItemRow.swift
│   │       └── PlannerItemFilterBar.swift
│   │
│   ├── Semester/
│   │   ├── SemesterSettingsView.swift
│   │   ├── EditSemesterView.swift
│   │   ├── SkippedDaysView.swift
│   │   └── Components/
│   │       ├── SkippedDayRow.swift
│   │       └── SemesterSummaryCard.swift
│   │
│   ├── Periods/
│   │   ├── PeriodListView.swift
│   │   ├── EditPeriodView.swift
│   │   └── Components/
│   │       └── PeriodRow.swift
│   │
│   └── Settings/
│       ├── SettingsView.swift
│       ├── NotificationSettingsView.swift
│       └── AppearanceSettingsView.swift
│
├── Services/
│   ├── Calendar/
│   │   ├── SchoolDayEngine.swift
│   │   ├── SemesterPresetLoader.swift
│   │   ├── HolidayProvider.swift
│   │   └── MEBPresetProvider.swift
│   │
│   ├── Schedule/
│   │   ├── NextClassCalculator.swift
│   │   ├── TodayScheduleProvider.swift
│   │   └── WeeklyScheduleBuilder.swift
│   │
│   ├── Notifications/
│   │   ├── NotificationManager.swift
│   │   └── NotificationScheduler.swift
│   │
│   └── Widgets/
│       └── WidgetDataProvider.swift
│
├── Persistence/
│   ├── ModelContainerFactory.swift
│   ├── PreviewContainer.swift
│   └── SampleDataSeeder.swift
│
├── Shared/
│   ├── Extensions/
│   │   ├── Date+Helpers.swift
│   │   ├── Calendar+Helpers.swift
│   │   └── Color+Hex.swift
│   │
│   ├── UI/
│   │   ├── AppColors.swift
│   │   ├── AppSpacing.swift
│   │   ├── AppTypography.swift
│   │   └── EmptyStateView.swift
│   │
│   └── Helpers/
│       ├── Constants.swift
│       └── Logger.swift
│
├── Resources/
│   ├── Presets/
│   │   └── meb_2025_2026.json
│   └── Assets.xcassets
│
├── WidgetsExtension/
│   ├── TeacherPlannerWidgets.swift
│   ├── NextClassWidget.swift
│   ├── TodayClassesWidget.swift
│   ├── TodayPlannerItemsWidget.swift
│   └── WeeklySnapshotWidget.swift
│
└── TeacherPlannerTests/
    ├── SchoolDayEngineTests.swift
    ├── NextClassCalculatorTests.swift
    └── WeeklyScheduleBuilderTests.swift
```

---

## Geliştirme Sırası

### Faz 1 — Temel İskelet
1. Xcode proje oluştur
2. SwiftData container kur
3. temel modelleri yaz
4. sample data oluştur
5. root navigation kur

### Faz 2 — Semester Engine
1. Semester modeli
2. SkippedDay modeli
3. weekend rule
4. school day engine
5. MEB preset loader

### Faz 3 — Schedule Engine
1. PeriodDefinition
2. Course
3. ClassSession
4. weekly grid
5. next class hesabı

### Faz 4 — Today Experience
1. today screen
2. next class card
3. today class list
4. quick add

### Faz 5 — Planner Items
1. item listesi
2. item ekleme / düzenleme
3. filtreleme
4. course ilişkisi

### Faz 6 — Notifications + Widgets
1. notification manager
2. next class widget
3. today classes widget
4. skipped day aware davranış

### Faz 7 — Polish
1. tema iyileştirme
2. performans
3. testler
4. export/import hazırlığı

---

## İlk Sprint İçin To-Do

İlk hedef sprint:

- [ ] Xcode proje oluştur
- [ ] SwiftData kur
- [ ] temel modelleri ekle
- [ ] sample data yaz
- [ ] basic sidebar / tab navigation yap
- [ ] Today boş ekranı oluştur
- [ ] Weekly Schedule boş grid oluştur
- [ ] Semester ekranı oluştur
- [ ] Period ekranı oluştur

---

## Teknik Notlar

### Tarih / Saat
- date kıyaslarında `Calendar.current.startOfDay(for:)` yaklaşımı kullanılmalı
- skipped day kontrolü tam timestamp yerine aynı gün mantığıyla yapılmalı

### Bildirimler
- ders bildirimi üretmeden önce school day engine mutlaka kontrol edilmeli

### Test Önceliği
Aşağıdaki parçalar test edilmeli:
- `isInstructionalDay`
- next class hesabı
- weekly schedule grid üretimi

### Tasarım İlkesi
- sade
- gereksiz animasyon yok
- veri girişi hızlı
- widget merkezli düşünce
- native görünüm
- form şişkinliği yok

---

## Son Karar Özeti

Bu uygulama:
- büyük öğretmen platformu değil
- kişisel kullanım odaklı
- Sigma benzeri sade planlayıcı
- ama semester ve bildirim mantığı daha doğru çalışan sürüm olacak

İlk hedef:
- hızlı çalışan sağlam çekirdek

Sonraki hedef:
- istenirse öğretmen özellikleriyle büyütmek

