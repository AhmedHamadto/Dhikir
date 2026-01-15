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

    private var currentSettings: UserSettings? {
        settings.first
    }

    private var currentStreak: UserStreak? {
        streaks.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        streakSection

                        notificationSection

                        appearanceSection

                        hapticSection

                        languageSection

                        aboutSection

                        legalSection

                        resetSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadSettings()
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your favorites, history, and streak progress. This action cannot be undone.")
            }
            .sheet(isPresented: $showingDisclaimer) {
                DisclaimerSheet()
            }
        }
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            HStack(spacing: 20) {
                StatCard(
                    title: "Current Streak",
                    value: "\(currentStreak?.currentStreak ?? 0)",
                    icon: "flame.fill",
                    color: .orange
                )

                StatCard(
                    title: "Longest Streak",
                    value: "\(currentStreak?.longestStreak ?? 0)",
                    icon: "trophy.fill",
                    color: Color("AccentGold")
                )

                StatCard(
                    title: "Total Days",
                    value: "\(currentStreak?.totalDaysActive ?? 0)",
                    icon: "calendar",
                    color: Color("AccentGreen")
                )
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            VStack(spacing: 12) {
                Toggle(isOn: $notificationsEnabled) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(Color("AccentGreen"))
                        Text("Enable Notifications")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .tint(Color("AccentGreen"))
                .onChange(of: notificationsEnabled) { _, newValue in
                    updateNotificationSetting(enabled: newValue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardBackground"))
                )

                if notificationsEnabled {
                    VStack(spacing: 8) {
                        ForEach($notificationTimes) { $time in
                            NotificationTimeRow(time: $time) {
                                updateNotificationTimes()
                            }
                        }
                    }
                }
            }
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            HStack(spacing: 12) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Button(action: {
                        selectedAppearance = mode
                        updateAppearance(mode)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(selectedAppearance == mode ? Color("AccentGreen") : Color("TextSecondary"))

                            Text(mode.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(selectedAppearance == mode ? Color("AccentGreen") : Color("TextSecondary"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackground"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAppearance == mode ? Color("AccentGreen") : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var hapticSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feedback")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            Toggle(isOn: $hapticFeedbackEnabled) {
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundStyle(Color("AccentGreen"))
                    Text("Haptic Feedback")
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .tint(Color("AccentGreen"))
            .onChange(of: hapticFeedbackEnabled) { _, newValue in
                updateHapticSetting(enabled: newValue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackground"))
            )
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Translation Language")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(SupportedLanguage.allCases) { language in
                    Button(action: {
                        selectedLanguage = language
                        updateLanguage(language)
                    }) {
                        HStack(spacing: 8) {
                            Text(language.flag)
                                .font(.system(size: 20))

                            Text(language.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(selectedLanguage == language ? Color("AccentGreen") : Color("TextPrimary"))
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("CardBackground"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedLanguage == language ? Color("AccentGreen") : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            VStack(spacing: 0) {
                AboutRow(title: "Version", value: "1.0.0")
                Divider()
                AboutRow(title: "Dhikirs", value: "74+")
                Divider()
                AboutRow(title: "Sources", value: "Quran & Hadith")
                Divider()
                AboutRow(title: "Languages", value: "7")
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackground"))
            )
        }
    }

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Legal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            VStack(spacing: 0) {
                Button(action: { showingDisclaimer = true }) {
                    HStack {
                        Text("Disclaimer")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("TextPrimary"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackground"))
            )

            Text("This app is for educational and spiritual purposes only. Content should be verified with qualified Islamic scholars.")
                .font(.system(size: 12))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.leading)
        }
    }

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            Button(action: { showingResetAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                    Text("Reset All Data")
                        .foregroundStyle(Color.red)
                    Spacer()
                }
                .font(.system(size: 16, weight: .medium))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardBackground"))
                )
            }
        }
    }

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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
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
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
                .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Button(action: { showTimePicker = true }) {
                        Text(time.timeString)
                            .font(.system(size: 14, weight: .medium))
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
            RoundedRectangle(cornerRadius: 12)
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
                .datePickerStyle(.wheel)
                .labelsHidden()

                Spacer()
            }
            .padding()
            .navigationTitle("Set Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                .font(.system(size: 16, weight: .medium))
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
                VStack(alignment: .leading, spacing: 20) {
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("By using this app, you acknowledge that you have read and understood these disclaimers.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("AccentGreen").opacity(0.1))
                    )
                }
                .padding()
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func disclaimerSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color("AccentGreen"))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))
            }

            Text(content)
                .font(.system(size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
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
