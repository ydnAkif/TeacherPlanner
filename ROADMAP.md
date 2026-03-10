# 🗺️ TeacherPlanner - Kapsamlı Mimari Analiz & Yol Haritası

> **Versiyon:** 0.3.0  
> **Son Güncelleme:** Mart 2026  
> **Analiz Tipi:** Derinlemesine Mimari İnceleme

---

## 📋 İçindekiler

1. [Genel Bakış](#-genel-bakış)
2. [Boş Dosyalar Analizi](#-boş-dosyalar-analizi)
3. [Mimari Borçlar (Technical Debt)](#-mimari-borçlar-technical-debt)
4. [SOLID Prensipleri Analizi](#-solid-prensipleri-analizi)
5. [Ölçeklenebilirlik Analizi](#-ölçeklenebilirlik-analizi)
6. [Modülerlik Değerlendirmesi](#-modülerlik-değerlendirmesi)
7. [Clean Architecture Uyumu](#-clean-architecture-uyumu)
8. [Gereksiz/Düzeltilmesi Gereken Alanlar](#-gereksiz--düzeltilmesi-gereken-alanlar)
9. [Test Coverage Analizi](#-test-coverage-analizi)
10. [Performans & Optimizasyon](#-performans--optimizasyon)
11. [Güvenlik Değerlendirmesi](#-güvenlik-değerlendirmesi)
12. [Yol Haritası (Roadmap)](#-yol-haritası-roadmap)
13. [Öncelik Matrisi](#-öncelik-matrisi)

---

## 🔍 Genel Bakış

### Proje Yapısı
```
TeacherPlanner/
├── App/                    # ✅ Temiz
├── Features/               # ⚠️ Bazı iyileştirmeler gerekli
│   ├── Courses/
│   ├── Onboarding/
│   ├── Periods/
│   ├── PlannerItems/
│   ├── Schedule/
│   ├── Semester/
│   ├── Settings/
│   └── Today/
├── Models/                 # ✅ İyi yapılandırılmış
├── Persistence/            # ✅ Temiz
├── Services/               # ⚠️ Actor/Struct tutarsızlığı
│   ├── Calendar/
│   ├── Notifications/
│   ├── Schedule/
│   └── Widgets/
├── Shared/                 # ⚠️ Boş dosyalar var
│   ├── Extensions/
│   ├── Helpers/
│   └── UI/
└── Resources/

TeacherPlannerWidgets/      # ❌ Büyük ölçüde BOŞ
TeacherPlannerTests/        # ⚠️ Eksik testler
TeacherPlannerUITests/      # ⚠️ Minimal
```

### Sağlık Skoru: **68/100**

| Kategori | Skor | Durum |
|----------|------|-------|
| Kod Kalitesi | 75/100 | ⚠️ İyi |
| Mimari | 65/100 | ⚠️ Orta |
| Test Coverage | 35/100 | ❌ Düşük |
| Dokümantasyon | 60/100 | ⚠️ Orta |
| Modülerlik | 70/100 | ⚠️ İyi |
| SOLID Uyumu | 65/100 | ⚠️ Orta |

---

## 🚫 Boş Dosyalar Analizi

### Kritik Seviye (Acil Doldurulmalı)

| Dosya | Durum | Öncelik | Etki |
|-------|-------|---------|------|
| `TeacherPlannerWidgets/NextClassWidget.swift` | ❌ BOŞ | 🔴 Yüksek | Widget çalışmıyor |
| `TeacherPlannerWidgets/TodayClassesWidget.swift` | ❌ BOŞ | 🔴 Yüksek | Widget çalışmıyor |
| `TeacherPlannerWidgets/TodayPlannerItemsWidget.swift` | ❌ BOŞ | 🔴 Yüksek | Widget çalışmıyor |
| `TeacherPlannerWidgets/WeeklySnapshotWidget.swift` | ❌ BOŞ | 🔴 Yüksek | Widget çalışmıyor |
| `Services/Widgets/WidgetDataProvider.swift` | ❌ BOŞ | 🔴 Yüksek | Widget data yok |

### Orta Seviye (Geliştirme için Gerekli)

| Dosya | Durum | Öncelik | Etki |
|-------|-------|---------|------|
| `App/AppEnvironment.swift` | ❌ BOŞ | 🟡 Orta | DI container eksik |
| `Schedule/WeeklyScheduleViewModel.swift` | ❌ BOŞ | 🟡 Orta | MVVM bozuk |
| `Shared/Helpers/Constants.swift` | ❌ BOŞ | 🟡 Orta | Magic number'lar |
| `Shared/Helpers/Logger.swift` | ❌ BOŞ | 🟡 Orta | Debug zorluğu |
| `Shared/Extensions/Date+Helpers.swift` | ❌ BOŞ | 🟡 Orta | Tekrarlı kod |
| `Shared/Extensions/Calendar+Helpers.swift` | ❌ BOŞ | 🟡 Orta | Tekrarlı kod |

### Düşük Seviye (İyileştirme)

| Dosya | Durum | Öncelik | Etki |
|-------|-------|---------|------|
| `TeacherPlannerTests/WeeklyScheduleBuilderTests.swift` | ❌ BOŞ | 🟢 Düşük | Test coverage |
| `TeacherPlannerWidgets/TeacherPlannerWidgets 2.swift` | ⚠️ Duplicate? | 🟢 Düşük | Cleanup |

---

## 💳 Mimari Borçlar (Technical Debt)

### 🔴 Kritik Borçlar

#### 1. **Actor/Struct Tutarsızlığı (Services Katmanı)**
```
Sorun: SchoolDayEngine struct iken, TodayScheduleProvider ve NextClassCalculator actor.
       Bu tutarsızlık thread-safety sorunlarına yol açabilir.

Etkilenen Dosyalar:
- Services/Calendar/SchoolDayEngine.swift (struct)
- Services/Schedule/TodayScheduleProvider.swift (actor)
- Services/Schedule/NextClassCalculator.swift (actor)
- Services/Notifications/NotificationScheduler.swift (actor)

Çözüm:
- Tüm servisleri actor yapısına geçir VEYA
- @MainActor annotation kullan
- Sendable protocol'ü implement et
```

#### 2. **Widget Extension Tamamen Boş**
```
Sorun: Widget target'ı mevcut ama içerik yok.
       Xcode'da görünüyor ama çalışmıyor.

Etki: Kullanıcı deneyimi kötü, App Store red riski.

Çözüm:
- WidgetBundle oluştur
- TimelineProvider implement et
- App Groups ile data paylaşımı kur
```

#### 3. **Dependency Injection Eksikliği**
```
Sorun: Services doğrudan View/ViewModel içinde oluşturuluyor.
       Test edilebilirlik çok düşük.

Örnek (TodayViewModel.swift):
self.schoolDayEngine = SchoolDayEngine(modelContext: modelContext)
self.nextClassCalculator = NextClassCalculator(...)

Çözüm:
- Protocol-based DI
- Environment injection
- Factory pattern
```

### 🟡 Orta Seviye Borçlar

#### 4. **ViewModel Tutarsızlığı**
```
Sorun: 
- TodayView → TodayViewModel ✅
- WeeklyScheduleView → WeeklyScheduleViewModel (BOŞ!) ❌
- CourseListView → ViewModel YOK (doğrudan @Query) ⚠️
- PlannerItemListView → ViewModel YOK ⚠️

Etki: Test edilebilirlik, kod tutarlılığı

Çözüm: Tüm Feature'lar için MVVM standardize et
```

#### 5. **Error Handling Tutarsızlığı**
```
Sorun: AppError tanımlı ama kullanılmıyor.
       Çoğu yerde try? ile error yutulmuş.

Örnekler:
- try? modelContext.save() // Error kayboldu
- try? modelContext.fetch(descriptor) // Sessiz hata

Çözüm:
- Result<T, AppError> pattern
- Centralized error handling
- User-facing error messages
```

#### 6. **Navigation Karmaşıklığı**
```
Sorun: AppRoute enum var ama kullanılmıyor.
       Her View kendi NavigationStack'ini yönetiyor.

Etki: Deep linking imkansız, state restoration yok

Çözüm:
- Coordinator pattern
- NavigationPath kullan
- Router service
```

### 🟢 Düşük Seviye Borçlar

#### 7. **Magic Numbers/Strings**
```
Sorun: Hardcoded değerler dağınık

Örnekler:
- "2025-2026" (OnboardingView)
- 15 dakika reminder (NotificationManager)
- 365 gün limit (SchoolDayEngine)
- Renk hex kodları inline

Çözüm: Constants.swift doldur
```

#### 8. **Duplicate Code**
```
Sorun: DateFormatter her yerde yeniden oluşturuluyor

Örnekler:
- TodayViewModel.dateformatter
- MEBPresetProvider.dateFormatter
- PeriodDefinition computed properties

Çözüm: Shared DateFormatter utility
```

---

## 🏗️ SOLID Prensipleri Analizi

### S - Single Responsibility Principle

| Sınıf | Uyum | Sorun |
|-------|------|-------|
| `TodayViewModel` | ⚠️ 60% | Hem UI state hem business logic |
| `SchoolDayEngine` | ✅ 85% | İyi ayrılmış |
| `NotificationManager` | ✅ 80% | Tek sorumluluk |
| `MEBPresetProvider` | ⚠️ 65% | Hem preset hem holiday logic |
| `SettingsView` | ❌ 40% | UI + business + notification logic |

**İyileştirme:**
```swift
// SettingsView'dan çıkarılmalı:
// 1. NotificationPermissionManager
// 2. DataResetService  
// 3. SettingsViewModel
```

### O - Open/Closed Principle

| Alan | Uyum | Sorun |
|------|------|-------|
| `PlannerItemType` | ✅ 90% | Enum genişletilebilir |
| `HolidayProvider` | ❌ 30% | Yeni yıl = kod değişikliği |
| `WeekendRule` | ✅ 85% | Enum genişletilebilir |
| `AppError` | ✅ 85% | Yeni case'ler eklenebilir |

**İyileştirme:**
```swift
// HolidayProvider için:
protocol HolidaySource {
    func getHolidays(in range: DateInterval) -> [Holiday]
}

class JSONHolidaySource: HolidaySource { }
class APIHolidaySource: HolidaySource { }
class MEBHolidaySource: HolidaySource { }
```

### L - Liskov Substitution Principle

| Değerlendirme | Sonuç |
|---------------|-------|
| Protocol kullanımı | ⚠️ Yetersiz |
| Inheritance | ✅ Minimal (iyi) |
| Substitutability | N/A (protocol az) |

**İyileştirme:**
```swift
// Servisler için protocol tanımla
protocol ScheduleProviding {
    func todayClasses() async -> [ClassSession]
    func currentClass() async -> ClassSession?
}

protocol ClassCalculating {
    func nextClass(from: Date) async -> NextClassResult?
}
```

### I - Interface Segregation Principle

| Değerlendirme | Sonuç |
|---------------|-------|
| Fat interfaces | ⚠️ Var |
| Protocol boyutları | N/A (protocol yok) |

**Sorun:**
```swift
// TodayViewModel çok fazla iş yapıyor
// Küçük protocol'lere bölünmeli:
protocol TodayDataProviding { }
protocol TodayActionsHandling { }
protocol TodayStateManaging { }
```

### D - Dependency Inversion Principle

| Değerlendirme | Sonuç |
|---------------|-------|
| Concrete dependencies | ❌ Yaygın |
| Protocol abstraction | ❌ Eksik |
| Injection | ❌ Yok |

**Mevcut (Kötü):**
```swift
class TodayViewModel {
    private let schoolDayEngine: SchoolDayEngine // Concrete!
    
    init(modelContext: ModelContext) {
        self.schoolDayEngine = SchoolDayEngine(modelContext: modelContext)
    }
}
```

**Olması Gereken:**
```swift
protocol SchoolDayCalculating {
    func isInstructionalDay(_ date: Date, semester: Semester?) -> Bool
}

class TodayViewModel {
    private let schoolDayEngine: SchoolDayCalculating
    
    init(schoolDayEngine: SchoolDayCalculating) {
        self.schoolDayEngine = schoolDayEngine
    }
}
```

---

## 📈 Ölçeklenebilirlik Analizi

### Mevcut Durum

| Faktör | Skor | Açıklama |
|--------|------|----------|
| Veri Ölçeği | ⚠️ 60% | SwiftData tek cihaz |
| Kod Ölçeği | ✅ 75% | Feature-based yapı iyi |
| Team Ölçeği | ⚠️ 55% | Modül bağımlılıkları var |
| Platform Ölçeği | ❌ 40% | macOS desteği yarım |

### Ölçeklenebilirlik Sorunları

#### 1. **Veri Senkronizasyonu**
```
Sorun: CloudKit/iCloud desteği yok
Etki: Multi-device kullanım yok
Çözüm: 
- SwiftData + CloudKit integration
- Conflict resolution strategy
```

#### 2. **Feature Coupling**
```
Sorun: Features arası doğrudan bağımlılık

Örnek:
TodayView → TodayViewModel → SchoolDayEngine → Semester model
                          → NextClassCalculator → ClassSession model
                          → TodayScheduleProvider

Çözüm: Feature modülleri, clean interfaces
```

#### 3. **Platform Abstraction**
```
Sorun: #if os(macOS) inline kullanımı

Örnek (RootView.swift):
#if os(macOS)
    NavigationSplitView { ... }
#else
    TabView { ... }
#endif

Çözüm: Platform-specific modules
```

### Önerilen Mimari Evrim

```
Şuanki: Monolithic App
    ↓
Kısa Vadeli: Feature Modules
    ↓
Orta Vadeli: Clean Architecture Layers
    ↓
Uzun Vadeli: Multi-Module SPM Packages
```

---

## 🧩 Modülerlik Değerlendirmesi

### Mevcut Modül Yapısı

```
┌─────────────────────────────────────────────────┐
│                    App                           │
├─────────────────────────────────────────────────┤
│  Features    │  Services   │  Shared            │
│  ┌─────────┐ │ ┌─────────┐ │ ┌────────────────┐ │
│  │ Today   │←┼→│Calendar │←┼→│ Extensions     │ │
│  │ Schedule│←┼→│Schedule │←┼→│ Helpers        │ │
│  │ Courses │ │ │Notif.   │ │ │ UI Components  │ │
│  │ Planner │ │ │Widgets  │ │ └────────────────┘ │
│  │ Semester│ │ └─────────┘ │                    │
│  │ Settings│ │             │                    │
│  └─────────┘ │             │                    │
├─────────────────────────────────────────────────┤
│              Models (SwiftData)                  │
├─────────────────────────────────────────────────┤
│              Persistence                         │
└─────────────────────────────────────────────────┘
```

### Bağımlılık Sorunları

```
❌ Döngüsel Bağımlılık Riski:
Features → Services → Models → Features (dolaylı)

❌ God Object Riski:
ModelContext her yerde inject ediliyor

❌ Feature Bleeding:
SemesterSettingsView → PeriodListView (cross-feature navigation)
```

### Önerilen Modül Yapısı

```
TeacherPlannerCore (SPM Package)
├── Models/
├── Protocols/
└── Utilities/

TeacherPlannerServices (SPM Package)
├── CalendarService/
├── NotificationService/
└── ScheduleService/

TeacherPlannerUI (SPM Package)
├── DesignSystem/
├── Components/
└── Themes/

TeacherPlannerFeatures (SPM Package)
├── TodayFeature/
├── ScheduleFeature/
├── CourseFeature/
├── PlannerFeature/
└── SettingsFeature/

TeacherPlannerApp (Main Target)
├── AppDelegate/
├── DI Container/
└── Coordinators/

TeacherPlannerWidgets (Extension)
└── Widgets/
```

---

## 🏛️ Clean Architecture Uyumu

### Mevcut Katman Analizi

```
┌──────────────────────────────────────┐
│         Presentation Layer           │  ← Views, ViewModels
│         (SwiftUI Views)              │     ✅ Var
├──────────────────────────────────────┤
│          Domain Layer                │  ← Use Cases, Entities
│     (Business Logic)                 │     ⚠️ Kısmen var
├──────────────────────────────────────┤
│           Data Layer                 │  ← Repositories, Data Sources
│      (SwiftData, Network)            │     ❌ Karışık
└──────────────────────────────────────┘
```

### Eksik Bileşenler

#### 1. **Use Cases (Eksik)**
```swift
// Olması gereken:
protocol GetTodayClassesUseCase {
    func execute() async -> Result<[ClassSession], AppError>
}

protocol TogglePlannerItemUseCase {
    func execute(itemId: UUID) async -> Result<Void, AppError>
}

protocol ScheduleNotificationUseCase {
    func execute(for date: Date) async -> Result<Void, AppError>
}
```

#### 2. **Repository Pattern (Eksik)**
```swift
// Olması gereken:
protocol CourseRepository {
    func getAll() async -> [Course]
    func getById(_ id: UUID) async -> Course?
    func save(_ course: Course) async throws
    func delete(_ course: Course) async throws
}

protocol SemesterRepository {
    func getActive() async -> Semester?
    func setActive(_ semester: Semester) async throws
}
```

#### 3. **Data Sources (Karışık)**
```swift
// Şuanki: ModelContext doğrudan kullanım
// Olması gereken:
protocol LocalDataSource {
    associatedtype Entity
    func fetch(predicate: Predicate<Entity>?) async throws -> [Entity]
    func save(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
}
```

### Clean Architecture Geçiş Planı

```
Phase 1: Protocol Extraction
- Mevcut servislere protocol ekle
- Repository interface'leri tanımla

Phase 2: Use Case Layer
- Feature başına use case'ler
- Input/Output modelleri

Phase 3: Data Layer Refactor  
- Repository implementations
- Data source abstraction

Phase 4: DI Container
- Swinject veya manual DI
- Environment-based injection
```

---

## 🗑️ Gereksiz / Düzeltilmesi Gereken Alanlar

### Silinmesi Gerekenler

| Dosya/Kod | Sebep | Aksiyon |
|-----------|-------|---------|
| `TeacherPlannerWidgets 2.swift` | Duplicate dosya | 🗑️ Sil |
| Boş comment blokları | Gereksiz noise | 🗑️ Temizle |
| Unused imports | Dead code | 🗑️ Kaldır |

### Birleştirilmesi Gerekenler

| Parçalar | Hedef | Sebep |
|----------|-------|-------|
| `HolidayProvider` + `MEBPresetProvider` holidays | `HolidayService` | DRY |
| DateFormatter instances | `DateFormatting` utility | DRY |
| Color hex arrays | `DesignSystem.Colors` | Single source of truth |

### Refactor Edilmesi Gerekenler

| Alan | Sorun | Çözüm |
|------|-------|-------|
| `SettingsView` | Fat View | MVVM + extract services |
| `TodayViewModel` | God object riski | Split responsibilities |
| `EditCourseView` | Inline pickers | Extract to separate views |
| `PlannerItemListView` | Complex filtering | Extract FilterViewModel |

### Dead Code Analizi

```swift
// NavigationExtensions.swift - AppRoute kullanılmıyor
enum AppRoute: Hashable {
    case today
    case schedule
    // ... hiçbir yerde kullanılmıyor!
}

// hideBackButton() extension - kullanım yok
extension View {
    func hideBackButton() -> some View { ... }
}
```

---

## 🧪 Test Coverage Analizi

### Mevcut Durum

| Modül | Test Dosyası | Coverage | Durum |
|-------|--------------|----------|-------|
| SchoolDayEngine | ✅ Var | ~40% | ⚠️ Eksik senaryolar |
| NextClassCalculator | ✅ Var | ~30% | ⚠️ Eksik senaryolar |
| WeeklyScheduleBuilder | ❌ Boş | 0% | ❌ Kritik |
| NotificationManager | ❌ Yok | 0% | ❌ Kritik |
| TodayViewModel | ❌ Yok | 0% | ❌ Kritik |
| Models | ❌ Yok | 0% | ⚠️ Orta |
| UI Components | ❌ Yok | 0% | 🟢 Düşük öncelik |

### Eksik Test Senaryoları

```swift
// SchoolDayEngineTests - Eksik:
- testIsInstructionalDay_WithSkippedDay()
- testIsInstructionalDay_OnSemesterBoundary()
- testGetInstructionalDays_CrossingYearBoundary()
- testNextInstructionalDay_NoMoreDaysInSemester()

// NextClassCalculatorTests - Eksik:
- testNextClass_AfterLastClassOfDay()
- testNextClass_NoClassesThisWeek()
- testNextClass_SemesterEnded()
```

### UI Test Durumu

```swift
// Mevcut UI testleri:
- testOnboardingAppears() ✅
- testOnboardingFormValidation() ✅ (ama çalışmıyor olabilir)

// Eksik UI testleri:
- testTodayViewLoadsCorrectly()
- testScheduleGridNavigation()
- testCourseCreationFlow()
- testPlannerItemCompletion()
- testSettingsNavigation()
```

### Test Stratejisi Önerisi

```
Unit Tests (Hedef: 80%)
├── Models (validation, computed properties)
├── Services (business logic)
├── ViewModels (state management)
└── Utilities (extensions, helpers)

Integration Tests (Hedef: 60%)
├── SwiftData operations
├── Service combinations
└── Data flow scenarios

UI Tests (Hedef: 40%)
├── Critical user flows
├── Accessibility
└── Screenshot tests

Snapshot Tests (Hedef: 50%)
├── UI components
├── Dark/Light mode
└── Dynamic type
```

---

## ⚡ Performans & Optimizasyon

### Tespit Edilen Sorunlar

#### 1. **Aşırı Fetch İşlemleri**
```swift
// WeeklyScheduleBuilder - Her cell için ayrı fetch
private func sessionForWeekday(_ weekday: Int, periodOrder: Int) -> ClassSession? {
    let descriptor = FetchDescriptor<ClassSession>(
        predicate: #Predicate { $0.weekday == weekday && $0.periodOrder == periodOrder }
    )
    return (try? modelContext.fetch(descriptor))?.first  // N+1 problemi!
}

// Çözüm: Batch fetch
func buildWeeklyView() -> WeeklyViewData {
    let allSessions = try? modelContext.fetch(FetchDescriptor<ClassSession>())
    let sessionsDict = Dictionary(grouping: allSessions ?? []) { 
        ScheduleCellKey(weekday: $0.weekday, periodOrder: $0.periodOrder) 
    }
    // Tek fetch ile tüm veriyi al
}
```

#### 2. **DateFormatter Overhead**
```swift
// Her property access'te yeni formatter
var startTimeString: String {
    let formatter = DateFormatter()  // Her seferinde yeni!
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: startTime)
}

// Çözüm: Static/Shared formatter
private static let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f
}()
```

#### 3. **Memory Leaks Riski**
```swift
// TodayView - State'te ViewModel tutma
@State private var viewModel: TodayViewModel?  // Reference type in @State

// Çözüm: @StateObject kullan
@StateObject private var viewModel = TodayViewModel()
```

### Optimizasyon Önerileri

| Alan | Mevcut | Önerilen | Kazanç |
|------|--------|----------|--------|
| Batch fetching | Yok | Implement | ~60% faster |
| Lazy loading | Kısmi | Full lazy | Memory ↓ |
| Caching | Yok | NSCache | ~40% faster |
| Background fetch | Yok | Actor-based | UI smooth |

---

## 🔒 Güvenlik Değerlendirmesi

### Mevcut Durum

| Alan | Durum | Açıklama |
|------|-------|----------|
| Data at Rest | ✅ OK | SwiftData encrypted |
| Sensitive Data | ✅ OK | Hassas veri yok |
| API Keys | N/A | External API yok |
| User Auth | N/A | Gerekli değil |
| Input Validation | ⚠️ Kısmi | Form validation eksik |

### Potansiyel Riskler

```
1. Widget Data Sharing
   - App Groups ile veri paylaşımı güvenli mi?
   - Çözüm: Keychain veya encrypted container

2. Notification Content
   - Ders bilgileri notification'da görünür
   - Çözüm: NotificationServiceExtension ile kontrol

3. Export/Backup
   - Veri export özelliği yok (gelecekte?)
   - Çözüm: Encrypted export format
```

---

## 🛣️ Yol Haritası (Roadmap)

### 📅 Faz 0: Acil Düzeltmeler (1-2 Hafta)

> **Hedef:** Uygulamayı çalışır duruma getirmek

#### Hafta 1
- [x] **Widget Implementation** 🔴
  - [x] WidgetBundle oluştur
  - [x] NextClassWidget implement et
  - [x] TodayClassesWidget implement et
  - [x] App Groups konfigürasyonu

- [x] **Boş Dosyaları Doldur** 🔴
  - [x] WidgetDataProvider.swift
  - [x] WeeklyScheduleViewModel.swift
  - [x] Constants.swift
  - [x] Logger.swift

#### Hafta 2
- [x] **Kritik Bug Fixes**
  - [x] @State → @StateObject migration
  - [x] Error handling standardization
  - [x] Memory leak fixes

---

### 📅 Faz 1: Temel İyileştirmeler (2-4 Hafta)

> **Hedef:** Kod kalitesini artırmak

#### Hafta 3-4
- [x] **MVVM Standardization**
  - [x] CourseListViewModel oluştur
  - [x] PlannerItemListViewModel oluştur
  - [x] SettingsViewModel oluştur
  - [x] WeeklyScheduleViewModel doldur

- [x] **Service Layer Refactor**
  - [x] Actor/Struct tutarlılığı
  - [x] Protocol extraction
  - [x] Error handling standardization

#### Hafta 5-6
- [x] **Test Coverage Artırma**
  - [x] Unit test coverage artırıldı (5 → 22 test)
  - [x] WeeklyScheduleBuilderTests
  - [x] SchoolDayEngine + NextClassCalculator edge cases
  - [x] PlannerItemTests (model testleri)

- [ ] **Code Quality**
  - [ ] SwiftLint integration
  - [ ] Dead code removal
  - [ ] Documentation comments

---

### 📅 Faz 2: Mimari İyileştirmeler (4-6 Hafta)

> **Hedef:** Clean Architecture'a yaklaşmak

#### Hafta 7-8
- [x] **Protocol-Based DI**
  - [x] Service protocols tanımla (`ServiceProtocols.swift`)
  - [x] `AppEnvironment` tam DI container'a dönüştürüldü
  - [ ] Repository pattern implement et
  - [ ] Factory pattern for ViewModels

- [ ] **Use Case Layer**
  - [ ] Core use cases tanımla
  - [ ] Input/Output models
  - [ ] Use case tests

#### Hafta 9-10
- [ ] **Modularization Prep**
  - [ ] Feature boundaries tanımla
  - [ ] Shared module extract et
  - [ ] Core module extract et

- [ ] **Navigation Refactor**
  - [ ] Coordinator pattern
  - [ ] Deep linking support
  - [ ] State restoration

#### Hafta 11-12
- [x] **Performance Optimization**
  - [x] Batch fetching (`WeeklyScheduleBuilder` N+1 fix)
  - [ ] Caching layer
  - [ ] Background processing

---

### 📅 Faz 3: Yeni Özellikler (6-10 Hafta)

> **Hedef:** Değer katan özellikler eklemek

#### Hafta 13-16
- [ ] **Cloud Sync**
  - [ ] iCloud/CloudKit integration
  - [ ] Conflict resolution
  - [ ] Offline support

- [ ] **Advanced Widgets**
  - [ ] Interactive widgets
  - [ ] Lock screen widgets
  - [ ] StandBy support

#### Hafta 17-20
- [ ] **Data Management**
  - [ ] Import/Export
  - [ ] Backup/Restore
  - [ ] Data migration tools

- [ ] **Collaboration Features**
  - [ ] Share schedule
  - [ ] Calendar integration
  - [ ] Siri shortcuts

#### Hafta 21-24
- [ ] **Analytics & Insights**
  - [ ] Teaching statistics
  - [ ] Time tracking
  - [ ] Reports generation

---

### 📅 Faz 4: Platform Genişleme (10+ Hafta)

> **Hedef:** Multi-platform desteği

- [ ] **macOS Native**
  - [ ] Menu bar app
  - [ ] Keyboard shortcuts
  - [ ] Native macOS UI

- [ ] **iPad Optimization**
  - [ ] Split view support
  - [ ] Apple Pencil integration
  - [ ] Stage Manager support

- [ ] **watchOS App**
  - [ ] Complications
  - [ ] Quick actions
  - [ ] Haptic reminders

- [ ] **visionOS** (Gelecek)
  - [ ] Spatial UI adaptation
  - [ ] Immersive schedule view

---

## 📊 Öncelik Matrisi

```
                    IMPACT
           Low    Medium    High
         ┌────────┬────────┬────────┐
    Low  │        │ Dead   │ MVVM   │
         │        │ Code   │ Std.   │
         ├────────┼────────┼────────┤
  EFFORT │ Const- │ Tests  │ DI     │
  Medium │ ants   │        │ Setup  │
         ├────────┼────────┼────────┤
    High │        │ Clean  │ Widget │
         │        │ Arch   │ Impl.  │
         └────────┴────────┴────────┘
```

### Öncelik Sıralaması

| # | İş | Effort | Impact | Öncelik |
|---|-------|--------|--------|---------|
| 1 | Widget Implementation | High | High | 🔴 P0 |
| 2 | Boş Dosyaları Doldur | Low | High | 🔴 P0 |
| 3 | MVVM Standardization | Medium | High | 🟡 P1 |
| 4 | Test Coverage | Medium | Medium | 🟡 P1 |
| 5 | Error Handling | Low | Medium | 🟡 P1 |
| 6 | DI Setup | Medium | High | 🟢 P2 |
| 7 | Clean Architecture | High | Medium | 🟢 P2 |
| 8 | Cloud Sync | High | High | 🔵 P3 |

---

## ✅ Kontrol Listesi

### Kod Kalitesi
- [ ] Tüm boş dosyalar dolduruldu
- [ ] SwiftLint entegre edildi
- [ ] Dead code temizlendi
- [ ] Documentation eklendi

### Mimari
- [ ] MVVM tutarlı uygulandı
- [ ] Protocol-based DI kuruldu
- [ ] Use case layer eklendi
- [ ] Repository pattern uygulandı

### Test
- [ ] Unit test coverage > 70%
- [ ] Integration tests yazıldı
- [ ] UI test kritik flowlar
- [ ] Performance test baseline

### CI/CD
- [ ] GitHub Actions kuruldu
- [ ] Automated testing
- [ ] Code coverage tracking
- [ ] Release automation

---

## 📝 Notlar

### Karar Kayıtları

| Tarih | Karar | Sebep |
|-------|-------|-------|
| - | SwiftData kullanımı | Modern, Apple native |
| - | Feature-based structure | Ölçeklenebilirlik |
| - | Actor-based services | Thread safety |

### Teknik Borç Takibi

Toplam Tahmini Borç: **~120 saat**

| Kategori | Saat | Yüzde |
|----------|------|-------|
| Widget | 24h | 20% |
| Testing | 32h | 27% |
| Refactoring | 40h | 33% |
| Documentation | 24h | 20% |

---

> **Son Söz:** Bu roadmap yaşayan bir dokümandır. Her sprint sonunda gözden geçirilmeli ve güncellenmelidir. Öncelikler değişebilir, yeni teknik borçlar ortaya çıkabilir. Önemli olan sürekli iyileştirme kültürünü korumaktır.

---

*Hazırlayan: Senior Architecture Review*  
*Tarih: Mart 2026*