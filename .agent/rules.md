# TeacherPlanner - Assistant Persistence & Rules

Bu dosya, projeye yeni bir model veya asistan katıldığında bağlamı ve kuralları hatırlaması için oluşturulmuştur.

## 📱 Hedef Platform & Cihaz
- **Cihaz**: iPhone 13 (Arayüz kararları bu fiziksel boyuta göre verilmeli).
- **Odak**: Sadece iOS (MacOS desteği şu an için öncelik değildir, kod sadeleşmeli).

## 🛠 Mimari Prensipler**
- **Sadeleşme**: Clean Architecture (Use Cases, Protocols) şu anki ölçek için fazla karmaşıklık yaratıyor. Daha doğrudan (ViewModel -> Repository/SwiftData) bir yapı tercih edilecek.
- **Tasarım**: "Premium" ve "Modern" bir görünüm hedefleniyor. Apple'ın standart bileşenlerini kullanarak ama üzerine özel dokunuşlar (gradyanlar, kart yapıları, mikro etkileşimler) ekleyerek ilerlenecek.
- **Teknoloji**: SwiftUI + SwiftData.

## 📝 Çalışma Prensipleri
- **Kod Yazmadan Önce**: Her zaman "Bu gerçekten gerekli mi?" veya "Daha basit yapılabilir mi?" diye sor.
- **Gereksiz Dosyalar**: `./Teacher` gibi kopya veya atıl kalmış klasörlere asla dokunma, temizlik aşamasında silinecekler.
- **Testler**: UI testleri şu an için devre dışı/boş bırakıldı. Hızlı iterasyon için manuel test ve Unit Testlere odaklan.

## 🎯 Mevcut Durum
- Proje "Tasarım Aşaması"ndan çıkmaya çalışıyor.
- Arayüz "karman çorman" olarak nitelendiriliyor ve sadeleşmesi gerekiyor.
- Karmaşıklık azaltılmalı, dosyalar arası atlama minimuma indirilmeli.
