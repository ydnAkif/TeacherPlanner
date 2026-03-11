//
//  TeacherPlannerUITests.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import XCTest

final class TeacherPlannerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    private func launchApp(withSeedData seed: Bool = false) {
        if seed {
            app.launchArguments.append("--seed-data")
        }
        app.launch()
    }

    private func findNavigationItem(named identifier: String) -> XCUIElement {
        // 1. Try by identifier (Universal)
        let query = app.descendants(matching: .any)[identifier]
        if query.exists { return query }
        
        // 2. Try by label/title (macOS Sidebar fallback)
        // Extract title from "nav_tab_title"
        var title = identifier.replacingOccurrences(of: "nav_tab_", with: "")
        title = title.prefix(1).uppercased() + title.dropFirst()
        
        let labelQuery = app.descendants(matching: .any)[title]
        if labelQuery.exists { return labelQuery }
        
        // 3. Specific element types
        let buttonQuery = app.buttons[identifier]
        if buttonQuery.exists { return buttonQuery }
        
        let textQuery = app.staticTexts[identifier]
        if textQuery.exists { return textQuery }
        
        return query
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding

    func testOnboardingAppears() {
        launchApp(withSeedData: false)
        // --uitesting ile memory-only container → aktif dönem yok → onboarding görünmeli
        // Simulator ilk kurulumda yavaş olabilir, timeout 45s
        XCTAssertTrue(
            app.staticTexts["onboarding_welcome_text"].waitForExistence(timeout: 45),
            "İlk açılışta onboarding ekranı görünmeli"
        )
    }

    func testOnboardingFormValidation() {
        launchApp(withSeedData: false)
        XCTAssertTrue(
            app.staticTexts["onboarding_welcome_text"].waitForExistence(timeout: 45),
            "Onboarding ekranı bekleniyor"
        )

        let startButton = app.buttons["onboarding_start_button"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 15))

        // Form boşken buton disabled olmalı
        XCTAssertFalse(startButton.isEnabled, "Okul adı boşken buton disabled olmalı")

        // Okul adı gir
        let schoolNameField = app.textFields["Örn: Atatürk Ortaokulu"]
        XCTAssertTrue(schoolNameField.waitForExistence(timeout: 5))
        schoolNameField.tap()
        schoolNameField.typeText("Atatürk Ortaokulu")

        // Buton aktif olmalı (akademik yıl varsayılan dolu geliyor)
        XCTAssertTrue(startButton.isEnabled, "Okul adı girildikten sonra buton aktif olmalı")
    }

    // MARK: - Yardımcı: Onboarding'i Geç

    private func completeOnboardingIfNeeded() {
        // Eğer uygulama --seed-data ile açıldıysa zaten ana ekrandayız
        if app.launchArguments.contains("--seed-data") {
            _ = findNavigationItem(named: "nav_tab_courses").waitForExistence(timeout: 20)
            return
        }

        // Değilse (legacy support) onboarding'i UI üzerinden geçmeye çalış
        guard app.staticTexts["onboarding_welcome_text"].waitForExistence(timeout: 5) else {
            _ = findNavigationItem(named: "nav_tab_courses").waitForExistence(timeout: 20)
            return
        }
        
        // ... (legacy UI bypass logic below if needed, but we'll prefer seeding)
    }

    // MARK: - Tab Navigasyon

    func testTabBar_CoursesTabExists() {
        launchApp(withSeedData: true)
        completeOnboardingIfNeeded()

        let coursesTab = findNavigationItem(named: "nav_tab_courses")
        XCTAssertTrue(coursesTab.waitForExistence(timeout: 20), "Courses sekmesi navigasyonda olmalı")
    }

    func testTabBar_ScheduleTabExists() {
        launchApp(withSeedData: true)
        completeOnboardingIfNeeded()

        let scheduleTab = findNavigationItem(named: "nav_tab_schedule")
        XCTAssertTrue(
            scheduleTab.waitForExistence(timeout: 20), "Schedule sekmesi navigasyonda olmalı")
    }

    func testTabBar_PlannerTabExists() {
        launchApp(withSeedData: true)
        completeOnboardingIfNeeded()

        let plannerTab = findNavigationItem(named: "nav_tab_planner items")
        XCTAssertTrue(
            plannerTab.waitForExistence(timeout: 20), "Planner Items sekmesi navigasyonda olmalı")
    }

    // MARK: - Courses

    func testAddNewCourse() {
        launchApp(withSeedData: true)
        completeOnboardingIfNeeded()

        // Courses sekmesine geç
        let coursesTab = findNavigationItem(named: "nav_tab_courses")
        XCTAssertTrue(coursesTab.waitForExistence(timeout: 20))
        coursesTab.tap()

        // + butonuna bas (navigation bar'daki Add butonu)
        let addButton = app.navigationBars.buttons["Add"]
        if addButton.waitForExistence(timeout: 15) {
            addButton.tap()
        } else {
            // Boş state'deki "Ders Ekle" butonu
            let emptyAddButton = app.buttons["Ders Ekle"]
            XCTAssertTrue(emptyAddButton.waitForExistence(timeout: 15))
            emptyAddButton.tap()
        }

        // Edit form açıldı mı?
        let courseNameField = app.textFields["Ders Adı"]
        XCTAssertTrue(
            courseNameField.waitForExistence(timeout: 15), "Ders adı text field görünmeli")

        courseNameField.tap()
        courseNameField.typeText("Matematik")

        app.buttons["Kaydet"].tap()

        // Listede görünüyor mu?
        XCTAssertTrue(
            app.staticTexts["Matematik"].waitForExistence(timeout: 15),
            "Eklenen ders listede görünmeli"
        )
    }

    // MARK: - Planner Items

    func testPlannerTab_NavigationBarExists() {
        launchApp(withSeedData: true)
        completeOnboardingIfNeeded()

        let plannerTab = findNavigationItem(named: "nav_tab_planner items")
        XCTAssertTrue(plannerTab.waitForExistence(timeout: 20))
        plannerTab.tap()

        XCTAssertTrue(
            app.navigationBars["Görevler"].waitForExistence(timeout: 15),
            "Planner Items sayfasında 'Görevler' navigation bar'ı olmalı"
        )
    }

    // MARK: - Schedule

    func testScheduleTab_NavigationBarExists() {
        launchApp(withSeedData: true)
        completeOnboardingIfNeeded()

        let scheduleTab = findNavigationItem(named: "nav_tab_schedule")
        XCTAssertTrue(scheduleTab.waitForExistence(timeout: 20))
        scheduleTab.tap()

        XCTAssertTrue(
            app.navigationBars["Weekly Schedule"].waitForExistence(timeout: 15),
            "Schedule sayfasında 'Weekly Schedule' navigation bar'ı olmalı"
        )
    }
}
