import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let notificationMessages = [
        "Salaam! How is your heart feeling right now?",
        "Peace be upon you. Take a gentle moment with Allah.",
        "A moment of dhikir awaits. How are you feeling?",
        "Salaam! Your heart deserves a peaceful moment.",
        "Take a breath. How are you feeling right now?",
        "A gentle reminder to check in with yourself.",
        "Salaam! Let's find some peace together.",
        "Your soul is calling. How do you feel?"
    ]

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            return granted
        } catch {
            #if DEBUG
            print("Notification authorization error: \(error)")
            #endif
            return false
        }
    }

    func scheduleNotifications(times: [NotificationTime]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for time in times where time.isEnabled {
            scheduleNotification(for: time)
        }
    }

    private func scheduleNotification(for time: NotificationTime) {
        let content = UNMutableNotificationContent()
        content.title = "Dhikir"
        content.body = notificationMessages.randomElement() ?? notificationMessages[0]
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: time.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
            #endif
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
