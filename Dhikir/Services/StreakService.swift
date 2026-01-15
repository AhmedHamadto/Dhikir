import Foundation
import SwiftData

final class StreakService {
    static let shared = StreakService()

    private init() {}

    func recordActivity(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<UserStreak>()

        do {
            let streaks = try context.fetch(fetchDescriptor)
            guard let streak = streaks.first else {
                let newStreak = UserStreak(currentStreak: 1, longestStreak: 1, totalDaysActive: 1)
                context.insert(newStreak)
                try context.save()
                return
            }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lastActive = calendar.startOfDay(for: streak.lastActiveDate)

            if today == lastActive {
                return
            }

            let daysDifference = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0

            if daysDifference == 1 {
                streak.currentStreak += 1
            } else {
                streak.currentStreak = 1
            }

            if streak.currentStreak > streak.longestStreak {
                streak.longestStreak = streak.currentStreak
            }

            streak.totalDaysActive += 1
            streak.lastActiveDate = Date()

            try context.save()
        } catch {
            print("Failed to record activity: \(error)")
        }
    }

    func getStreak(context: ModelContext) -> UserStreak? {
        let fetchDescriptor = FetchDescriptor<UserStreak>()
        return try? context.fetch(fetchDescriptor).first
    }

    func streakMilestone(for streak: Int) -> String? {
        switch streak {
        case 7: return "1 Week"
        case 14: return "2 Weeks"
        case 30: return "1 Month"
        case 60: return "2 Months"
        case 90: return "3 Months"
        case 180: return "6 Months"
        case 365: return "1 Year"
        default: return nil
        }
    }
}
