import Foundation
import SwiftData

final class DatabaseService {
    static let shared = DatabaseService()

    private init() {}

    func seedDatabase(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "dhikirs", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            #if DEBUG
            print("Failed to load dhikirs.json")
            #endif
            return
        }

        do {
            let decoder = JSONDecoder()
            let container = try decoder.decode(DhikirContainer.self, from: data)

            for dhikirData in container.dhikirs {
                let dhikir = dhikirData.toModel()
                context.insert(dhikir)
            }

            try context.save()
            #if DEBUG
            print("Successfully seeded \(container.dhikirs.count) dhikirs")
            #endif
        } catch {
            #if DEBUG
            print("Failed to decode dhikirs: \(error)")
            #endif
        }
    }

    func getDhikirs(for category: String, context: ModelContext) -> [Dhikir] {
        let fetchDescriptor = FetchDescriptor<Dhikir>()

        do {
            let allDhikirs = try context.fetch(fetchDescriptor)
            return allDhikirs.filter { $0.categories.contains(category) }
        } catch {
            #if DEBUG
            print("Failed to fetch dhikirs: \(error)")
            #endif
            return []
        }
    }

    func getRandomDhikir(for category: String, context: ModelContext) -> Dhikir? {
        let dhikirs = getDhikirs(for: category, context: context)
        return dhikirs.randomElement()
    }

    func syncDatabase(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "dhikirs", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let container = try decoder.decode(DhikirContainer.self, from: data)

            let fetchDescriptor = FetchDescriptor<Dhikir>()
            let existingDhikirs = try context.fetch(fetchDescriptor)
            let existingById = Dictionary(uniqueKeysWithValues: existingDhikirs.compactMap { dhikir in
                (dhikir.id, dhikir)
            })

            var updatedCount = 0
            var insertedCount = 0

            for dhikirData in container.dhikirs {
                guard let uuid = UUID(uuidString: dhikirData.id) else { continue }

                if let existing = existingById[uuid] {
                    var changed = false
                    if existing.arabicText != dhikirData.arabicText {
                        existing.arabicText = dhikirData.arabicText; changed = true
                    }
                    if existing.transliteration != dhikirData.transliteration {
                        existing.transliteration = dhikirData.transliteration; changed = true
                    }
                    if existing.englishTranslation != dhikirData.englishTranslation {
                        existing.englishTranslation = dhikirData.englishTranslation; changed = true
                    }
                    if existing.source != dhikirData.source {
                        existing.source = dhikirData.source; changed = true
                    }
                    let newSourceType = SourceType(rawValue: dhikirData.sourceType) ?? .hadith
                    if existing.sourceType != newSourceType {
                        existing.sourceType = newSourceType; changed = true
                    }
                    if existing.categories != dhikirData.categories {
                        existing.categories = dhikirData.categories; changed = true
                    }
                    if existing.repetitionCount != dhikirData.repetitionCount {
                        existing.repetitionCount = dhikirData.repetitionCount; changed = true
                    }
                    let newTranslations = dhikirData.translations ?? [:]
                    if existing.translations != newTranslations {
                        existing.translations = newTranslations; changed = true
                    }
                    let newBenefit = dhikirData.benefit
                    if existing.benefit != newBenefit {
                        existing.benefit = newBenefit; changed = true
                    }
                    let newBenefitTranslations = dhikirData.benefitTranslations ?? [:]
                    if existing.benefitTranslations != newBenefitTranslations {
                        existing.benefitTranslations = newBenefitTranslations; changed = true
                    }
                    if changed { updatedCount += 1 }
                } else {
                    context.insert(dhikirData.toModel())
                    insertedCount += 1
                }
            }

            // Remove dhikirs that are no longer in the JSON
            let currentJsonIds = Set(container.dhikirs.compactMap { UUID(uuidString: $0.id) })
            var deletedCount = 0
            for existing in existingDhikirs {
                if !currentJsonIds.contains(existing.id) {
                    context.delete(existing)
                    deletedCount += 1
                }
            }

            if updatedCount > 0 || insertedCount > 0 || deletedCount > 0 {
                try context.save()
                #if DEBUG
                print("Database sync: \(updatedCount) updated, \(insertedCount) inserted, \(deletedCount) removed")
                #endif
            }
        } catch {
            #if DEBUG
            print("Failed to sync database: \(error)")
            #endif
        }
    }
}

private struct DhikirContainer: Codable {
    let dhikirs: [DhikirData]
}
