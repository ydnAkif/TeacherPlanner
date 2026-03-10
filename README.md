# Teacher Planner

Kişisel kullanım için geliştirilen, SwiftUI + SwiftData tabanlı öğretmen planlama uygulaması.

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20iPadOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.10-orange)
![UI](https://img.shields.io/badge/UI-SwiftUI-red)
![Data](https://img.shields.io/badge/Data-SwiftData-green)
![Version](https://img.shields.io/badge/version-0.3.x-purple)

---

## 📌 Durum Özeti (Gerçek Proje Durumu)

Bu README, mevcut kod tabanının **gerçek** durumuna göre güncellenmiştir.

- Uygulama temel akışları çalışır durumda (Today, Schedule, Courses, Planner, Semester, Settings)
- Projede mimari olarak Feature bazlı ayrım mevcut
- SwiftData modelleri ve servis katmanı var
- Test altyapısı kısmi
- Widget tarafında target/senaryo tutarsızlığı ve boş dosyalar mevcut
- Mimari borçlar ve kapsamlı aksiyon planı `ROADMAP.md` içinde

> Detaylı teknik analiz ve yol haritası için: **[`ROADMAP.md`](./ROADMAP.md)**

---

## ✨ Mevcut Özellikler

### Uygulama Ekranları
- **Today**
  - Bugünkü dersler
  - Sıradaki ders kartı
  - Bugünkü planner item’lar
- **Weekly Schedule**
  - Haftalık grid görünümü
  - Gün/saat bazlı session gösterimi
- **Courses**
  - Ders listeleme
  - Ders ekleme/düzenleme
  - Ders detay ekranı
- **Planner Items**
  - Görev/not/hatırlatma türleri
  - Filtreleme ve tamamlanma yönetimi
- **Semester**
  - Dönem ayarları
  - Skipped days yönetimi
- **Settings**
  - Bildirim ayarları
  - Görünüm ayarları
  - Veri sıfırlama

### Servisler
- Takvim/öğretim günü hesaplama
- Sıradaki ders hesaplama
- Günlük/haftalık schedule üretimi
- Bildirim zamanlama altyapısı

---

## 🛠 Teknoloji Yığını

- **Dil:** Swift 5.10+
- **UI:** SwiftUI
- **Veri Katmanı:** SwiftData
- **Concurrency:** async/await, actor tabanlı servisler (kısmi/tutarsız kullanım mevcut)
- **Bildirimler:** UserNotifications
- **Widget:** WidgetKit (uygulamada eksik/boş parçalar mevcut)

---

## 🧱 Mimari (Mevcut)

Proje klasör organizasyonu:

- `TeacherPlanner/App`
- `TeacherPlanner/Features`
- `TeacherPlanner/Models`
- `TeacherPlanner/Persistence`
- `TeacherPlanner/Services`
- `TeacherPlanner/Shared`
- `TeacherPlannerWidgets` (kısmi/boş dosyalar içeriyor)
- `TeacherPlannerTests`
- `TeacherPlannerUITests`

Mimari yaklaşım:
- Feature bazlı yapı
- View + Service merkezli akış
- MVVM bazı feature’larda var, bazılarında eksik/tutarsız
- DI ve repository/use-case katmanı henüz standartlaştırılmamış

---

## ⚠️ Bilinen Kritik Konular

Aşağıdakiler roadmap’te öncelikli ele alınacak konulardır:

1. **Widget tarafı eksik**
   - Widget dosyalarının bir kısmı boş
   - Widget data provider boş
2. **Boş/placeholder dosyalar**
   - AppEnvironment, bazı helper/extension dosyaları, test dosyaları
3. **Mimari tutarsızlıklar**
   - Actor/struct servis yaklaşımı tutarsız
   - MVVM her feature’da standart değil
4. **Error handling**
   - Yer yer `try?` ile hata yutma
5. **Test coverage düşük**
   - Bazı test dosyaları boş veya kapsam sınırlı

Detaylar: **[`ROADMAP.md`](./ROADMAP.md)**

---

## 🚀 Kurulum

### Gereksinimler
- Xcode 16+
- macOS 15+ / iOS 18+ / iPadOS 18+

### Çalıştırma
1. `TeacherPlanner.xcodeproj` dosyasını açın
2. Uygun scheme seçin
3. Build & Run (`Cmd + R`)

---

## 🗺 Yol Haritası

Roadmap fazları:

- **Faz 0 (Acil):** Widget implementasyonu + boş kritik dosyaların doldurulması
- **Faz 1:** MVVM standardizasyonu + test coverage artışı
- **Faz 2:** DI, repository/use-case, navigation refactor
- **Faz 3+:** Cloud sync, gelişmiş widgetlar, ileri özellikler

Tam plan: **[`ROADMAP.md`](./ROADMAP.md)**

---

## 🧪 Test

Mevcut:
- Unit test altyapısı var (kısmi)
- UI test altyapısı var (kısmi)

Hedef:
- Unit test coverage artışı
- Kritik user flow UI testleri
- Servis + ViewModel testlerinin tamamlanması

---

## 🤝 Katkı

1. Branch açın
2. Değişikliği küçük ve odaklı tutun
3. Test/derleme kontrolü yapın
4. PR açın ve ilgili roadmap maddesine referans verin

---

## 📄 Lisans

Bu proje kişisel kullanım için geliştirilmektedir.

---

## 👤 İletişim

**Akif AYDIN**  
GitHub: [@akifaydin](https://github.com/akifaydin)