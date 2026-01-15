import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]

    @State private var currentPage = 0
    @Binding var hasCompletedOnboarding: Bool

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Salaam",
            subtitle: "السلام عليكم",
            description: "Welcome to Dhikir, your companion for remembrance of Allah throughout the day.",
            imageName: "heart.text.square.fill",
            color: Color("AccentGreen")
        ),
        OnboardingPage(
            title: "How Are You Feeling?",
            subtitle: "كيف حالك",
            description: "Tell us your emotional state or what you're doing, and we'll show you relevant dhikirs from the Quran and Sunnah.",
            imageName: "face.smiling.inverse",
            color: Color("AccentGold")
        ),
        OnboardingPage(
            title: "Gentle Reminders",
            subtitle: "تذكير لطيف",
            description: "Receive warm, personal notifications throughout the day asking how you're feeling.",
            imageName: "bell.badge.fill",
            color: Color(red: 0.6, green: 0.7, blue: 0.8)
        ),
        OnboardingPage(
            title: "Build Your Practice",
            subtitle: "بناء ممارستك",
            description: "Track your daily streak, save favorites, and build a consistent habit of remembrance.",
            imageName: "flame.fill",
            color: .orange
        )
    ]

    var body: some View {
        ZStack {
            Color("BackgroundCream")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                bottomSection
            }
        }
    }

    private var bottomSection: some View {
        VStack(spacing: 24) {
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color("AccentGreen") : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }

            // Action button
            Button(action: handleButtonTap) {
                Text(buttonTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("AccentGreen"))
                    )
            }
            .padding(.horizontal, 32)

            if currentPage < pages.count - 1 {
                Button("Skip") {
                    completeOnboarding()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))
            }
        }
        .padding(.bottom, 40)
    }

    private var buttonTitle: String {
        if currentPage == pages.count - 1 {
            return "Begin Your Journey"
        } else if currentPage == 2 {
            return "Enable Notifications"
        } else {
            return "Continue"
        }
    }

    private func handleButtonTap() {
        if currentPage == 2 {
            // Request notification permission
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    if let settings = settings.first {
                        NotificationService.shared.scheduleNotifications(times: settings.notificationTimes)
                    }
                }
                await MainActor.run {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }
        } else if currentPage == pages.count - 1 {
            completeOnboarding()
        } else {
            withAnimation {
                currentPage += 1
            }
        }
    }

    private func completeOnboarding() {
        if let settings = settings.first {
            settings.hasCompletedOnboarding = true
            try? modelContext.save()
        }

        withAnimation(.easeInOut(duration: 0.3)) {
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
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 120, height: 120)

                Image(systemName: page.imageName)
                    .font(.system(size: 50))
                    .foregroundStyle(page.color)
            }

            VStack(spacing: 16) {
                Text(page.subtitle)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(page.color)

                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
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
