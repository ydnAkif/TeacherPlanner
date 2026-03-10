# TeacherPlanner TODO

Bu dosya, `ROADMAP.md` ile hizalı olacak şekilde faz bazlı yeniden düzenlenmiştir.  
Öncelik sırası: **P0 > P1 > P2 > P3**

---

## Durum Etiketleri

- [ ] Bekliyor
- [~] Devam Ediyor
- [x] Tamamlandı
- [!] Bloklu / Dış Bağımlı

---

## FAZ 0 — Acil Düzeltmeler (P0)

> Hedef: Çalışmayan/eksik kritik parçaları tamamlamak

### 0.1 Widget Altyapısı
- [x] Widget extension akışını doğrula (target/scheme/build config)
- [x] `TeacherPlannerWidgets/NextClassWidget.swift` implement et
- [x] `TeacherPlannerWidgets/TodayClassesWidget.swift` implement et
- [x] `TeacherPlannerWidgets/TodayPlannerItemsWidget.swift` implement et
- [x] `TeacherPlannerWidgets/WeeklySnapshotWidget.swift` implement et
- [x] `TeacherPlanner/Services/Widgets/WidgetDataProvider.swift` implement et
- [x] App Group veri paylaşımı stratejisini netleştir ve uygula
- [x] Widget placeholder/timeline/snapshot senaryolarını tamamla
- [x] Widget preview’leri ekle ve doğrula

### 0.2 Boş Kritik Dosyalar
- [x] `TeacherPlanner/App/AppEnvironment.swift` doldur (app-level dependency merkezi)
- [x] `TeacherPlanner/Features/Schedule/WeeklyScheduleViewModel.swift` doldur
- [x] `TeacherPlanner/Shared/Helpers/Constants.swift` doldur
- [x] `TeacherPlanner/Shared/Helpers/Logger.swift` doldur
- [x] `TeacherPlanner/Shared/Extensions/Date+Helpers.swift` doldur
- [x] `TeacherPlanner/Shared/Extensions/Calendar+Helpers.swift` doldur

### 0.3 Stabilizasyon
- [x] `@State` ile tutulan referans tipleri gözden geçir (`@StateObject` / `@Observable` kararları)
- [x] Kritik `try?` noktalarını hata görünürlüğü olan akışlara taşı
- [x] Sessizce yutulan hata noktalarına log + kullanıcı mesajı ekle

---

## FAZ 1 — Temel Kalite İyileştirmeleri (P1)

> Hedef: Kod kalitesini ve sürdürülebilirliği artırmak

### 1.1 MVVM Standardizasyonu
- [x] Courses için ViewModel katmanı oluştur
- [x] PlannerItems için ViewModel katmanı oluştur
- [x] Settings için ViewModel katmanı oluştur
- [x] Weekly Schedule ekranında ViewModel akışını oturt
- [x] View'lardan business logic taşı (View → ViewModel)

### 1.2 Error Handling Standardizasyonu
- [x] `AppError` tipini gerçek kullanımda merkezileştir
- [x] Error mapping stratejisi belirle (storage, validation, permission)
- [ ] UI’da tutarlı hata gösterimi (alert/banner) standardı oluştur
- [x] Geliştirici logu ile kullanıcı mesajını ayır

### 1.3 Kod Temizliği
- [ ] Kullanılmayan kod/enum/extension’ları temizle
- [ ] Tekrarlanan tarih formatlama kodlarını helper’a taşı
- [x] Magic number/string noktalarını constants üzerinden yönet
- [x] Dosya adlandırma ve klasör yapısını tutarlı hale getir

---

## FAZ 1.5 — Test Tabanı (P1)

> Hedef: Kırılmaları erken yakalayacak minimum güvenlik ağı

### 1.5.1 Unit Test
- [x] `TeacherPlannerTests/WeeklyScheduleBuilderTests.swift` doldur
- [x] `SchoolDayEngine` edge-case testleri ekle
- [x] `NextClassCalculator` edge-case testleri ekle
- [x] `PlannerItem` model testleri ekle (`PlannerItemTests.swift`)

