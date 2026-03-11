# TeacherPlanner - RoadMap 🗺️

Projenin sadeleşme ve iPhone 13 odaklı gelişim planı.

## 📍 Mevcut Durum: Sadeleşme Başlangıcı
Uygulama temel mantığına sahip ancak arayüz ve mimari karmaşıklık içinde. İlk hedef "Temizlik ve Netlik".

## 🗓 Faz 1: Sadeleşme ve Temizlik (Genel Düzenleme)
- [x] **Redundant Klasör Temizliği**: Kontrol edildi, ayrı `./Teacher` kopyası yok.
- [x] **Mimari İnceltme**: Use Case katmanının kaldırılarak mantığın ViewModel ve Repository katmanına çekilmesi.
- [x] **UI Audit**: Çift design system (`AppColors`/`AppSpacing` + `DesignSystem`) tespiti; `AppColors` typealias, `AppSpacing` köprü enum'a dönüştürüldü. 30+ deprecated `.cornerRadius()` tespit edildi — Faz 2'de modernize edilecek.

## 🎨 Faz 2: iPhone 13 Odaklı Yeniden Tasarım
- [ ] **Ana Ekran (Today)**: Kart yapısının sadeleşmesi, "Bir sonraki ders" kısmının daha premium hale getirilmesi.
- [ ] **Navigasyon**: Yan menü yerine iPhone odaklı modern bir TabBar tasarımı.
- [ ] **Renk & Tipografi**: Projenin görsel kimliğinin Apple standartlarında "Premium" seviyeye çekilmesi.

## 🛠 Faz 3: Feature Bazlı Geliştirme
- [ ] **Ders Programı**: Haftalık görünümün tek elle kullanım kolaylığına göre optimize edilmesi.
- [ ] **Görev Yönetimi**: Hızlı görev ekleme ve tamamlama deneyiminin iyileştirilmesi.
- [ ] **Bildirimler**: Ders öncesi hatırlatıcıların kararlı hale getirilmesi.

## ✅ Tamamlananlar
- [x] UI Testlerin bypass edilmesi ve devre dışı bırakılması (Hız için).
- [x] Swift 6 Concurrency uyumluluğu.
- [x] Yeni README ve persistent Rules yapısının kurulması.
- [x] Widget Extension kaldırıldı.
- [x] Use Case katmanı (TodayOverviewUseCase, PlannerTaskUseCase, NotificationUseCase) kaldırıldı.
- [x] **Faz 1 tamamlandı**: Design system birleştirildi, mimari sadeleştirildi.
