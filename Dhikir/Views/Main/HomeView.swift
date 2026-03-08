import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var streaks: [UserStreak]
    @Query private var settings: [UserSettings]
    @Binding var showEmotionSelection: Bool
    @State private var selectedCategory: String?
    @State private var showDhikir = false

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    private var currentStreak: Int {
        streaks.first?.currentStreak ?? 0
    }

    private var hapticEnabled: Bool {
        settings.first?.hapticFeedbackEnabled ?? true
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    streakCard

                    emotionsSection

                    situationsSection
                }
                .padding()
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationDestination(isPresented: $showDhikir) {
                if let category = selectedCategory {
                    DhikirDisplayView(category: category)
                }
            }
            .onAppear {
                if showEmotionSelection {
                    showEmotionSelection = false
                }
                NotificationService.shared.clearBadge()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(L(.appName, preferredLanguage))
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(Color("TextPrimary"))

            Text(L(.howAreYouFeeling, preferredLanguage))
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))
        }
        .padding(.top, 20)
    }

    private var streakCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(currentStreak) \(L(.dayStreak, preferredLanguage))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))

                if let milestone = StreakService.shared.streakMilestone(for: currentStreak) {
                    Text(milestone)
                        .font(.system(size: 14))
                        .foregroundStyle(Color("AccentGold"))
                } else {
                    Text(L(.keepGoing, preferredLanguage))
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(currentStreak) day streak")
    }

    private var emotionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L(.howIFeel, preferredLanguage))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(EmotionalState.allCases) { emotion in
                    EmotionButton(
                        title: emotion.displayName(for: preferredLanguage),
                        arabicTitle: emotion.arabicName,
                        icon: emotion.icon,
                        color: emotion.color,
                        description: emotion.description(for: preferredLanguage),
                        hapticEnabled: hapticEnabled
                    ) {
                        selectCategory(emotion.rawValue)
                    }
                }
            }
        }
    }

    private var situationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L(.whatImDoing, preferredLanguage))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(LifeSituation.allCases) { situation in
                    EmotionButton(
                        title: situation.displayName(for: preferredLanguage),
                        arabicTitle: situation.arabicName,
                        icon: situation.icon,
                        color: situation.color,
                        description: situation.description(for: preferredLanguage),
                        hapticEnabled: hapticEnabled
                    ) {
                        selectCategory(situation.rawValue)
                    }
                }
            }
        }
    }

    private func selectCategory(_ category: String) {
        if hapticEnabled {
            triggerHaptic(.light)
        }
        selectedCategory = category
        StreakService.shared.recordActivity(context: modelContext)
        showDhikir = true
    }
}

#Preview {
    HomeView(showEmotionSelection: .constant(false))
        .modelContainer(for: [Dhikir.self, UserStreak.self], inMemory: true)
}
