import Foundation
import SwiftData
import SwiftUI

enum AppearanceMode: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var notificationsEnabled: Bool = true
    var notificationTimes: [NotificationTime] = NotificationTime.defaults
    var hasCompletedOnboarding: Bool = false
    var preferredLanguageRaw: String = "en"
    var hapticFeedbackEnabled: Bool = true
    var appearanceModeRaw: String = "System"

    var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRaw) ?? .system }
        set { appearanceModeRaw = newValue.rawValue }
    }

    var preferredLanguage: SupportedLanguage {
        get { SupportedLanguage(rawValue: preferredLanguageRaw) ?? .english }
        set { preferredLanguageRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        notificationsEnabled: Bool = true,
        notificationTimes: [NotificationTime] = NotificationTime.defaults,
        hasCompletedOnboarding: Bool = false,
        preferredLanguage: SupportedLanguage = .english,
        hapticFeedbackEnabled: Bool = true,
        appearanceMode: AppearanceMode = .system
    ) {
        self.id = id
        self.notificationsEnabled = notificationsEnabled
        self.notificationTimes = notificationTimes
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.preferredLanguageRaw = preferredLanguage.rawValue
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.appearanceModeRaw = appearanceMode.rawValue
    }
}

struct NotificationTime: Codable, Identifiable, Equatable {
    var id: UUID
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var label: String

    init(id: UUID = UUID(), hour: Int, minute: Int, isEnabled: Bool = true, label: String) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.label = label
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let calendar = Calendar.current
        let components = DateComponents(hour: hour, minute: minute)
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }

    static var defaults: [NotificationTime] {
        [
            NotificationTime(hour: 6, minute: 30, label: "Fajr time"),
            NotificationTime(hour: 9, minute: 0, label: "Morning"),
            NotificationTime(hour: 13, minute: 0, label: "Afternoon"),
            NotificationTime(hour: 17, minute: 0, label: "Asr time"),
            NotificationTime(hour: 21, minute: 0, label: "Evening")
        ]
    }
}
