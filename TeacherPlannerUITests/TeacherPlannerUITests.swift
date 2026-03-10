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
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testOnboardingAppears() {
        // İlk açılışta onboarding görünmeli
        XCTAssertTrue(app.staticTexts["Hoş Geldiniz"].waitForExistence(timeout: 5))
    }

    func testOnboardingFormValidation() {
        let schoolNameField = app.textFields["Okul Adı"]
        let yearField = app.textFields["Akademik Yıl"]
        let devamButton = app.buttons["Devam"]

        // Form boşken Devam butonu disabled olmalı
        XCTAssertFalse(devamButton.isEnabled)

        // Okul adı girilince
        schoolNameField.tap()
        schoolNameField.typeText("Atatürk Ortaokulu")

        // Hala disabled (yıl boş)
        XCTAssertFalse(devamButton.isEnabled)

        // Yıl girilince
        yearField.tap()
        yearField.typeText("2025-2026")

        // Artık enabled olmalı
        XCTAssertTrue(devamButton.isEnabled)
    }
}
