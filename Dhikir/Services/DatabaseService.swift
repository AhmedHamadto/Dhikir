import Foundation
import SwiftData

final class DatabaseService {
    static let shared = DatabaseService()

    private init() {}

    func seedDatabase(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "dhikirs", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load dhikirs.json")
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
            print("Successfully seeded \(container.dhikirs.count) dhikirs")
        } catch {
            print("Failed to decode dhikirs: \(error)")
        }
    }

    func getDhikirs(for category: String, context: ModelContext) -> [Dhikir] {
        let fetchDescriptor = FetchDescriptor<Dhikir>()

        do {
            let allDhikirs = try context.fetch(fetchDescriptor)
            return allDhikirs.filter { $0.categories.contains(category) }
        } catch {
            print("Failed to fetch dhikirs: \(error)")
            return []
        }
    }

    func getRandomDhikir(for category: String, context: ModelContext) -> Dhikir? {
        let dhikirs = getDhikirs(for: category, context: context)
        return dhikirs.randomElement()
    }
}

private struct DhikirContainer: Codable {
    let dhikirs: [DhikirData]
}
