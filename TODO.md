# TeacherPlanner TODO Listesi & Sprint Planı

> **Son Güncelleme:** Mart 2026  
> **Versiyon:** 0.5.0  
> **Mevcut Sprint:** Sprint 3 (Error Handling + DesignSystem)

---

## 🔴 Sprint 3: Teknik Mükemmellik (2-3 Hafta)

### Hafta 1: Error Handling + DesignSystem

#### Error Handling Standardization (P0 - Kritik)
- [x] **Try? Kullanımlarını Tespit Et**
  - [x] Proje genelinde `try?` arama ve listele
  - [x] Kritik veri kaydı işlemlerini belirle
  - [x] Error logging stratejisi belirle

- [x] **ModelContext Save İşlemleri**
  ```swift
  // ❌ Kötü
  try? modelContext.save()
  
  // ✅ İyi
  do {
      try modelContext.save()
  } catch {
      AppLogger.error(error, message: "Veri kaydedilemedi")
      appError = AppError.from(error: error)
  }
  ```
  - [x] Tüm `modelContext.save()` çağrılarını refactor et
  - [x] Error handling utility ekle

- [x] **Result<T, AppError> Pattern**
  - [x] Use case return type'larını Result'a çevir
  - [x] Error mapping fonksiyonları ekle
  - [x] ViewModel error handling standardize et

- [ ] **User-Friendly Error Messages**
  - [x] AppError case'leri için mesajlar tanımla
  - [ ] Localizable.strings dosyası oluştur
  - [x] Error alert component standardize et

#### DesignSystem Implementation (P0 - Kritik)
- [x] **DesignSystem.Colors**
  ```swift
  enum DesignSystem {
      enum Colors {
          static let primary = Color.blue
          static let secondary = Color.gray
          static let accent = Color.orange
          static let success = Color.green
          static let error = Color.red
          static let warning = Color.yellow
      }
  }
  ```
  - [x] Colors enum oluştur
  - [x] Semantic colors tanımla (Multi-platform support eklendi)
  - [x] Dark mode support ekle

- [ ] **DesignSystem.Spacing**
  ```swift
  enum Spacing {
      static let xs: CGFloat = 4
      static let sm: CGFloat = 8
      static let md: CGFloat = 12
      static let lg: CGFloat = 16
      static let xl: CGFloat = 24
      static let xxl: CGFloat = 32
  }
  ```
  - [x] Spacing enum oluştur
  - [ ] Mevcut padding/margin'leri replace et

- [ ] **DesignSystem.Typography**
  ```swift
  enum Typography {
      static let largeTitle = Font.largeTitle.weight(.bold)
      static let title = Font.title.weight(.semibold)
      static let headline = Font.headline.weight(.semibold)
      static let body = Font.body
      static let caption = Font.caption
  }
  ```
  - [ ] Typography enum oluştur
  - [ ] Font modifier'ları replace et

- [ ] **Inline Hex Codes Temizliği**
  - [x] Tüm hex codes'ları bul
  - [ ] DesignSystem.Colors'a taşı
  - [ ] Refactor et

### Hafta 2: Logger + Shared Extensions

#### Logger Implementation (P1 - Orta)
- [x] **Logger.swift**
  ```swift
  enum AppLogger {
      static func debug(_ message: String, file: String, function: String, line: Int)
      static func info(_ message: String, file: String, function: String, line: Int)
      static func warning(_ message: String, file: String, function: String, line: Int)
      static func error(_ error: Error?, message: String, file: String, function: String, line: Int)
  }
  ```
  - [x] Logger utility oluştur
  - [x] Log levels implement et
  - [x] OSLog integration (opsiyonel)
  - [x] File-based logging (opsiyonel)

- [x] **Logger Kullanımı**
  - [x] Mevcut print() çağrılarını Logger'a çevir
  - [x] Error logging standardize et
  - [x] Debug vs Release configuration

#### Shared Extensions (P1 - Orta)
- [ ] **Date+Helpers.swift**
  ```swift
  extension Date {
      var fullDateString: String
      var shortDateString: String
      var timeString: String
      func formatted(_ style: DateFormatter.Style) -> String
      func isSameDay(as date: Date) -> Bool
      func days(from date: Date) -> Int
  }
  ```
  - [x] Date extensions oluştur
  - [x] DateFormatter singleton'ları ekle
  - [x] Computed properties taşı

