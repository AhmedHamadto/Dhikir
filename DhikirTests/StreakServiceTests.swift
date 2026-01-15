import XCTest
import SwiftData
@testable import Dhikir

@MainActor
final class StreakServiceTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([
            Dhikir.self,
            UserFavorite.self,
            ReadingHistory.self,
            UserStreak.self,
            UserSettings.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Streak Milestone Tests

    func testStreakMilestoneOneWeek() {
        let milestone = StreakService.shared.streakMilestone(for: 7)
        XCTAssertEqual(milestone, "1 Week")
    }

    func testStreakMilestoneTwoWeeks() {
        let milestone = StreakService.shared.streakMilestone(for: 14)
        XCTAssertEqual(milestone, "2 Weeks")
    }

    func testStreakMilestoneOneMonth() {
        let milestone = StreakService.shared.streakMilestone(for: 30)
        XCTAssertEqual(milestone, "1 Month")
    }

    func testStreakMilestoneTwoMonths() {
        let milestone = StreakService.shared.streakMilestone(for: 60)
        XCTAssertEqual(milestone, "2 Months")
    }

    func testStreakMilestoneThreeMonths() {
        let milestone = StreakService.shared.streakMilestone(for: 90)
        XCTAssertEqual(milestone, "3 Months")
    }

    func testStreakMilestoneSixMonths() {
        let milestone = StreakService.shared.streakMilestone(for: 180)
        XCTAssertEqual(milestone, "6 Months")
    }

    func testStreakMilestoneOneYear() {
        let milestone = StreakService.shared.streakMilestone(for: 365)
        XCTAssertEqual(milestone, "1 Year")
    }

    func testStreakMilestoneNonMilestone() {
        let milestone = StreakService.shared.streakMilestone(for: 5)
        XCTAssertNil(milestone)
    }

    func testStreakMilestoneZero() {
        let milestone = StreakService.shared.streakMilestone(for: 0)
        XCTAssertNil(milestone)
    }

    // MARK: - Get Streak Tests

    func testGetStreakWhenNoStreak() {
        let streak = StreakService.shared.getStreak(context: modelContext)
        XCTAssertNil(streak)
    }

    func testGetStreakWhenStreakExists() throws {
        let streak = UserStreak(currentStreak: 5, longestStreak: 10, totalDaysActive: 20)
        modelContext.insert(streak)
        try modelContext.save()

        let fetchedStreak = StreakService.shared.getStreak(context: modelContext)
        XCTAssertNotNil(fetchedStreak)
        XCTAssertEqual(fetchedStreak?.currentStreak, 5)
        XCTAssertEqual(fetchedStreak?.longestStreak, 10)
        XCTAssertEqual(fetchedStreak?.totalDaysActive, 20)
    }

    // MARK: - Record Activity Tests

    func testRecordActivityCreatesNewStreak() throws {
        StreakService.shared.recordActivity(context: modelContext)

        let fetchDescriptor = FetchDescriptor<UserStreak>()
        let streaks = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(streaks.count, 1)
        XCTAssertEqual(streaks.first?.currentStreak, 1)
        XCTAssertEqual(streaks.first?.longestStreak, 1)
        XCTAssertEqual(streaks.first?.totalDaysActive, 1)
    }

    func testRecordActivitySameDayNoChange() throws {
        let streak = UserStreak(currentStreak: 5, longestStreak: 5, totalDaysActive: 5)
        streak.lastActiveDate = Date()
        modelContext.insert(streak)
        try modelContext.save()

        StreakService.shared.recordActivity(context: modelContext)

        let fetchDescriptor = FetchDescriptor<UserStreak>()
        let streaks = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(streaks.first?.currentStreak, 5)
        XCTAssertEqual(streaks.first?.totalDaysActive, 5)
    }
}
