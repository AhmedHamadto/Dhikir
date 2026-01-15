import Foundation
import SwiftData

@Model
final class UserStreak {
    @Attribute(.unique) var id: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date
    var totalDaysActive: Int

    init(
        id: UUID = UUID(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActiveDate: Date = Date(),
        totalDaysActive: Int = 0
    ) {
        self.id = id
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDate = lastActiveDate
        self.totalDaysActive = totalDaysActive
    }
}