- [ ] **Calendar+Helpers.swift**
  ```swift
  extension Calendar {
      func isWeekend(_ date: Date) -> Bool
      func isWeekday(_ date: Date) -> Bool
      func startOfWeek(_ date: Date) -> Date
      func endOfWeek(_ date: Date) -> Date
  }
  ```
  - [x] Calendar extensions oluştur
  - [x] Week calculation helpers

- [ ] **Color+Hex.swift**
  ```swift
  extension Color {
      init(hex: String)
      var hexString: String?
  }
  ```
  - [x] Hex to Color converter
  - [x] Color to Hex converter

### Hafta 3: MEB Presets + Data

#### MEB Preset JSON (P1 - Orta)
- [ ] **JSON Schema**
  ```json
  {
    "year": "2025-2026",
    "holidays": [
      {
        "name": "Cumhuriyet Bayramı",
        "date": "2025-10-29",
        "type": "national"
      }
    ],
    "midTerms": [
      {
        "name": "Ara Tatil",
        "startDate": "2025-11-10",
        "endDate": "2025-11-17"
      }
    ]
  }
  ```
  - [ ] JSON schema tanımla
  - [ ] meb_2025_2026.json oluştur

- [ ] **JSONHolidaySource**
  ```swift
  protocol HolidaySource {
      func getHolidays(in range: DateInterval) -> [Holiday]
  }
  
  class JSONHolidaySource: HolidaySource {
      func load(from url: URL) throws -> HolidayData
      func getHolidays(in range: DateInterval) -> [Holiday]
  }
  ```
  - [ ] HolidaySource protocol
  - [ ] JSONHolidaySource implement et
  - [ ] MEBPresetProvider refactor

#### Data Migration (P2 - Düşük)
- [ ] **Versioned Schema**
  - [ ] SwiftData versioning kur
  - [ ] Migration policy oluştur
  - [ ] Test senaryoları yaz

- [ ] **Export/Import**
  - [ ] JSON export fonksiyonu
  - [ ] JSON import fonksiyonu
  - [ ] Backup/restore UI

---

## 🟡 Sprint 4: Navigation + Accessibility (3-4 Hafta)

### Hafta 4-5: Coordinator Pattern

#### Navigation Refactor (P0 - Kritik)
- [ ] **AppCoordinator**
  ```swift
  @MainActor
  @Observable
  class AppCoordinator {
      enum Route: Hashable {
          case today
          case schedule
          case courses
          case courseDetail(UUID)
          case plannerItems
          case settings
      }
      
      var path: NavigationPath
      func navigate(to route: Route)
      func goBack()
  }
  ```
  - [ ] AppCoordinator oluştur
  - [ ] Route enum tanımla
  - [ ] NavigationPath based routing

- [ ] **Deep Linking**
  - [ ] URL scheme tanımla
  - [ ] Deep link handler
  - [ ] Route mapping

- [ ] **State Restoration**
  - [ ] Navigation state save
  - [ ] App launch restore
  - [ ] Test senaryoları

### Hafta 6: Accessibility

#### VoiceOver Support (P0 - Kritik)
- [ ] **Today View**
  - [ ] Tüm butonlara accessibilityLabel
  - [ ] Complex views'e accessibilityHint
  - [ ] Dynamic value'lar için accessibilityValue

- [ ] **Schedule View**
  - [ ] Grid cells accessibility
  - [ ] Course blocks accessibility

- [ ] **All Views**
  - [ ] Decorative elements'i gizle
  - [ ] Navigation labels
  - [ ] Error messages accessibility

#### Dynamic Type (P1 - Orta)
- [ ] **Font Scaling**
  - [ ] Tüm font'lar Dynamic Type compatible yap
  - [ ] Minimum scale factor ayarla
  - [ ] Line limits ayarla

- [ ] **Layout Testing**
  - [ ] En büyük font boyutunda test
  - [ ] Layout breaking kontrol
  - [ ] ScrollView adjustments

### Hafta 7: Dark Mode + Haptics

#### Dark Mode Testing (P1 - Orta)
- [ ] **Color Assets**
  - [ ] Tüm color'ları asset'e taşı
  - [ ] Dark mode variants ekle
  - [ ] Semantic colors kullan

- [ ] **Screenshot Tests**
  - [ ] Light mode screenshots
  - [ ] Dark mode screenshots
  - [ ] Regression testing

#### Haptic Feedback (P2 - Düşük)
- [ ] **UIFeedbackGenerator**
  ```swift
  enum HapticFeedback {
      static func success()
      static func warning()
      static func error()
      static func buttonTap()
  }
  ```
  - [ ] Haptic utility oluştur
  - [ ] Button taps için haptic
  - [ ] Success/error haptics

