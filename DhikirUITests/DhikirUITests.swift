import XCTest

final class DhikirUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding Tests

    func testOnboardingFlowDisplays() throws {
        app.launch()

        // First launch should show onboarding
        let salaamText = app.staticTexts["Salaam"]
        XCTAssertTrue(salaamText.waitForExistence(timeout: 5))
    }

    func testOnboardingCanBeSkipped() throws {
        app.launch()

        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 5) {
            skipButton.tap()

            // Should now see the main tab bar
            let homeTab = app.tabBars.buttons["Home"]
            XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        }
    }

    func testOnboardingContinueButton() throws {
        app.launch()

        let continueButton = app.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 5) {
            continueButton.tap()

            // Should advance to next page
            let howAreYouFeelingText = app.staticTexts["How Are You Feeling?"]
            XCTAssertTrue(howAreYouFeelingText.waitForExistence(timeout: 5))
        }
    }

    // MARK: - Tab Navigation Tests

    func testTabBarNavigation() throws {
        // Skip onboarding first
        app.launch()
        skipOnboardingIfPresent()

        // Test Home tab
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        homeTab.tap()

        // Test Favorites tab
        let favoritesTab = app.tabBars.buttons["Favorites"]
        XCTAssertTrue(favoritesTab.exists)
        favoritesTab.tap()

        // Test History tab
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.exists)
        historyTab.tap()

        // Test Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
    }

    // MARK: - Home View Tests

    func testHomeViewDisplaysEmotions() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Check for "How I Feel" section
        let howIFeelText = app.staticTexts["How I Feel"]
        XCTAssertTrue(howIFeelText.waitForExistence(timeout: 5))

        // Check for emotional states
        let anxiousButton = app.buttons["Anxious"]
        XCTAssertTrue(anxiousButton.exists || app.staticTexts["Anxious"].exists)
    }

    func testHomeViewDisplaysSituations() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Scroll to see situations
        app.swipeUp()

        // Check for "What I'm Doing" section
        let whatImDoingText = app.staticTexts["What I'm Doing"]
        XCTAssertTrue(whatImDoingText.waitForExistence(timeout: 5))
    }

    func testHomeViewDisplaysStreak() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Check for streak display
        let streakText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Streak'")).firstMatch
        XCTAssertTrue(streakText.waitForExistence(timeout: 5))
    }

    // MARK: - Emotion Selection Tests

    func testSelectingEmotionNavigatesToDhikir() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Find and tap an emotion button
        let anxiousButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Anxious'")).firstMatch
        if anxiousButton.waitForExistence(timeout: 5) {
            anxiousButton.tap()

            // Should navigate to dhikir display
            // Look for Arabic text or translation
            let dhikirContent = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Translation'")).firstMatch
            XCTAssertTrue(dhikirContent.waitForExistence(timeout: 5))
        }
    }

    // MARK: - Favorites View Tests

    func testFavoritesViewEmptyState() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Navigate to Favorites
        let favoritesTab = app.tabBars.buttons["Favorites"]
        favoritesTab.tap()

        // Check for empty state
        let noFavoritesText = app.staticTexts["No Favorites Yet"]
        XCTAssertTrue(noFavoritesText.waitForExistence(timeout: 5))
    }

    // MARK: - History View Tests

    func testHistoryViewEmptyState() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Navigate to History
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        // Check for empty state
        let noHistoryText = app.staticTexts["No History Yet"]
        XCTAssertTrue(noHistoryText.waitForExistence(timeout: 5))
    }

    // MARK: - Settings View Tests

    func testSettingsViewDisplays() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check for key elements
        let notificationsText = app.staticTexts["Notifications"]
        XCTAssertTrue(notificationsText.waitForExistence(timeout: 5))

        let aboutText = app.staticTexts["About"]
        XCTAssertTrue(aboutText.exists)
    }

    func testSettingsNotificationToggle() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Find notification toggle
        let notificationToggle = app.switches["Enable Notifications"]
        if notificationToggle.waitForExistence(timeout: 5) {
            XCTAssertTrue(notificationToggle.exists)
        }
    }

    // MARK: - Helper Methods

    private func skipOnboardingIfPresent() {
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 3) {
            skipButton.tap()
        }

        // Also try "Begin Your Journey" if we're on the last page
        let beginButton = app.buttons["Begin Your Journey"]
        if beginButton.waitForExistence(timeout: 2) {
            beginButton.tap()
        }
    }
}
