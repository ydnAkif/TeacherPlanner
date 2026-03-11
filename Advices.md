# TeacherPlanner — Uzman Analizi & Tavsiyeler

> **Bakış açısı:** 30 yıllık deneyimli bir iOS mühendisi gözüyle. Pohpohlama yok, gerçekler var.

---

## 1. MİMARİ: Ölçeğini Aşan Soyutlama

### 1.1 Repository Pattern — Gereksiz mi?

`CourseRepository`, `SemesterRepository`, `PlannerRepository` adında 3 repository var. Bunlar SwiftData'nın `ModelContext`'ini sarmalıyor. Oysa `@Query` ve `ModelContext` **zaten** bu işi yapıyor. Apple, SwiftData'yı tam da repository layer gerekmeden kullanılsın diye tasarladı.

**Sorun:** `PlannerRepository.fetchTodayItems()` → `ModelContext.fetch()` çağrısı. Bu `protocol PlannerRepositoryProtocol` + `class PlannerRepository` çifti 80 satır kod, sıfır ek değer.

**Öneri:** Repository'leri tamamen kaldır. ViewModel'lerde doğrudan `@Query` ve `modelContext.insert/delete/save` kullan. Unit test gerekirse `SwiftData`'nın `inMemory` modunu kullan.

### 1.2 Protocol Proliferation (Protokol Çoğalması)

`SchoolDayCalculating`, `NextClassProviding`, `TodayScheduleProviding`, `WeeklyScheduleBuilding`, `NotificationScheduling`, `PlannerRepositoryProtocol`, `CourseRepositoryProtocol`, `SemesterRepositoryProtocol` — **8 protokol**, hepsi tek bir concrete class ile eşleşiyor.

Bu protokoller şu an için hiçbir fayda sağlamıyor:
- Test double yok (UI testler devre dışı)
- Birden fazla implementasyon yok
- DI container (`AppEnvironment`) protokol bağımlılıklarını zaten concrete class olarak başlatıyor

**Öneri:** `SchoolDayEngine`, `NextClassCalculator` gibi core hesaplama sınıflarında protokolü tut (bunlar unit test edilebilir). Geri kalanları kaldır.

### 1.3 Lazy Setup Anti-Pattern

Her ViewModel `init()` + `setup()` ikili kombinasyonunu kullanıyor:

```swift
init() {}
func setup(schoolDayEngine: ..., nextClassCalculator: ..., ...) async { ... }
```

Bu, SwiftUI'ın `@StateObject` ile çakışan bir pattern. `setup()` çağrılmazsa ViewModel boş kalıyor, çağrılırsa de-facto `init` oluyor. `isInitialized` guard'ı bu kırık tasarımın belirtisi.

**Asıl sorun:** SwiftData modeli ile ViewModel'i doğrudan bağlamak. SwiftUI'da doğru yaklaşım `@Query` ile View'da verileri çekmek, ViewModel'i sadece aksiyonlar için kullanmak.

**Öneri:** Today ve Schedule için ViewModel'i ya tamamen kaldır (`View` + `@Query`), ya da `@Environment` değerini `init`'e al ve `setup()` pattern'ını sil.

---

## 2. DATA MODELİ: İyi ama Eksikler Var

### 2.1 `PlannerItem.priority` Int — Kötü Seçim

```swift
var priority: Int  // 1-3 arası (1: yüksek, 2: orta, 3: düşük)
```

Bu yorumu **sadece comment'te** tutuluyor. Kod hiçbir yerde bu sınırı doğrulamıyor. `priority = 99` geçerli bir değer. Bunun yerine:

```swift
enum Priority: Int, Codable { case high = 1, medium = 2, low = 3 }
var priority: Priority
```

### 2.2 `ClassSession.period` — Optional ama Olmadan Anlamsız

`ClassSession`, `period: PeriodDefinition?` ilişkisine sahip. Ama period olmadan bir ders seansının anlamı yok. Bu optional, kodun her yerinde `guard let period = session.period` guard'ı zorunlu kılıyor. `compactMap` palyatif.

**Öneri:** `period`'u non-optional yap. Veri bütünlüğünü veri katmanında tanımla, guard'larla kodun içine yayma.

### 2.3 `Course.colorHex` String — Fragile

Renk `"#007AFF"` gibi bir String olarak saklanıyor. `Color(hex:)` extension gerekiyor, her erişimde parse ediliyor. SwiftData `Transformable` veya `RawRepresentable` enum kullanılabilir. Alternatif olarak en az kötü çözüm basit int (RGB) saklamak.

### 2.4 `Semester` — Birden Fazla Aktif Dönem Mümkün

`isActive: Bool` çakışmasını önleyen hiçbir şey yok. `getActiveSemester()` sadece `first` döndürüyor. İki dönem aktif olursa uygulama rastgele birini alır.

