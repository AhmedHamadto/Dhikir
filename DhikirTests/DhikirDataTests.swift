import XCTest
@testable import Dhikir

final class DhikirDataTests: XCTestCase {

    // MARK: - JSON Data Validation Tests

    func testDhikirDataDecoding() throws {
        let jsonString = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440001",
            "arabicText": "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
            "transliteration": "Hasbunallahu wa ni'mal wakeel",
            "englishTranslation": "Sufficient for us is Allah",
            "source": "Quran 3:173",
            "sourceType": "Quran",
            "categories": ["anxious", "overwhelmed"],
            "repetitionCount": 7,
            "audioFileName": null,
            "benefit": "Test benefit"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let dhikirData = try decoder.decode(DhikirData.self, from: data)

        XCTAssertEqual(dhikirData.id, "550e8400-e29b-41d4-a716-446655440001")
        XCTAssertEqual(dhikirData.arabicText, "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ")
        XCTAssertEqual(dhikirData.transliteration, "Hasbunallahu wa ni'mal wakeel")
        XCTAssertEqual(dhikirData.source, "Quran 3:173")
        XCTAssertEqual(dhikirData.sourceType, "Quran")
        XCTAssertEqual(dhikirData.categories.count, 2)
        XCTAssertEqual(dhikirData.repetitionCount, 7)
        XCTAssertNil(dhikirData.audioFileName)
        XCTAssertEqual(dhikirData.benefit, "Test benefit")
    }

    func testDhikirDataToModel() throws {
        // Use JSON decoding to create DhikirData since it's a Codable struct
        let jsonString = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440001",
            "arabicText": "Test Arabic",
            "transliteration": "Test Transliteration",
            "englishTranslation": "Test Translation",
            "source": "Quran 1:1",
            "sourceType": "Quran",
            "categories": ["morning"],
            "repetitionCount": 3,
            "audioFileName": null,
            "benefit": "Test benefit"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let dhikirData = try decoder.decode(DhikirData.self, from: data)
        let model = dhikirData.toModel()

        XCTAssertEqual(model.arabicText, "Test Arabic")
        XCTAssertEqual(model.transliteration, "Test Transliteration")
        XCTAssertEqual(model.englishTranslation, "Test Translation")
        XCTAssertEqual(model.source, "Quran 1:1")
        XCTAssertEqual(model.sourceType, .quran)
        XCTAssertEqual(model.categories, ["morning"])
        XCTAssertEqual(model.repetitionCount, 3)
    }

    func testSourceTypeConversion() {
        XCTAssertEqual(SourceType(rawValue: "Quran"), .quran)
        XCTAssertEqual(SourceType(rawValue: "Hadith"), .hadith)
        XCTAssertEqual(SourceType(rawValue: "Sunnah"), .sunnah)
        XCTAssertNil(SourceType(rawValue: "Invalid"))
    }

    func testSourceTypeRawValues() {
        XCTAssertEqual(SourceType.quran.rawValue, "Quran")
        XCTAssertEqual(SourceType.hadith.rawValue, "Hadith")
        XCTAssertEqual(SourceType.sunnah.rawValue, "Sunnah")
    }

    func testAllSourceTypesCaseIterable() {
        let allCases = SourceType.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.quran))
        XCTAssertTrue(allCases.contains(.hadith))
        XCTAssertTrue(allCases.contains(.sunnah))
    }

    // MARK: - Category Coverage Tests

    func testAllEmotionalStatesHaveCategories() {
        let emotionalCategories = EmotionalState.allCases.map { $0.rawValue }

        // These should match the categories used in dhikirs.json
        let expectedCategories = ["anxious", "sad", "angry", "grateful", "hopeful",
                                   "lonely", "overwhelmed", "fearful", "joyful", "lost"]

        for category in expectedCategories {
            XCTAssertTrue(emotionalCategories.contains(category),
                          "Missing emotional category: \(category)")
        }
    }

    func testAllLifeSituationsHaveCategories() {
        let situationCategories = LifeSituation.allCases.map { $0.rawValue }

        let expectedCategories = ["morning", "evening", "before_sleep", "upon_waking",
                                   "during_illness", "traveling", "facing_difficulty",
                                   "before_decision", "after_salah", "seeking_forgiveness"]

        for category in expectedCategories {
            XCTAssertTrue(situationCategories.contains(category),
                          "Missing situation category: \(category)")
        }
    }
}
