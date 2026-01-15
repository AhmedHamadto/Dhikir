import XCTest
import SwiftUI
@testable import Dhikir

final class EmotionalStateTests: XCTestCase {

    // MARK: - Emotional State Tests

    func testEmotionalStateCount() {
        XCTAssertEqual(EmotionalState.allCases.count, 10)
    }

    func testEmotionalStateRawValues() {
        XCTAssertEqual(EmotionalState.anxious.rawValue, "anxious")
        XCTAssertEqual(EmotionalState.sad.rawValue, "sad")
        XCTAssertEqual(EmotionalState.angry.rawValue, "angry")
        XCTAssertEqual(EmotionalState.grateful.rawValue, "grateful")
        XCTAssertEqual(EmotionalState.hopeful.rawValue, "hopeful")
        XCTAssertEqual(EmotionalState.lonely.rawValue, "lonely")
        XCTAssertEqual(EmotionalState.overwhelmed.rawValue, "overwhelmed")
        XCTAssertEqual(EmotionalState.fearful.rawValue, "fearful")
        XCTAssertEqual(EmotionalState.joyful.rawValue, "joyful")
        XCTAssertEqual(EmotionalState.lost.rawValue, "lost")
    }

    func testEmotionalStateDisplayNames() {
        XCTAssertEqual(EmotionalState.anxious.displayName, "Anxious")
        XCTAssertEqual(EmotionalState.sad.displayName, "Sad")
        XCTAssertEqual(EmotionalState.grateful.displayName, "Grateful")
    }

    func testEmotionalStateArabicNames() {
        XCTAssertEqual(EmotionalState.anxious.arabicName, "قلق")
        XCTAssertEqual(EmotionalState.sad.arabicName, "حزين")
        XCTAssertEqual(EmotionalState.grateful.arabicName, "شاكر")
    }

    func testEmotionalStateIcons() {
        XCTAssertEqual(EmotionalState.anxious.icon, "wind")
        XCTAssertEqual(EmotionalState.sad.icon, "cloud.rain")
        XCTAssertEqual(EmotionalState.angry.icon, "flame")
        XCTAssertEqual(EmotionalState.grateful.icon, "hands.clap")
    }

    func testEmotionalStateHasDescriptions() {
        for state in EmotionalState.allCases {
            XCTAssertFalse(state.description.isEmpty, "\(state) should have a description")
        }
    }

    func testEmotionalStateIdentifiable() {
        let state = EmotionalState.anxious
        XCTAssertEqual(state.id, state.rawValue)
    }

    // MARK: - Life Situation Tests

    func testLifeSituationCount() {
        XCTAssertEqual(LifeSituation.allCases.count, 10)
    }

    func testLifeSituationRawValues() {
        XCTAssertEqual(LifeSituation.morning.rawValue, "morning")
        XCTAssertEqual(LifeSituation.evening.rawValue, "evening")
        XCTAssertEqual(LifeSituation.beforeSleep.rawValue, "before_sleep")
        XCTAssertEqual(LifeSituation.uponWaking.rawValue, "upon_waking")
        XCTAssertEqual(LifeSituation.duringIllness.rawValue, "during_illness")
        XCTAssertEqual(LifeSituation.traveling.rawValue, "traveling")
        XCTAssertEqual(LifeSituation.facingDifficulty.rawValue, "facing_difficulty")
        XCTAssertEqual(LifeSituation.beforeDecision.rawValue, "before_decision")
        XCTAssertEqual(LifeSituation.afterSalah.rawValue, "after_salah")
        XCTAssertEqual(LifeSituation.seekingForgiveness.rawValue, "seeking_forgiveness")
    }

    func testLifeSituationDisplayNames() {
        XCTAssertEqual(LifeSituation.morning.displayName, "Morning")
        XCTAssertEqual(LifeSituation.beforeSleep.displayName, "Before Sleep")
        XCTAssertEqual(LifeSituation.afterSalah.displayName, "After Salah")
    }

    func testLifeSituationArabicNames() {
        XCTAssertEqual(LifeSituation.morning.arabicName, "الصباح")
        XCTAssertEqual(LifeSituation.evening.arabicName, "المساء")
        XCTAssertEqual(LifeSituation.seekingForgiveness.arabicName, "الاستغفار")
    }

    func testLifeSituationIcons() {
        XCTAssertEqual(LifeSituation.morning.icon, "sunrise")
        XCTAssertEqual(LifeSituation.evening.icon, "sunset")
        XCTAssertEqual(LifeSituation.beforeSleep.icon, "moon.stars")
        XCTAssertEqual(LifeSituation.traveling.icon, "airplane")
    }

    func testLifeSituationHasDescriptions() {
        for situation in LifeSituation.allCases {
            XCTAssertFalse(situation.description.isEmpty, "\(situation) should have a description")
        }
    }

    func testLifeSituationIdentifiable() {
        let situation = LifeSituation.morning
        XCTAssertEqual(situation.id, situation.rawValue)
    }
}
