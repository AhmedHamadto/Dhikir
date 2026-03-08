import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var streaks: [UserStreak]
    @Query private var settings: [UserSettings]
    @Binding var showEmotionSelection: Bool
    @State private var selectedCategory: String?
    @State private var showDhikir = false
    @State private var cardsAppeared = false
    @State private var milestoneGlow = false

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
                VStack(spacing: AppTokens.Spacing.xl) {
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
                cardsAppeared = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppTokens.Spacing.sm) {
            Text(L(.appName, preferredLanguage))
                .font(AppTokens.Typography.appTitle)
                .foregroundStyle(Color("TextPrimary"))

            Text(L(.howAreYouFeeling, preferredLanguage))
                .font(AppTokens.Typography.callToAction)
                .foregroundStyle(Color("TextPrimary"))
        }
        .padding(.top, AppTokens.Spacing.xl)
    }

    private var streakCard: some View {
        HStack(spacing: AppTokens.Spacing.lg) {
            Image(systemName: "flame.fill")
                .font(.system(size: AppTokens.IconSize.medium))
                .foregroundStyle(Color.orange)

            VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                if currentStreak == 0 {
                    Text(L(.startYourJourney, preferredLanguage))
                        .font(AppTokens.Typography.heading)
                        .foregroundStyle(Color("TextPrimary"))
                } else {
                    Text("\(currentStreak) \(L(.dayStreak, preferredLanguage))")
                        .font(AppTokens.Typography.heading)
                        .foregroundStyle(Color("TextPrimary"))
                }

                if let milestone = StreakService.shared.streakMilestone(for: currentStreak) {
                    Text(milestone)
                        .font(AppTokens.Typography.caption)
                        .foregroundStyle(Color("AccentGold"))
                        .opacity(milestoneGlow ? 1.0 : 0.7)
                        .onAppear {
                            guard !reduceMotion else { return }
                            withAnimation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true)) {
                                milestoneGlow = true
                            }
                        }
                } else {
                    Text(L(.keepGoing, preferredLanguage))
                        .font(AppTokens.Typography.bodySmall)
                        .foregroundStyle(Color("TextSecondary"))
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                .fill(Color("CardBackground"))
                .shadow(color: .black.opacity(AppTokens.Shadow.heavy.opacity), radius: AppTokens.Shadow.heavy.radius, y: AppTokens.Shadow.heavy.y)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(currentStreak == 0
            ? L(.startYourJourney, preferredLanguage)
            : "\(currentStreak) day streak"
        )
    }

    private var emotionsSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.lg) {
            Text(L(.howIFeel, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextPrimary"))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTokens.Spacing.sm) {
                ForEach(Array(EmotionalState.allCases.enumerated()), id: \.element) { index, emotion in
                    EmotionButton(
                        title: emotion.displayName(for: preferredLanguage),
                        arabicTitle: emotion.arabicName,
                        icon: emotion.icon,
                        color: emotion.color,
                        description: emotion.description(for: preferredLanguage),
                        compact: true,
                        hapticEnabled: hapticEnabled
                    ) {
                        selectCategory(emotion.rawValue)
                    }
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 8)
                    .animation(
                        reduceMotion ? .none : .easeInOut(duration: 0.3).delay(Double(index) * 0.03),
                        value: cardsAppeared
                    )
                }
            }
        }
    }

    private var situationsSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.lg) {
            Text(L(.whatImDoing, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextPrimary"))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTokens.Spacing.md) {
                ForEach(Array(LifeSituation.allCases.enumerated()), id: \.element) { index, situation in
                    let staggerOffset = EmotionalState.allCases.count + index
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
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 8)
                    .animation(
                        reduceMotion ? .none : .easeInOut(duration: 0.3).delay(Double(staggerOffset) * 0.03),
                        value: cardsAppeared
                    )
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
