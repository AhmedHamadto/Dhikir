import Foundation
import SwiftData

enum SourceType: String, Codable, CaseIterable {
    case quran = "Quran"
    case hadith = "Hadith"
    case sunnah = "Sunnah"
}

@Model
final class Dhikir {
    @Attribute(.unique) var id: UUID
    var arabicText: String
    var transliteration: String
    var englishTranslation: String
    var source: String
    var sourceType: SourceType
    var categories: [String]
    var repetitionCount: Int
    var audioFileName: String?
    var benefit: String?

    init(
        id: UUID = UUID(),
        arabicText: String,
        transliteration: String,
        englishTranslation: String,
        source: String,
        sourceType: SourceType,
        categories: [String],
        repetitionCount: Int = 1,
        audioFileName: String? = nil,
        benefit: String? = nil
    ) {
        self.id = id
        self.arabicText = arabicText
        self.transliteration = transliteration
        self.englishTranslation = englishTranslation
        self.source = source
        self.sourceType = sourceType
        self.categories = categories
        self.repetitionCount = repetitionCount
        self.audioFileName = audioFileName
        self.benefit = benefit
    }
}

struct DhikirData: Codable {
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

    func toModel() -> Dhikir {
        Dhikir(
            id: UUID(uuidString: id) ?? UUID(),
            arabicText: arabicText,
            transliteration: transliteration,
            englishTranslation: englishTranslation,
            source: source,
            sourceType: SourceType(rawValue: sourceType) ?? .hadith,
            categories: categories,
            repetitionCount: repetitionCount,
            audioFileName: audioFileName,
            benefit: benefit
        )
    }
}
