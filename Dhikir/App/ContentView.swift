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

    private var preferredColorScheme: ColorScheme? {
        settings.first?.appearanceMode.colorScheme
    }

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    enum Tab: String, CaseIterable {
        case home
        case favorites
        case history
        case settings

        func label(for language: SupportedLanguage) -> String {
            switch self {
            case .home: return L(.tabHome, language)
            case .favorites: return L(.tabFavorites, language)
            case .history: return L(.tabHistory, language)
            case .settings: return L(.tabSettings, language)
            }
        }

        var icon: String {
            switch self {
            case .home: return "heart.text.square"
            case .favorites: return "heart.fill"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                #if os(iOS)
                mainTabView
                #elseif os(macOS)
                mainSplitView
                #endif
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .environment(\.layoutDirection, (preferredLanguage == .arabic || preferredLanguage == .urdu) ? .rightToLeft : .leftToRight)
        .onAppear {
            if let userSettings = settings.first {
                hasCompletedOnboarding = userSettings.hasCompletedOnboarding
            }
        }
    }

    #if os(iOS)
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(showEmotionSelection: $showEmotionSelection)
                .tabItem {
                    Label(L(.tabHome, preferredLanguage), systemImage: "heart.text.square")
                }
                .tag(Tab.home)

            FavoritesView()
                .tabItem {
                    Label(L(.tabFavorites, preferredLanguage), systemImage: "heart.fill")
                }
                .tag(Tab.favorites)

            HistoryView()
                .tabItem {
                    Label(L(.tabHistory, preferredLanguage), systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)

            SettingsView()
                .tabItem {
                    Label(L(.tabSettings, preferredLanguage), systemImage: "gearshape.fill")
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
    #endif

    #if os(macOS)
    private var mainSplitView: some View {
        NavigationSplitView {
            List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.label(for: preferredLanguage), systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle(L(.appName, preferredLanguage))
        } detail: {
            switch selectedTab {
            case .home:
                HomeView(showEmotionSelection: $showEmotionSelection)
            case .favorites:
                FavoritesView()
            case .history:
                HistoryView()
            case .settings:
                SettingsView()
            }
        }
        .tint(Color("AccentGreen"))
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveNotificationResponse)) { _ in
            showEmotionSelection = true
            selectedTab = .home
        }
    }
    #endif
}

#Preview {
    ContentView()
        .modelContainer(for: [Dhikir.self, UserFavorite.self, ReadingHistory.self, UserStreak.self, UserSettings.self], inMemory: true)
}
