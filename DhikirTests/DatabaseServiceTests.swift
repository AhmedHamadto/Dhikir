import XCTest
import SwiftData
@testable import Dhikir

@MainActor
final class DatabaseServiceTests: XCTestCase {

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

    // MARK: - Get Dhikirs Tests

    func testGetDhikirsForCategory() throws {
        // Insert test dhikirs
        let dhikir1 = Dhikir(
            arabicText: "Test 1",
            transliteration: "Test 1",
            englishTranslation: "Test 1",
            source: "Test",
            sourceType: .hadith,
            categories: ["anxious", "sad"],
            repetitionCount: 3
        )
        let dhikir2 = Dhikir(
            arabicText: "Test 2",
            transliteration: "Test 2",
            englishTranslation: "Test 2",
            source: "Test",
            sourceType: .quran,
            categories: ["anxious"],
            repetitionCount: 7
        )
        let dhikir3 = Dhikir(
            arabicText: "Test 3",
            transliteration: "Test 3",
            englishTranslation: "Test 3",
            source: "Test",
            sourceType: .sunnah,
            categories: ["grateful"],
            repetitionCount: 1
        )

        modelContext.insert(dhikir1)
        modelContext.insert(dhikir2)
        modelContext.insert(dhikir3)
        try modelContext.save()

        let anxiousDhikirs = DatabaseService.shared.getDhikirs(for: "anxious", context: modelContext)
        XCTAssertEqual(anxiousDhikirs.count, 2)

        let sadDhikirs = DatabaseService.shared.getDhikirs(for: "sad", context: modelContext)
        XCTAssertEqual(sadDhikirs.count, 1)

        let gratefulDhikirs = DatabaseService.shared.getDhikirs(for: "grateful", context: modelContext)
        XCTAssertEqual(gratefulDhikirs.count, 1)
    }

    func testGetDhikirsForNonExistentCategory() throws {
        let dhikir = Dhikir(
            arabicText: "Test",
            transliteration: "Test",
            englishTranslation: "Test",
            source: "Test",
            sourceType: .hadith,
            categories: ["anxious"],
            repetitionCount: 3
        )

        modelContext.insert(dhikir)
        try modelContext.save()

        let dhikirs = DatabaseService.shared.getDhikirs(for: "nonexistent", context: modelContext)
        XCTAssertEqual(dhikirs.count, 0)
    }

    func testGetRandomDhikir() throws {
        let dhikir1 = Dhikir(
            arabicText: "Test 1",
            transliteration: "Test 1",
            englishTranslation: "Test 1",
            source: "Test",
            sourceType: .hadith,
            categories: ["morning"],
            repetitionCount: 3
        )
        let dhikir2 = Dhikir(
            arabicText: "Test 2",
            transliteration: "Test 2",
            englishTranslation: "Test 2",
            source: "Test",
            sourceType: .quran,
            categories: ["morning"],
            repetitionCount: 7
        )

        modelContext.insert(dhikir1)
        modelContext.insert(dhikir2)
        try modelContext.save()

        let randomDhikir = DatabaseService.shared.getRandomDhikir(for: "morning", context: modelContext)
        XCTAssertNotNil(randomDhikir)
        XCTAssertTrue(randomDhikir!.categories.contains("morning"))
    }

    func testGetRandomDhikirForEmptyCategory() throws {
        let randomDhikir = DatabaseService.shared.getRandomDhikir(for: "empty", context: modelContext)
        XCTAssertNil(randomDhikir)
    }
}
