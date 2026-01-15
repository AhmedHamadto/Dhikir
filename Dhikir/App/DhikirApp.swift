import SwiftUI
import SwiftData

@main
struct DhikirApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Dhikir.self,
            UserFavorite.self,
            ReadingHistory.self,
            UserStreak.self,
            UserSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    seedDatabaseIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func seedDatabaseIfNeeded() {
        let context = sharedModelContainer.mainContext

        let fetchDescriptor = FetchDescriptor<Dhikir>()
        let existingCount = (try? context.fetchCount(fetchDescriptor)) ?? 0

        if existingCount == 0 {
            DatabaseService.shared.seedDatabase(context: context)
        }

        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let settingsCount = (try? context.fetchCount(settingsDescriptor)) ?? 0

        if settingsCount == 0 {
            let defaultSettings = UserSettings()
            context.insert(defaultSettings)
        }

        let streakDescriptor = FetchDescriptor<UserStreak>()
        let streakCount = (try? context.fetchCount(streakDescriptor)) ?? 0

        if streakCount == 0 {
            let defaultStreak = UserStreak()
            context.insert(defaultStreak)
        }

        try? context.save()
    }
}
