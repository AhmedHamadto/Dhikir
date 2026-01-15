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

    func refreshTranslations(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "dhikirs", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let container = try decoder.decode(DhikirContainer.self, from: data)

            let fetchDescriptor = FetchDescriptor<Dhikir>()
            let existingDhikirs = try context.fetch(fetchDescriptor)

            var updatedCount = 0
            for dhikirData in container.dhikirs {
                guard let uuid = UUID(uuidString: dhikirData.id) else { continue }

                if let existing = existingDhikirs.first(where: { $0.id == uuid }) {
                    let newTranslations = dhikirData.translations ?? [:]
                    if existing.translations != newTranslations {
                        existing.translations = newTranslations
                        updatedCount += 1
                    }
                }
            }

            if updatedCount > 0 {
                try context.save()
                #if DEBUG
                print("Updated translations for \(updatedCount) dhikirs")
                #endif
            }
        } catch {
            #if DEBUG
            print("Failed to refresh translations: \(error)")
            #endif
        }
    }
}

private struct DhikirContainer: Codable {
    let dhikirs: [DhikirData]
}