---

## 🟢 Sprint 5: Test Coverage + CI/CD (4-6 Hafta)

### Hafta 8-9: Unit Tests

#### ViewModel Tests (P0 - Kritik)
- [ ] **TodayViewModelTests**
  - [ ] testLoadData_success
  - [ ] testLoadData_emptyState
  - [ ] testLoadData_error
  - [ ] testToggleCompleted_success
  - [ ] testToggleCompleted_error

- [x] **WeeklyScheduleViewModelTests**
  - [x] testLoadData_populatesGridView
  - [x] testDeleteSession_success
  - [x] testDeleteSession_error

- [ ] **SettingsViewModelTests**
  - [ ] testToggleNotifications
  - [ ] testRequestPermission_granted
  - [ ] testRequestPermission_denied
  - [ ] testResetData_success
  - [ ] testResetData_error

#### Use Case Tests (P0 - Kritik)
- [ ] **TodayOverviewUseCaseTests**
  - [ ] testExecute_withActiveSemester
  - [ ] testExecute_withoutSemester
  - [ ] testExecute_onNonInstructionalDay

- [ ] **PlannerTaskUseCaseTests**
  - [ ] testToggleCompleted
  - [ ] testFetchTodayItems
  - [ ] testDeleteItem

#### Repository Tests (P1 - Orta)
- [ ] **CourseRepositoryTests**
  - [ ] testGetAll
  - [ ] testGetById
  - [ ] testSave
  - [ ] testDelete

- [ ] **SemesterRepositoryTests**
  - [ ] testGetActive
  - [ ] testSetActive

### Hafta 10-11: Integration Tests

#### SwiftData Integration (P1 - Orta)
- [ ] **CRUD Operations**
  - [ ] testCreateReadUpdateDelete_Course
  - [ ] testCreateReadUpdateDelete_Semester
  - [ ] testCreateReadUpdateDelete_PlannerItem

- [ ] **Relationships**
  - [ ] testCourse_SessionsRelationship
  - [ ] testSession_PeriodRelationship

- [ ] **Predicates**
  - [ ] testFetchWithPredicate
  - [ ] testFetchWithCompoundPredicate

#### Service Integration (P1 - Orta)
- [ ] **SchoolDayEngine + NextClassCalculator**
  - [ ] testNextClass_onInstructionalDay
  - [ ] testNextClass_onWeekend

- [ ] **NotificationScheduler**
  - [ ] testScheduleNotification
  - [ ] testCancelNotification

### Hafta 12-13: UI Tests

#### Critical User Flows (P1 - Orta)
- [x] **Onboarding Flow**
  - [x] testOnboarding_createFirstSemester
  - [x] testOnboarding_setPeriods

- [x] **Today View**
  - [x] testTodayView_loadsData
  - [x] testTodayView_displaysNextClass

- [x] **Add Course Flow**
  - [x] testAddCourse_navigateFromSidebar
  - [x] testAddCourse_fillFormAndSave

- [x] **Complete Planner Item**
  - [x] testCompleteItem_toggleCompletion
  - [x] testDeleteItem_swipeToDelete

#### Accessibility Tests (P2 - Düşük)
- [ ] **VoiceOver Navigation**
  - [ ] testVoiceOver_navigateTodayView
  - [ ] testVoiceOver_activateButton

- [ ] **Dynamic Type**
  - [ ] testDynamicType_largestFont
  - [ ] testDynamicType_layoutDoesNotBreak

### Hafta 14: CI/CD

#### GitHub Actions (P0 - Kritik)
- [ ] **Build Workflow**
  ```yaml
  name: Build
  on: [push, pull_request]
  jobs:
    build-macos:
      runs-on: macos-latest
      steps:
        - uses: actions/checkout@v3
        - name: Build macOS
          run: xcodebuild -scheme TeacherPlanner -destination 'platform=macOS' build
    build-ios:
      runs-on: macos-latest
      steps:
        - uses: actions/checkout@v3
        - name: Build iOS
          run: xcodebuild -scheme TeacherPlanner -destination 'platform=iOS Simulator,name=iPhone 15' build
  ```
  - [ ] .github/workflows/build.yml oluştur
  - [ ] macOS build job
  - [ ] iOS build job

