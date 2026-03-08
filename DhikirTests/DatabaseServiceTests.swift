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

    // MARK: - JSON Integrity Tests

    func testDhikirsJsonIntegrity() throws {
        let url = Bundle.main.url(forResource: "dhikirs", withExtension: "json")
        let data = try XCTUnwrap(try? Data(contentsOf: XCTUnwrap(url)))
        let container = try JSONDecoder().decode(DhikirTestContainer.self, from: data)

        // Count dhikirs per active category
        var categoryCounts: [String: Int] = [:]
        for dhikir in container.dhikirs {
            for category in dhikir.categories {
                categoryCounts[category, default: 0] += 1
            }
        }

        // Every active emotional state must have exactly 5 dhikirs
        let emotionalStates = ["anxious", "sad", "angry", "grateful", "hopeful",
                               "lonely", "overwhelmed", "fearful", "joyful", "lost"]
        for state in emotionalStates {
            XCTAssertEqual(categoryCounts[state], 5,
                           "Expected 5 dhikirs for '\(state)', got \(categoryCounts[state] ?? 0)")
        }

        // Every active life situation must have exactly 5 dhikirs
        let lifeSituations = ["during_illness", "traveling", "facing_difficulty",
                              "before_decision", "seeking_forgiveness"]
        for situation in lifeSituations {
            XCTAssertEqual(categoryCounts[situation], 5,
                           "Expected 5 dhikirs for '\(situation)', got \(categoryCounts[situation] ?? 0)")
        }

        // Every dhikir must have required fields
        for dhikir in container.dhikirs {
            XCTAssertFalse(dhikir.id.isEmpty, "Dhikir has empty id")
            XCTAssertFalse(dhikir.arabicText.isEmpty, "Dhikir \(dhikir.id) has empty arabicText")
            XCTAssertFalse(dhikir.transliteration.isEmpty, "Dhikir \(dhikir.id) has empty transliteration")
            XCTAssertFalse(dhikir.englishTranslation.isEmpty, "Dhikir \(dhikir.id) has empty englishTranslation")
            XCTAssertFalse(dhikir.source.isEmpty, "Dhikir \(dhikir.id) has empty source")
            XCTAssertFalse(dhikir.categories.isEmpty, "Dhikir \(dhikir.id) has no categories")
            XCTAssertGreaterThan(dhikir.repetitionCount, 0, "Dhikir \(dhikir.id) has invalid repetitionCount")
            XCTAssertNotNil(UUID(uuidString: dhikir.id), "Dhikir \(dhikir.id) has invalid UUID")
        }
    }

    func testDhikirsJsonCategoriesMatchEnums() throws {
        let url = Bundle.main.url(forResource: "dhikirs", withExtension: "json")
        let data = try XCTUnwrap(try? Data(contentsOf: XCTUnwrap(url)))
        let container = try JSONDecoder().decode(DhikirTestContainer.self, from: data)

        let validEmotionalStates = Set(EmotionalState.allCases.map(\.rawValue))
        let validLifeSituations = Set(LifeSituation.allCases.map(\.rawValue))
        let disabledPrefixed = Set(["_morning", "_evening", "_before_sleep", "_after_salah", "_upon_waking"])
        let allValid = validEmotionalStates.union(validLifeSituations).union(disabledPrefixed)

        for dhikir in container.dhikirs {
            for category in dhikir.categories {
                XCTAssertTrue(allValid.contains(category),
                              "Dhikir \(dhikir.id) has unknown category '\(category)'")
            }
        }
    }

    // MARK: - Sync Behavior Tests

    func testSyncUpdatesCategories() throws {
        // Seed a dhikir with wrong categories (simulates stale database)
        let knownId = UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!
        let stale = Dhikir(
            id: knownId,
            arabicText: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
            transliteration: "Hasbunallahu wa ni'mal wakeel",
            englishTranslation: "Sufficient for us is Allah",
            source: "Quran 3:173",
            sourceType: .quran,
            categories: ["anxious", "sad", "angry", "grateful", "hopeful",
                         "lonely", "overwhelmed", "fearful", "joyful",
                         "lost", "morning", "evening", "fakecategory"],
            repetitionCount: 7
        )
        modelContext.insert(stale)
        try modelContext.save()

        // Verify stale state
        let before = DatabaseService.shared.getDhikirs(for: "fakecategory", context: modelContext)
        XCTAssertEqual(before.count, 1)

        // Run sync
        DatabaseService.shared.syncDatabase(context: modelContext)

        // Verify categories were corrected from JSON
        let after = DatabaseService.shared.getDhikirs(for: "fakecategory", context: modelContext)
        XCTAssertEqual(after.count, 0, "Sync should have removed fake category")

        let fetched = try modelContext.fetch(FetchDescriptor<Dhikir>()).first { $0.id == knownId }
        XCTAssertNotNil(fetched)
        XCTAssertFalse(fetched!.categories.contains("fakecategory"))
        XCTAssertFalse(fetched!.categories.contains("morning"), "Should not have disabled category without prefix")
    }

    func testSyncInsertsNewDhikirs() throws {
        // Start with empty database
        XCTAssertEqual(try modelContext.fetchCount(FetchDescriptor<Dhikir>()), 0)

        // Seed just one dhikir
        let partial = Dhikir(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
            arabicText: "Test",
            transliteration: "Test",
            englishTranslation: "Test",
            source: "Test",
            sourceType: .quran,
            categories: ["anxious"],
            repetitionCount: 1
        )
        modelContext.insert(partial)
        try modelContext.save()
        XCTAssertEqual(try modelContext.fetchCount(FetchDescriptor<Dhikir>()), 1)

        // Sync should insert the remaining dhikirs from JSON
        DatabaseService.shared.syncDatabase(context: modelContext)

        let totalCount = try modelContext.fetchCount(FetchDescriptor<Dhikir>())
        XCTAssertGreaterThan(totalCount, 1, "Sync should have inserted new dhikirs from JSON")
    }

    func testSyncRemovesDeletedDhikirs() throws {
        // Insert a dhikir with an ID that doesn't exist in JSON
        let fakeId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let orphan = Dhikir(
            id: fakeId,
            arabicText: "Orphan",
            transliteration: "Orphan",
            englishTranslation: "Orphan",
            source: "Fake",
            sourceType: .hadith,
            categories: ["anxious"],
            repetitionCount: 1
        )
        modelContext.insert(orphan)
        try modelContext.save()

        // Also seed the real database so sync has something to compare against
        DatabaseService.shared.seedDatabase(context: modelContext)
        try modelContext.save()

        // Sync should remove the orphan
        DatabaseService.shared.syncDatabase(context: modelContext)

        let remaining = try modelContext.fetch(FetchDescriptor<Dhikir>())
        XCTAssertNil(remaining.first { $0.id == fakeId }, "Sync should have removed orphan dhikir")
    }
}

// Minimal Codable struct for JSON integrity tests (avoids SwiftData dependency)
private struct DhikirTestContainer: Codable {
    let dhikirs: [DhikirTestEntry]
}

private struct DhikirTestEntry: Codable {
    let id: String
    let arabicText: String
    let transliteration: String
    let englishTranslation: String
    let source: String
    let sourceType: String
    let categories: [String]
    let repetitionCount: Int
    let audioFileName: String?
    let benefit: String?
    let translations: [String: String]?
    let benefitTranslations: [String: String]?
}
