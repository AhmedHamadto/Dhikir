import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var settings: [UserSettings]

    @State private var currentPage = 0
    @State private var selectedLanguage: SupportedLanguage = .english
    @State private var notificationDenied = false
    @Binding var hasCompletedOnboarding: Bool

    private let totalPages = 5

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    private var contentPages: [OnboardingPage] {
        [
            OnboardingPage(
                title: L(.salaam, preferredLanguage),
                subtitle: L(.salaamArabic, preferredLanguage),
                description: L(.welcomeDescription, preferredLanguage),
                imageName: "heart.text.square.fill",
                color: Color("AccentGreen")
            ),
            OnboardingPage(
                title: L(.howAreYouFeelingTitle, preferredLanguage),
                subtitle: L(.howAreYouFeelingArabic, preferredLanguage),
                description: L(.howAreYouFeelingDescription, preferredLanguage),
                imageName: "face.smiling.inverse",
                color: Color("AccentGold")
            ),
            OnboardingPage(
                title: L(.gentleReminders, preferredLanguage),
                subtitle: L(.gentleRemindersArabic, preferredLanguage),
                description: L(.gentleRemindersDescription, preferredLanguage),
                imageName: "bell.badge.fill",
                color: Color(red: 0.6, green: 0.7, blue: 0.8)
            ),
            OnboardingPage(
                title: L(.buildYourPractice, preferredLanguage),
                subtitle: L(.buildYourPracticeArabic, preferredLanguage),
                description: L(.buildYourPracticeDescription, preferredLanguage),
                imageName: "flame.fill",
                color: .orange
            )
        ]
    }

    private var pageTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
    }

    var body: some View {
        ZStack {
            Color("BackgroundCream")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                #if os(iOS)
                TabView(selection: $currentPage) {
                    languageSelectionPage
                        .tag(0)

                    ForEach(0..<contentPages.count, id: \.self) { index in
                        OnboardingPageView(page: contentPages[index])
                            .tag(index + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? nil : .easeInOut, value: currentPage)
                #else
                Group {
                    if currentPage == 0 {
                        languageSelectionPage
                    } else {
                        OnboardingPageView(page: contentPages[currentPage - 1])
                    }
                }
                .id(currentPage)
                .transition(pageTransition)
                .animation(reduceMotion ? nil : .easeInOut, value: currentPage)
                #endif

                bottomSection
            }
        }
        .onAppear {
            selectedLanguage = preferredLanguage
        }
    }

    // MARK: - Language Selection Page

    private var languageSelectionPage: some View {
        VStack(spacing: AppTokens.Spacing.xxl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color("AccentGreen").opacity(0.15))
                    .frame(width: AppTokens.Onboarding.heroOuterCircle, height: AppTokens.Onboarding.heroOuterCircle)

                Circle()
                    .fill(Color("AccentGreen").opacity(0.3))
                    .frame(width: AppTokens.Onboarding.heroInnerCircle, height: AppTokens.Onboarding.heroInnerCircle)

                Image(systemName: "globe")
                    .font(.system(size: AppTokens.Onboarding.heroIconSize))
                    .foregroundStyle(Color("AccentGreen"))
            }

            VStack(spacing: AppTokens.Spacing.lg) {
                Text(L(.chooseYourLanguage, preferredLanguage))
                    .font(AppTokens.Typography.appTitle)
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                Text(L(.chooseLanguageDescription, preferredLanguage))
                    .font(AppTokens.Typography.body)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(AppTokens.Onboarding.lineSpacing)
                    .padding(.horizontal, AppTokens.Spacing.xxl)
            }

            // Language grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTokens.Spacing.md) {
                ForEach(SupportedLanguage.allCases) { language in
                    Button(action: {
                        selectedLanguage = language
                        updateLanguage(language)
                    }) {
                        HStack(spacing: AppTokens.Spacing.sm) {
                            Text(language.flag)
                                .font(AppTokens.Typography.icon)

                            Text(language.displayName)
                                .font(AppTokens.Typography.small)
                                .foregroundStyle(selectedLanguage == language ? Color("AccentGreen") : Color("TextPrimary"))
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, AppTokens.Spacing.md)
                        .padding(.vertical, AppTokens.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTokens.Radius.small)
                                .fill(Color("CardBackground"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTokens.Radius.small)
                                        .stroke(selectedLanguage == language ? Color("AccentGreen") : Color.clear, lineWidth: AppTokens.Onboarding.borderWidth)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, AppTokens.Spacing.xxl)

            Spacer()
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: AppTokens.Spacing.xl) {
            // Page indicators
            PillProgressIndicator(count: totalPages, current: currentPage)

            // Notification denied message
            if currentPage == 3 && notificationDenied {
                Text(L(.notificationDeniedMessage, preferredLanguage))
                    .font(AppTokens.Typography.caption)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTokens.Spacing.xxl)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            #if os(macOS)
            // Previous button on macOS
            if currentPage > 0 {
                Button(action: {
                    withAnimation {
                        currentPage -= 1
                    }
                }) {
                    Text(L(.previousButton, preferredLanguage))
                        .font(AppTokens.Typography.body)
                        .foregroundStyle(Color("AccentGreen"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            #endif

            // Action button
            Button(action: handleButtonTap) {
                Text(buttonTitle)
                    .font(AppTokens.Typography.heading)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTokens.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                            .fill(Color("AccentGreen"))
                    )
            }
            .padding(.horizontal, AppTokens.Spacing.xxl)

            if currentPage < totalPages - 1 {
                Button(L(.skip, preferredLanguage)) {
                    completeOnboarding()
                }
                .font(AppTokens.Typography.caption)
                .foregroundStyle(Color("TextSecondary"))
            }
        }
        .padding(.bottom, AppTokens.Onboarding.bottomInset)
    }

    // MARK: - Button Title

    private var buttonTitle: String {
        if currentPage == totalPages - 1 {
            return L(.beginYourJourney, preferredLanguage)
        } else if currentPage == 3 && !notificationDenied {
            return L(.enableNotificationsButton, preferredLanguage)
        } else {
            return L(.continueButton, preferredLanguage)
        }
    }

    // MARK: - Actions

    private func handleButtonTap() {
        if currentPage == 3 && !notificationDenied {
            // Request notification permission
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                await MainActor.run {
                    if granted {
                        if let settings = settings.first {
                            NotificationService.shared.scheduleNotifications(times: settings.notificationTimes)
                        }
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            notificationDenied = true
                        }
                    }
                }
            }
        } else if currentPage == totalPages - 1 {
            completeOnboarding()
        } else {
            withAnimation {
                currentPage += 1
            }
        }
    }

    private func updateLanguage(_ language: SupportedLanguage) {
        if let settings = settings.first {
            settings.preferredLanguage = language
            try? modelContext.save()
        }
    }

    private func completeOnboarding() {
        if let settings = settings.first {
            settings.hasCompletedOnboarding = true
            try? modelContext.save()
        }

        withAnimation(.easeInOut(duration: AppTokens.Onboarding.animationDuration)) {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppTokens.Spacing.xxl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: AppTokens.Onboarding.heroOuterCircle, height: AppTokens.Onboarding.heroOuterCircle)

                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: AppTokens.Onboarding.heroInnerCircle, height: AppTokens.Onboarding.heroInnerCircle)

                Image(systemName: page.imageName)
                    .font(.system(size: AppTokens.Onboarding.heroIconSize))
                    .foregroundStyle(page.color)
            }

            VStack(spacing: AppTokens.Spacing.lg) {
                Text(page.subtitle)
                    .font(AppTokens.Typography.arabicSmall)
                    .foregroundStyle(page.color)

                Text(page.title)
                    .font(AppTokens.Typography.appTitle)
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(AppTokens.Typography.body)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(AppTokens.Onboarding.lineSpacing)
                    .padding(.horizontal, AppTokens.Spacing.xxl)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: [UserSettings.self], inMemory: true)
}
