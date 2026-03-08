import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    @Query private var streaks: [UserStreak]

    @State private var notificationsEnabled: Bool = true
    @State private var notificationTimes: [NotificationTime] = NotificationTime.defaults
    @State private var showingResetAlert = false
    @State private var showingDisclaimer = false
    @State private var selectedAppearance: AppearanceMode = .system
    @State private var selectedLanguage: SupportedLanguage = .english
    @State private var hapticFeedbackEnabled: Bool = true

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    private var currentSettings: UserSettings? {
        settings.first
    }

    private var currentStreak: UserStreak? {
        streaks.first
    }

    private var uniqueEnabledDhikirCount: Int {
        let allDhikirs = (try? modelContext.fetch(FetchDescriptor<Dhikir>())) ?? []
        return allDhikirs.filter { dhikir in
            dhikir.categories.contains { !$0.hasPrefix("_") }
        }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTokens.Spacing.xl) {
                        progressSection

                        preferencesSection

                        aboutAndLegalSection
                    }
                    .padding()
                }
            }
            .navigationTitle(L(.settings, preferredLanguage))
            .onAppear {
                loadSettings()
            }
            .alert(L(.resetAllData, preferredLanguage), isPresented: $showingResetAlert) {
                Button(L(.cancel, preferredLanguage), role: .cancel) {}
                Button(L(.reset, preferredLanguage), role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text(L(.resetWarning, preferredLanguage))
            }
            .sheet(isPresented: $showingDisclaimer) {
                DisclaimerSheet()
            }
        }
    }

    // MARK: - Section 1: Your Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.lg) {
            Text(L(.yourProgress, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextPrimary"))

            HStack(spacing: 20) {
                StatCard(
                    title: L(.currentStreak, preferredLanguage),
                    value: "\(currentStreak?.currentStreak ?? 0)",
                    icon: "flame.fill",
                    color: .orange
                )

                StatCard(
                    title: L(.longestStreak, preferredLanguage),
                    value: "\(currentStreak?.longestStreak ?? 0)",
                    icon: "trophy.fill",
                    color: Color("AccentGold")
                )

                StatCard(
                    title: L(.totalDays, preferredLanguage),
                    value: "\(currentStreak?.totalDaysActive ?? 0)",
                    icon: "calendar",
                    color: Color("AccentGreen")
                )
            }
        }
    }

    // MARK: - Section 2: Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.lg) {
            Text(L(.preferences, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextPrimary"))

            // Notifications
            notificationContent

            // Appearance
            appearanceContent

            // Haptic Feedback
            #if os(iOS)
            hapticContent
            #endif

            // Language
            languageContent
        }
    }

    private var notificationContent: some View {
        VStack(spacing: AppTokens.Spacing.md) {
            Toggle(isOn: $notificationsEnabled) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(Color("AccentGreen"))
                    Text(L(.enableNotifications, preferredLanguage))
                        .font(AppTokens.Typography.body)
                }
            }
            .tint(Color("AccentGreen"))
            .onChange(of: notificationsEnabled) { _, newValue in
                updateNotificationSetting(enabled: newValue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                    .fill(Color("CardBackground"))
            )

            if notificationsEnabled {
                VStack(spacing: AppTokens.Spacing.sm) {
                    ForEach($notificationTimes) { $time in
                        NotificationTimeRow(time: $time) {
                            updateNotificationTimes()
                        }
                    }
                }
            }
        }
    }

    private var appearanceContent: some View {
        HStack(spacing: AppTokens.Spacing.md) {
            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedAppearance = mode
                    updateAppearance(mode)
                }) {
                    VStack(spacing: AppTokens.Spacing.sm) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(selectedAppearance == mode ? Color("AccentGreen") : Color("TextSecondary"))

                        Text(mode.displayName(for: preferredLanguage))
                            .font(AppTokens.Typography.small)
                            .foregroundStyle(selectedAppearance == mode ? Color("AccentGreen") : Color("TextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTokens.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                            .fill(Color("CardBackground"))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                                    .stroke(selectedAppearance == mode ? Color("AccentGreen") : Color.clear, lineWidth: 2)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var hapticContent: some View {
        Toggle(isOn: $hapticFeedbackEnabled) {
            HStack {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .foregroundStyle(Color("AccentGreen"))
                Text(L(.hapticFeedback, preferredLanguage))
                    .font(AppTokens.Typography.body)
            }
        }
        .tint(Color("AccentGreen"))
        .onChange(of: hapticFeedbackEnabled) { _, newValue in
            updateHapticSetting(enabled: newValue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                .fill(Color("CardBackground"))
        )
    }

    private var languageContent: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            Text(L(.translationLanguage, preferredLanguage))
                .font(AppTokens.Typography.caption)
                .foregroundStyle(Color("TextSecondary"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTokens.Spacing.sm) {
                ForEach(SupportedLanguage.allCases) { language in
                    Button(action: {
                        selectedLanguage = language
                        updateLanguage(language)
                    }) {
                        HStack(spacing: AppTokens.Spacing.sm) {
                            Text(language.flag)
                                .font(.system(size: 20))

                            Text(language.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(selectedLanguage == language ? Color("AccentGreen") : Color("TextPrimary"))
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, AppTokens.Spacing.md)
                        .padding(.vertical, AppTokens.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppTokens.Radius.small)
                                .fill(Color("CardBackground"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTokens.Radius.small)
                                        .stroke(selectedLanguage == language ? Color("AccentGreen") : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Section 3: About & Legal

    private var aboutAndLegalSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.lg) {
            Text(L(.about, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextPrimary"))

            // About info rows
            VStack(spacing: 0) {
                AboutRow(title: L(.version, preferredLanguage), value: "1.0.0")
                Divider()
                AboutRow(title: L(.dhikirs, preferredLanguage), value: "\(uniqueEnabledDhikirCount)")
                Divider()
                AboutRow(title: L(.sources, preferredLanguage), value: L(.quranAndHadith, preferredLanguage))
                Divider()
                AboutRow(title: L(.languages, preferredLanguage), value: "7")
            }
            .background(
                RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                    .fill(Color("CardBackground"))
            )

            // Disclaimer
            VStack(spacing: 0) {
                Button(action: { showingDisclaimer = true }) {
                    HStack {
                        Text(L(.disclaimer, preferredLanguage))
                            .font(AppTokens.Typography.body)
                            .foregroundStyle(Color("TextPrimary"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(AppTokens.Typography.caption)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(
                RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                    .fill(Color("CardBackground"))
            )

            Text(L(.disclaimerNote, preferredLanguage))
                .font(.system(size: 12))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.leading)

            // Reset
            Button(action: { showingResetAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                    Text(L(.resetAllData, preferredLanguage))
                        .foregroundStyle(Color.red)
                    Spacer()
                }
                .font(AppTokens.Typography.body)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                        .fill(Color("CardBackground"))
                )
            }
        }
    }

    // MARK: - Settings Logic

    private func loadSettings() {
        if let settings = currentSettings {
            notificationsEnabled = settings.notificationsEnabled
            notificationTimes = settings.notificationTimes
            selectedAppearance = settings.appearanceMode
            selectedLanguage = settings.preferredLanguage
            hapticFeedbackEnabled = settings.hapticFeedbackEnabled
        }
    }

    private func updateAppearance(_ mode: AppearanceMode) {
        if let settings = currentSettings {
            settings.appearanceMode = mode
            try? modelContext.save()
        }
    }

    private func updateLanguage(_ language: SupportedLanguage) {
        if let settings = currentSettings {
            settings.preferredLanguage = language
            try? modelContext.save()
        }
    }

    private func updateHapticSetting(enabled: Bool) {
        if let settings = currentSettings {
            settings.hapticFeedbackEnabled = enabled
            try? modelContext.save()
        }
    }

    private func updateNotificationSetting(enabled: Bool) {
        if enabled {
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    NotificationService.shared.scheduleNotifications(times: notificationTimes)
                }
            }
        } else {
            NotificationService.shared.cancelAllNotifications()
        }

        if let settings = currentSettings {
            settings.notificationsEnabled = enabled
            try? modelContext.save()
        }
    }

    private func updateNotificationTimes() {
        if let settings = currentSettings {
            settings.notificationTimes = notificationTimes
            try? modelContext.save()
        }

        if notificationsEnabled {
            NotificationService.shared.scheduleNotifications(times: notificationTimes)
        }
    }

    private func resetAllData() {
        let favoriteDescriptor = FetchDescriptor<UserFavorite>()
        let historyDescriptor = FetchDescriptor<ReadingHistory>()

        if let favorites = try? modelContext.fetch(favoriteDescriptor) {
            for favorite in favorites {
                modelContext.delete(favorite)
            }
        }

        if let history = try? modelContext.fetch(historyDescriptor) {
            for item in history {
                modelContext.delete(item)
            }
        }

        if let streak = currentStreak {
            streak.currentStreak = 0
            streak.longestStreak = 0
            streak.totalDaysActive = 0
            streak.lastActiveDate = Date()
        }

        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTokens.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("TextPrimary"))

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                .fill(Color("CardBackground"))
                .shadow(
                    color: .black.opacity(AppTokens.Shadow.light.opacity),
                    radius: AppTokens.Shadow.light.radius,
                    y: AppTokens.Shadow.light.y
                )
        )
    }
}

struct NotificationTimeRow: View {
    @Binding var time: NotificationTime
    let onUpdate: () -> Void

    @State private var showTimePicker = false

    var body: some View {
        HStack {
            Toggle(isOn: $time.isEnabled) {
                HStack {
                    Text(time.label)
                        .font(AppTokens.Typography.body)
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Button(action: { showTimePicker = true }) {
                        Text(time.timeString)
                            .font(AppTokens.Typography.caption)
                            .foregroundStyle(Color("AccentGreen"))
                    }
                }
            }
            .tint(Color("AccentGreen"))
            .onChange(of: time.isEnabled) { _, _ in
                onUpdate()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                .fill(Color("CardBackground"))
        )
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(time: $time, onDone: onUpdate)
        }
    }
}

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var time: NotificationTime
    let onDone: () -> Void

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Time",
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                #if os(iOS)
                .datePickerStyle(.wheel)
                #endif
                .labelsHidden()

                Spacer()
            }
            .padding()
            .navigationTitle("Set Time")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        let calendar = Calendar.current
                        time.hour = calendar.component(.hour, from: selectedDate)
                        time.minute = calendar.component(.minute, from: selectedDate)
                        onDone()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let calendar = Calendar.current
                        time.hour = calendar.component(.hour, from: selectedDate)
                        time.minute = calendar.component(.minute, from: selectedDate)
                        onDone()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                #endif
            }
            .onAppear {
                let calendar = Calendar.current
                var components = DateComponents()
                components.hour = time.hour
                components.minute = time.minute
                selectedDate = calendar.date(from: components) ?? Date()
            }
        }
    }
}

struct AboutRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(AppTokens.Typography.body)
                .foregroundStyle(Color("TextPrimary"))

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(Color("TextSecondary"))
        }
        .padding()
    }
}

