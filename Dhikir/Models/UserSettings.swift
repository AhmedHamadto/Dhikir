import Foundation
import SwiftData

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var notificationsEnabled: Bool
    var notificationTimes: [NotificationTime]
    var hasCompletedOnboarding: Bool
    var preferredLanguage: String
    var hapticFeedbackEnabled: Bool

    init(
        id: UUID = UUID(),
        notificationsEnabled: Bool = true,
        notificationTimes: [NotificationTime] = NotificationTime.defaults,
        hasCompletedOnboarding: Bool = false,
        preferredLanguage: String = "en",
        hapticFeedbackEnabled: Bool = true
    ) {
        self.id = id
        self.notificationsEnabled = notificationsEnabled
        self.notificationTimes = notificationTimes
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.preferredLanguage = preferredLanguage
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
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