- [ ] **Test Workflow**
  ```yaml
  name: Tests
  on: [push, pull_request]
  jobs:
    test:
      runs-on: macos-latest
      steps:
        - uses: actions/checkout@v3
        - name: Run Tests
          run: xcodebuild -scheme TeacherPlanner -destination 'platform=macOS' test
  ```
  - [ ] .github/workflows/test.yml oluştur
  - [ ] Unit tests job
  - [ ] UI tests job (opsiyonel)

- [ ] **Code Coverage**
  - [ ] Coverage report generation
  - [ ] Coverage badge (README)
  - [ ] Minimum coverage threshold

- [ ] **SwiftLint**
  - [ ] .swiftlint.yml oluştur
  - [ ] Lint workflow
  - [ ] Fail on error

#### Fastlane (P2 - Düşük)
- [ ] **Build Automation**
  - [ ] Fastfile oluştur
  - [ ] build lane
  - [ ] test lane

- [ ] **Screenshot Automation**
  - [ ] snapshot configuration
  - [ ] Frame screenshots
  - [ ] Upload to App Store

---

## 📋 Genel Backlog (Öncelik Sırasına Göre)

### P0 - Kritik (Bu Sprint)
- [ ] Error handling standardization
- [ ] DesignSystem implementation
- [ ] Accessibility (VoiceOver, Dynamic Type)

### P1 - Yüksek (Sonraki Sprint)
- [ ] Logger utility
- [ ] Shared extensions
- [ ] MEB Preset JSON
- [ ] ViewModel tests
- [ ] Use case tests
- [ ] Navigation coordinator

### P2 - Orta (Gelecek Sprint)
- [ ] Repository tests
- [ ] Integration tests
- [ ] CI/CD pipeline
- [ ] Dark mode testing
- [ ] Data migration

### P3 - Düşük (İleride)
- [ ] Haptic feedback
- [ ] Snapshot tests
- [ ] UI tests (non-critical)
- [ ] Cloud sync
- [ ] Calendar integration

---

## 📊 İlerleme Takibi

### Tamamlanan Sprint'ler

#### Sprint 1 (Mart 2026) ✅
- [x] Widget implementation
- [x] DI container (AppEnvironment)
- [x] Use cases (TodayOverview, PlannerTask, Notification)
- [x] Repository pattern

#### Sprint 2 (Mart 2026) ✅
- [x] Test coverage artırma (5 test suite)
- [x] MVVM standardization (tüm ViewModels)
- [x] Performance optimization (batch fetching)

### Mevcut Sprint

#### Sprint 3 (Mart-Nisan 2026) 🔄
- [ ] Error handling standardization
- [ ] DesignSystem implementation
- [ ] Logger + Shared extensions
- [ ] MEB Preset JSON

### Planlanan Sprint'ler

#### Sprint 4 (Nisan 2026) 📋
- [ ] Navigation coordinator
- [ ] Accessibility
- [ ] Dark mode testing

#### Sprint 5 (Mayıs 2026) 📋
- [ ] Unit tests (ViewModel, UseCase, Repository)
- [ ] Integration tests
- [ ] UI tests
- [ ] CI/CD pipeline

---

## 🎯 Sprint 3 Definition of Done

Bir görevin "tamamlandı" sayılması için:
- [ ] Kod yazıldı ve commit edildi
- [ ] Unit test yazıldı (en az %80 coverage)
- [ ] Manuel test edildi (macOS + iOS)
- [ ] Code review yapıldı
- [ ] Documentation güncellendi
- [ ] ROADMAP.md'de işaretlendi

---

## 📝 Notlar

### Teknik Kararlar
- **Error Handling:** Result<T, AppError> pattern kullanılacak
- **DesignSystem:** Enum-based, static properties
- **Logger:** OSLog integration (production), print (debug)
- **Navigation:** NavigationPath + Coordinator pattern

### Bilinen Sorunlar
| ID | Sorun | Workaround | Öncelik |
|----|-------|------------|---------|
| BUG-001 | Widget stale data | Pull-to-refresh | 🟡 Orta |
| BUG-002 | Notification permission reset | Re-grant in Settings | 🟡 Orta |
| BUG-003 | Dark mode contrast | Use light mode | 🟢 Düşük |

### Açık Sorular
1. CloudKit sync için hangi strateji kullanılmalı?
2. Export formatı JSON mu, ICS mi, her ikisi mi?
3. watchOS app öncelikli mi yoksa iPad optimization mı?

---

> **Not:** Bu TODO listesi yaşayan bir dokümandır. Her sprint sonunda güncellenir ve yeni öncelikler eklenir.

*Son Güncelleme: Mart 2026*  
*Versiyon: 0.5.0*
