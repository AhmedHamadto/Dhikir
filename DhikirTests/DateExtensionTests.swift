import XCTest
@testable import Dhikir

final class DateExtensionTests: XCTestCase {

    func testStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testIsToday() {
        let today = Date()
        XCTAssertTrue(today.isToday)

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertFalse(yesterday.isToday)
    }

    func testIsYesterday() {
        let today = Date()
        XCTAssertFalse(today.isYesterday)

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertTrue(yesterday.isYesterday)
    }

    func testDaysBetween() {
        let today = Date()
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)!

        let daysBetween = fiveDaysAgo.daysBetween(today)
        XCTAssertEqual(daysBetween, 5)
    }

    func testDaysBetweenSameDay() {
        let today = Date()
        let daysBetween = today.daysBetween(today)
        XCTAssertEqual(daysBetween, 0)
    }

    func testFormatted() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15

        let date = calendar.date(from: components)!
        let formatted = date.formatted(as: "yyyy-MM-dd")

        XCTAssertEqual(formatted, "2024-06-15")
    }

    func testDateNow() {
        let dateNow = Date()
        let currentDate = Date()

        // Should be within a second of each other
        let difference = abs(dateNow.timeIntervalSince(currentDate))
        XCTAssertLessThan(difference, 1.0)
    }
}