**Öneri:** `isActive` yerine ayrı bir `currentSemesterID: UUID?` UserDefaults değeri kullan. Ya da fetch sırasında `sortBy: [SortDescriptor(\.startDate, order: .reverse)]` ekle ve yalnızca ilkini aldığını belgele.

---

## 3. SERVİSLER: Gerçek Değer Burada

Bu bölüm projenin en güçlü kısmı:

- `SchoolDayEngine` — temiz, test edilebilir, mantığı yerinde
- `NextClassCalculator` — karmaşık ama doğru düşünülmüş (N+1 sorunsuz)
- `WeeklyScheduleBuilder` — in-memory grid optimizasyonu güzel

### 3.1 `NextClassCalculator` — `class` Neden?

```swift
class NextClassCalculator: NextClassProviding {
```

Diğer service'ler `final class`. Bu `class` açık-kapalı. Miras alınsın diye mi bırakıldı? Hayır. `final` ekle.

### 3.2 `SchoolDayEngine` — `weekendRule` init parametresi anlamsız

```swift
init(modelContext: ModelContext, weekendRule: WeekendRule = .saturdaySunday) {
```

Ama `isInstructionalDay` içinde `semester.weekendRule` kullanılıyor, `self.weekendRule` değil. Yani init'teki parametre hiç kullanılmıyor. Bu bir bug veya dead code.

### 3.3 `NotificationScheduler` — Duplicate Fetch Logic

`scheduleTodayNotifications()` ve `scheduleWeekNotifications()` içinde birebir aynı `FetchDescriptor<ClassSession>` kodu iki kez yazılmış. `classesForWeekday(_ weekday: Int)` gibi private yardımcı metoda çıkartılmalı.

---

## 4. ARAYÜZ: Potansiyel Var, Gerçekleşmemiş

### 4.1 Today Ekranı — Vizyon Var, Polishing Yok

`NextClassCard` bir öğretmenin en çok baktığı yer. Şu an:
- `Color.gray.opacity(0.5)` arka plan — ham, tasarımsız
- Kalan süre (dk/saat) şeffaf metinle küçük — en kritik bilgi en az görünür yerde
- Ders rengi büyük `Circle` — iyi ama 48pt icon ile daraltılmış

Bu kart, kullanıcının her sabah ilk baktığı şey olmalı. Şu anki hali Notion'ın 2017 tasarımına benziyor.

### 4.2 30+ Yerde `.cornerRadius()` — Deprecated

SwiftUI'da `.cornerRadius()` modifier iOS 16'dan itibaren deprecated. `.clipShape(RoundedRectangle(cornerRadius:))` kullanılmalı. 30+ kullanım var; teknik borç birikmiş.

### 4.3 TabBar — 6 Tab Çok Fazla

iPhone genişliği için **5 tab maksimum**'dur. 6 tab olduğundan "Planner Items" ibaresi zaten TabBar'da kesiliveriyor. Bugün iPhone 16 Pro'da bile 6 tab sığdırmak zorlaşıyor.

**Mevcut 6 tab:**
1. Today
2. Schedule (Haftalık Program)
3. Courses (Dersler)
4. Planner Items (Görevler)
5. Semester (Dönem)
6. Settings

**Öneri — 4 tab:**
1. **Today** (bugünkü dersler + görevler birleşik)
2. **Schedule** (haftalık program)
3. **Courses** (dersler + görevler alt sekme)
4. **Settings** (dönem + bildirim + görünüm)

Semester yönetimi Settings altına gömülebilir. Planner Items Courses'un alt sekmesi olabilir.

### 4.4 Navigasyon Dili — Karışık

`AppRouter.Tab.today.title = "Today"` — İngilizce.
`SettingsView.navigationTitle = "Ayarlar"` — Türkçe.
`WeeklyScheduleView.navigationTitle = "Weekly Schedule"` — İngilizce.

Tek bir dilde yaz. Hedef kitle Türk öğretmenler → **tamamen Türkçe**.

### 4.5 `RootView` — macOS Kodu iOS Uygulamasında

```swift
#if os(macOS)
    NavigationSplitView { ... }
#else
    TabView { ... }
#endif
```

`.agent/rules.md` dosyası "Sadece iOS" diyor. Bu `#if os(macOS)` bloku (yaklaşık 15 satır) dead code. Sil, proje temizlenir.

### 4.6 EmptyStateView — Generic ama Bağlamdan Kopuk

Tüm ekranlarda aynı `EmptyStateView` kullanılıyor. Bu iyi. Ama görseli yok — sadece SF Symbol. Bir öğretmenin boş program ekranı için "henüz ders yok, hadi ekle" mesajı SF Symbol'den çok daha motive edici bir illüstrasyon hak ediyor.

---

## 5. CONSTANTS: Widget Mirası Temizlenmedi

```swift
enum Constants {
    static let appGroupIdentifier = "group.com.ydnakif.TeacherPlanner.shared"
    ...
}
```

