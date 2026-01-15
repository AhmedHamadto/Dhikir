import Foundation
import SwiftData

enum SourceType: String, Codable, CaseIterable {
    case quran = "Quran"
    case hadith = "Hadith"
    case sunnah = "Sunnah"
}

enum SupportedLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case arabic = "ar"
    case urdu = "ur"
    case indonesian = "id"
    case turkish = "tr"
    case french = "fr"
    case malay = "ms"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        case .urdu: return "اردو"
        case .indonesian: return "Bahasa Indonesia"
        case .turkish: return "Türkçe"
        case .french: return "Français"
        case .malay: return "Bahasa Melayu"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .arabic: return "🇸🇦"
        case .urdu: return "🇵🇰"
        case .indonesian: return "🇮🇩"
        case .turkish: return "🇹🇷"
        case .french: return "🇫🇷"
        case .malay: return "🇲🇾"
        }
    }
}

@Model
final class Dhikir {
    @Attribute(.unique) var id: UUID
    var arabicText: String
    var transliteration: String
    var englishTranslation: String
    var translations: [String: String] = [:]
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
        translations: [String: String] = [:],
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
        self.translations = translations
        self.source = source
        self.sourceType = sourceType
        self.categories = categories
        self.repetitionCount = repetitionCount
        self.audioFileName = audioFileName
        self.benefit = benefit
    }

    func translation(for language: SupportedLanguage) -> String {
        if language == .english {
            return englishTranslation
        }
        return translations[language.rawValue] ?? englishTranslation
    }
}

struct DhikirData: Codable {
    let id: String
    let arabicText: String
    let transliteration: String
    let englishTranslation: String
    let translations: [String: String]?
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
            translations: translations ?? [:],
            source: source,
            sourceType: SourceType(rawValue: sourceType) ?? .hadith,
            categories: categories,
            repetitionCount: repetitionCount,
            audioFileName: audioFileName,
            benefit: benefit
        )
    }
}
