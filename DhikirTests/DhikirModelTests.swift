import XCTest
import SwiftData
@testable import Dhikir

@MainActor
final class DhikirModelTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([
            Dhikir.self,
            UserFavorite.self,
            ReadingHistory.self,
            UserStreak.self,
            UserSettings.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Dhikir Model Tests

    func testDhikirCreation() throws {
        let dhikir = Dhikir(
            arabicText: "بِسْمِ اللَّهِ",
            transliteration: "Bismillah",
            englishTranslation: "In the name of Allah",
            source: "Common Usage",
            sourceType: .sunnah,
            categories: ["morning", "evening"],
            repetitionCount: 1
        )

        XCTAssertNotNil(dhikir.id)
        XCTAssertEqual(dhikir.arabicText, "بِسْمِ اللَّهِ")
        XCTAssertEqual(dhikir.transliteration, "Bismillah")
        XCTAssertEqual(dhikir.englishTranslation, "In the name of Allah")
        XCTAssertEqual(dhikir.sourceType, .sunnah)
        XCTAssertEqual(dhikir.categories.count, 2)
        XCTAssertTrue(dhikir.categories.contains("morning"))
        XCTAssertEqual(dhikir.repetitionCount, 1)
    }

    func testDhikirPersistence() throws {
        let dhikir = Dhikir(
            arabicText: "الْحَمْدُ لِلَّهِ",
            transliteration: "Alhamdulillah",
            englishTranslation: "All praise is due to Allah",
            source: "Quran 1:2",
            sourceType: .quran,
            categories: ["grateful"],
            repetitionCount: 3
        )

        modelContext.insert(dhikir)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<Dhikir>()
        let fetchedDhikirs = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedDhikirs.count, 1)
        XCTAssertEqual(fetchedDhikirs.first?.arabicText, "الْحَمْدُ لِلَّهِ")
    }

    func testDhikirWithOptionalFields() throws {
        let dhikir = Dhikir(
            arabicText: "Test",
            transliteration: "Test",
            englishTranslation: "Test",
            source: "Test",
            sourceType: .hadith,
            categories: ["anxious"],
            repetitionCount: 7,
            audioFileName: "test.mp3",
            benefit: "This is a test benefit"
        )

        XCTAssertEqual(dhikir.audioFileName, "test.mp3")
        XCTAssertEqual(dhikir.benefit, "This is a test benefit")
    }

    // MARK: - UserFavorite Tests

    func testUserFavoriteCreation() throws {
        let dhikirId = UUID()
        let favorite = UserFavorite(dhikirId: dhikirId)

        XCTAssertNotNil(favorite.id)
        XCTAssertEqual(favorite.dhikirId, dhikirId)
        XCTAssertNotNil(favorite.dateAdded)
    }

    func testUserFavoritePersistence() throws {
        let dhikirId = UUID()
        let favorite = UserFavorite(dhikirId: dhikirId)

        modelContext.insert(favorite)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<UserFavorite>()
        let fetchedFavorites = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedFavorites.count, 1)
        XCTAssertEqual(fetchedFavorites.first?.dhikirId, dhikirId)
    }

    // MARK: - ReadingHistory Tests

    func testReadingHistoryCreation() throws {
        let dhikirId = UUID()
        let history = ReadingHistory(
            dhikirId: dhikirId,
            category: "anxious",
            completedRepetitions: 5
        )

        XCTAssertNotNil(history.id)
        XCTAssertEqual(history.dhikirId, dhikirId)
        XCTAssertEqual(history.category, "anxious")
        XCTAssertEqual(history.completedRepetitions, 5)
        XCTAssertNotNil(history.dateRead)
    }

    // MARK: - UserStreak Tests

    func testUserStreakCreation() throws {
        let streak = UserStreak(
            currentStreak: 5,
            longestStreak: 10,
            totalDaysActive: 30
        )

        XCTAssertEqual(streak.currentStreak, 5)
        XCTAssertEqual(streak.longestStreak, 10)
        XCTAssertEqual(streak.totalDaysActive, 30)
    }

    func testUserStreakDefaults() throws {
        let streak = UserStreak()

        XCTAssertEqual(streak.currentStreak, 0)
        XCTAssertEqual(streak.longestStreak, 0)
        XCTAssertEqual(streak.totalDaysActive, 0)
    }

    // MARK: - UserSettings Tests

    func testUserSettingsCreation() throws {
        let settings = UserSettings()

        XCTAssertTrue(settings.notificationsEnabled)
        XCTAssertFalse(settings.hasCompletedOnboarding)
        XCTAssertEqual(settings.preferredLanguage, "en")
        XCTAssertTrue(settings.hapticFeedbackEnabled)
        XCTAssertEqual(settings.notificationTimes.count, 5) // Default times
    }

    func testNotificationTimeDefaults() throws {
        let defaults = NotificationTime.defaults

        XCTAssertEqual(defaults.count, 5)
        XCTAssertEqual(defaults[0].label, "Fajr time")
        XCTAssertEqual(defaults[0].hour, 6)
        XCTAssertEqual(defaults[0].minute, 30)
    }

    func testNotificationTimeString() throws {
        let time = NotificationTime(hour: 14, minute: 30, label: "Afternoon")
        let timeString = time.timeString

        XCTAssertTrue(timeString.contains("2:30") || timeString.contains("14:30"))
    }
}
