import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    @State private var selectedTab: Tab = .home
    @State private var showEmotionSelection = false
    @State private var hasCompletedOnboarding = false

    private var shouldShowOnboarding: Bool {
        guard let userSettings = settings.first else { return true }
        return !userSettings.hasCompletedOnboarding && !hasCompletedOnboarding
    }

    enum Tab {
        case home
        case favorites
        case history
        case settings
    }

    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                mainTabView
            }
        }
        .onAppear {
            if let userSettings = settings.first {
                hasCompletedOnboarding = userSettings.hasCompletedOnboarding
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(showEmotionSelection: $showEmotionSelection)
                .tabItem {
                    Label("Home", systemImage: "heart.text.square")
                }
                .tag(Tab.home)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(Tab.favorites)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(Color("AccentGreen"))
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveNotificationResponse)) { _ in
            showEmotionSelection = true
            selectedTab = .home
        }
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Dhikir.self, UserFavorite.self, ReadingHistory.self, UserStreak.self, UserSettings.self], inMemory: true)
}