`appGroupIdentifier` — Widget Extension kaldırıldı. Bu App Group artık kullanılmıyor. Kalmaya devam ediyor çünkü kimse silmedi.

Aynı şekilde `TeacherPlanner.entitlements` dosyasındaki App Group kaydı da temizlenmeli.

---

## 6. HATA YÖNETİMİ: İyi Başlamış, Yarım Kalmış

`AppError` enum'u iyi tasarlanmış. `ModelContext+AppError` extension'ı `saveResult` / `fetchResult` Pattern'ı elegant.

**Sorun:** `AppError.networkUnavailable`, `requestFailed`, `timeout` case'leri mevcut. Bu bir **offline-first** uygulama — network hiç kullanılmıyor. Bu case'ler dead code.

---

## 7. TEST DURUMU: Dikkat Çeken Boşluk

Unit testler güzel: `SchoolDayEngineTests`, `NextClassCalculatorTests`, `WeeklyScheduleBuilderTests` var.

**Kritik eksik:** `PlannerRepository` test edilmiyor. `fetchTodayItems()` predicate logic'i (bugün başlangıcı / bitiş) test gerektiriyor — zaman dilimleri (timezone), gece yarısı sınırları vs. bug'a açık.

---

## 8. ONBOARDING: Sabit Tarihler — Tehlike

```swift
if semesterType == .guz {
    startDate = calendar.date(from: DateComponents(year: year, month: 9, day: 8)) ?? Date()
    endDate = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 23)) ?? Date()
```

MEB takvimi her yıl değişir. Güz dönemi Eylül 8'de başlamıyor (2026'da farklı olabilir). Bu sabit tarihler gerçek veriye uymadığında kullanıcı fark etmeyebilir, ama dönem hesaplamaları hatalı çalışır.

**Öneri:** Tarihleri sabitlemek yerine kullanıcıya DatePicker sun. MEBPreset'i "tahmini başlangıç noktası" olarak sun, onay iste.

---

## 9. PERFORMANS: Küçük ama Gerçek Sorunlar

### 9.1 `SchoolDayEngine.getActiveSemester()` — Her Seferinde Fetch

`TodayViewModel.loadData()` içinde `engine.getActiveSemester()` çağrılıyor. Bu her refresh'te bir `ModelContext.fetch()` anlamına geliyor. Semester nadiren değişir.

**Öneri:** `AppEnvironment`'ta `@Published var activeSemester: Semester?` tut, semester değiştiğinde güncelle.

### 9.2 `WeeklyScheduleBuilder.buildWeeklyView()` — `allPeriods()` + `buildWeeklyGrid()` = 2 Fetch

```swift
func buildWeeklyView() -> WeeklyViewData {
    let periods = allPeriods()       // fetch #1
    let allSessions = buildWeeklyGrid() // fetch #2 (sessions)
```

Tek metodda iki ayrı fetch. Sequence açısından sorun yok ama birleştirilebilir.

---

## 10. ÖNCELİKLİ AKSİYON LİSTESİ

Sırasıyla yapılması gereken işler:

| # | Aksiyon | Etki | Zorluk |
|---|---------|------|--------|
| 1 | macOS `#if` bloklarını sil | Kod temizliği | Kolay |
| 2 | Widget kalıntılarını (`appGroupIdentifier`, entitlements) temizle | Temizlik | Kolay |
| 3 | `.cornerRadius()` → `.clipShape(RoundedRectangle(cornerRadius:))` | Uyumluluk | Orta |
| 4 | `PlannerItem.priority` → enum'a çevir | Doğruluk | Orta |
| 5 | TabBar'ı 6'dan 4'e indir | UX | Zor |
| 6 | `Today` ekranı → premium kart tasarımı | Etki | Zor |
| 7 | Navigasyon dilini tamamen Türkçe yap | Tutarlılık | Kolay |
| 8 | Repository pattern'ını kaldır (sadece `@Query` + `modelContext`) | Sadeleşme | Zor |
| 9 | Onboarding'deki sabit tarihleri → DatePicker yap | Doğruluk | Orta |
| 10 | `SchoolDayEngine.weekendRule` init parametresini temizle (bug) | Düzeltme | Kolay |

---

## GENEL SONUÇ

Bu proje, **birisi kod yazmayı biliyor ama neyin ne zaman gerekli olduğunu henüz oturtuyor**.

İyi olanlar: SwiftData kullanımı sağlam, `ModelContext+AppError` extension'ı akıllıca, `SchoolDayEngine` test edilebilir ve mantıklı.

Endişe verenler: Protokol soyutlamaları gerçek bir problemi çözmüyor; ölçeğin gerektirdiğinden 2 katman fazla var; UI henüz "görüyorum ama hissetmiyorum" fazında; 6 tab bir akıl sağlığı sorunu.

**Tek cümle:** Mimariyi daha da sadeleştir (repository'ler dahil), sonra tüm enerjiyi `Today` ve `Schedule` ekranlarının premier hissettirmesine harca.
