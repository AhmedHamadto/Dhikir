import XCTest
@testable import Dhikir

final class AppTokensTests: XCTestCase {

    func testTypographyTokensExist() {
        XCTAssertNotNil(AppTokens.Typography.appTitle)
        XCTAssertNotNil(AppTokens.Typography.callToAction)
        XCTAssertNotNil(AppTokens.Typography.heading)
        XCTAssertNotNil(AppTokens.Typography.body)
        XCTAssertNotNil(AppTokens.Typography.caption)
        XCTAssertNotNil(AppTokens.Typography.small)
        XCTAssertNotNil(AppTokens.Typography.arabic)
        XCTAssertNotNil(AppTokens.Typography.arabicSmall)
        XCTAssertNotNil(AppTokens.Typography.transliteration)
        XCTAssertNotNil(AppTokens.Typography.counter)
        XCTAssertNotNil(AppTokens.Typography.counterSmall)
    }

    func testSpacingTokenValues() {
        XCTAssertEqual(AppTokens.Spacing.xs, 4)
        XCTAssertEqual(AppTokens.Spacing.sm, 8)
        XCTAssertEqual(AppTokens.Spacing.md, 12)
        XCTAssertEqual(AppTokens.Spacing.lg, 16)
        XCTAssertEqual(AppTokens.Spacing.xl, 24)
        XCTAssertEqual(AppTokens.Spacing.xxl, 32)
    }

    func testRadiusTokenValues() {
        XCTAssertEqual(AppTokens.Radius.small, 10)
        XCTAssertEqual(AppTokens.Radius.medium, 12)
        XCTAssertEqual(AppTokens.Radius.large, 16)
        XCTAssertEqual(AppTokens.Radius.xl, 20)
    }

    func testCounterTokenValues() {
        XCTAssertEqual(AppTokens.Counter.floatingSize, 80)
        XCTAssertEqual(AppTokens.Counter.inlineSize, 120)
        XCTAssertEqual(AppTokens.Counter.strokeWidth, 6)
    }

    func testShadowTokenValues() {
        XCTAssertEqual(AppTokens.Shadow.light.radius, 6)
        XCTAssertEqual(AppTokens.Shadow.light.y, 3)
        XCTAssertEqual(AppTokens.Shadow.light.opacity, 0.03)
        XCTAssertEqual(AppTokens.Shadow.medium.radius, 8)
        XCTAssertEqual(AppTokens.Shadow.medium.y, 4)
        XCTAssertEqual(AppTokens.Shadow.medium.opacity, 0.05)
    }
}