### 1.5.2 UI Test
- [ ] Onboarding ana akışını stabil hale getir
- [ ] Kritik kullanıcı akışları için UI test ekle:
  - [ ] Yeni ders ekleme
  - [ ] Planner item tamamlama
  - [ ] Haftalık program hücre düzenleme
  - [ ] Semester/Skipped day yönetimi

---

## FAZ 2 — Mimari Güçlendirme (P2)

> Hedef: Ölçeklenebilir, modüler ve test edilebilir yapı

### 2.1 Dependency Inversion / DI
- [x] Servisler için protokol arayüzleri tanımla (`ServiceProtocols.swift`)
- [ ] ViewModel’lerde concrete bağımlılıkları soyutla
- [x] Uygulama seviyesinde dependency composition kökü oluştur (`AppEnvironment`)
- [x] Mock/Stub kolaylaştıracak yapı kur (protokol tipleri)

### 2.2 Domain Katmanı (Use Case)
- [ ] Kritik akışlar için use-case katmanı çıkar:
  - [ ] Bugünkü dersleri getir
  - [ ] Sıradaki dersi hesapla
  - [ ] Planner item tamamlama
  - [ ] Bildirim yeniden zamanlama
- [ ] ViewModel → UseCase bağımlılık çizgisini netleştir

### 2.3 Data Erişim Standardı
- [ ] SwiftData erişimini repository benzeri katmanla sadeleştir
- [ ] Ortak fetch/save yardımcıları tanımla
- [ ] Predicate/sort kalıplarını tekrar kullanılabilir hale getir

### 2.4 Navigation Refactor
- [ ] Uygulama genelinde navigation modelini standardize et
- [ ] Dağınık navigation state’lerini tek akışta topla
- [ ] Deep link / state restoration için temel hazırlık yap

---

## FAZ 3 — Ürün Genişletme (P3)

> Hedef: Kullanıcı değerini artıran ileri özellikler

### 3.1 Senkronizasyon
- [ ] Cloud sync değerlendirmesi (iCloud/CloudKit)
- [ ] Çakışma çözüm stratejisi
- [ ] Offline-first davranış kararları

### 3.2 Widget 2.0
- [ ] Interactive widget senaryoları
- [ ] Lock screen/standby varyantları
- [ ] Widget performans ve güncelleme stratejisi

### 3.3 Veri Yönetimi
- [ ] Export/Import (JSON/ics kapsam kararı)
- [ ] Backup/Restore akışı
- [ ] Veri migrasyonu ve sürümleme notları

---

## Teknik Borç Backlog’u

- [ ] Actor/struct tutarsız servis tasarımını standardize et
- [ ] `SettingsView` içindeki business logic’i ayır
- [ ] Notification izin akışını kullanıcı açısından netleştir
- [ ] Büyük view dosyalarını alt bileşenlere böl
- [ ] Performans: tekrarlı fetch noktalarında optimizasyon yap

---

## Dokümantasyon Görevleri

- [ ] `README.md` ile gerçek durumun eşleşmesini koru
- [ ] `ROADMAP.md` güncellendikçe TODO fazlarını senkron tut
- [ ] Mimari kararlar için kısa ADR notları ekle
- [ ] Test stratejisini tek bir dokümanda topla

---

## Sprint Önerisi (Kısa Plan)

### Sprint A (1-2 hafta)
- [x] Faz 0 maddelerinin %100 tamamlanması
- [x] Widget’ların çalışır hale gelmesi
- [x] Boş kritik dosyaların kapatılması

### Sprint B (1-2 hafta)
- [ ] Faz 1 + 1.5 başlangıcı
- [ ] MVVM standardizasyonu (en az 2 feature)
- [ ] Unit test coverage anlamlı artış

### Sprint C (2 hafta)
- [ ] Faz 2 başlangıcı
- [ ] DI/Protocol omurgası
- [ ] Use-case pilot uygulama

---

## Tanım (Definition of Done)

Bir görev ancak şu koşullarla tamamlanmış sayılır:

- [ ] Kod derleniyor
- [ ] İlgili testler geçiyor
- [ ] Hata/boş state akışı ele alınmış
- [ ] Gerekli dokümantasyon güncellenmiş
- [ ] Roadmap/TODO tutarlılığı korunmuş