struct DisclaimerSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                    disclaimerSection(
                        title: "Educational Purpose",
                        icon: "book.fill",
                        content: "Dhikir is provided for educational and spiritual enrichment purposes only. The content within this application is intended to assist Muslims in their personal practice of dhikir (remembrance of Allah) and is not intended to replace guidance from qualified Islamic scholars, formal Islamic education, or professional counseling."
                    )

                    disclaimerSection(
                        title: "No Religious Authority",
                        icon: "person.fill.questionmark",
                        content: "The developers of Dhikir do not claim to be Islamic scholars or religious authorities, do not issue religious rulings (fatawa), and do not represent any Islamic school of thought exclusively. Users should consult qualified Islamic scholars for religious guidance."
                    )

                    disclaimerSection(
                        title: "Source Accuracy",
                        icon: "checkmark.shield.fill",
                        content: "While we have made every effort to ensure accuracy, sources are provided for reference and verification purposes. Users are encouraged to verify all content with primary sources and qualified scholars. Translations are interpretive and may vary from other translations."
                    )

                    disclaimerSection(
                        title: "Mental Health",
                        icon: "heart.fill",
                        content: "Dhikir is not a substitute for professional mental health care. If you are experiencing a mental health crisis, please contact emergency services or a mental health professional. Content related to emotions is spiritual in nature, not clinical."
                    )

                    disclaimerSection(
                        title: "No Warranty",
                        icon: "exclamationmark.triangle.fill",
                        content: "The application is provided \"as is\" without warranty of any kind. To the maximum extent permitted by law, the developers shall not be liable for any damages arising from the use of this application."
                    )

                    VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                        Text("By using this app, you acknowledge that you have read and understood these disclaimers.")
                            .font(AppTokens.Typography.caption)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                            .fill(Color("AccentGreen").opacity(0.1))
                    )
                }
                .padding()
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("Disclaimer")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                #else
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                #endif
            }
        }
    }

    private func disclaimerSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            HStack(spacing: AppTokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(AppTokens.Typography.body)
                    .foregroundStyle(Color("AccentGreen"))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))
            }

            Text(content)
                .font(.system(size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .lineSpacing(AppTokens.Spacing.xs)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                .fill(Color("CardBackground"))
        )
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self, UserStreak.self, UserFavorite.self, ReadingHistory.self], inMemory: true)
}

#Preview("Disclaimer") {
    DisclaimerSheet()
}
