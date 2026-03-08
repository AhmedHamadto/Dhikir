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
        XCTAssertEqual(EmotionalState.anxious.icon, "leaf.fill")
        XCTAssertEqual(EmotionalState.sad.icon, "drop.fill")
        XCTAssertEqual(EmotionalState.angry.icon, "flame.fill")
        XCTAssertEqual(EmotionalState.grateful.icon, "hand.raised.fill")
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
        XCTAssertEqual(LifeSituation.allCases.count, 5)
    }

    func testLifeSituationRawValues() {
        XCTAssertEqual(LifeSituation.duringIllness.rawValue, "during_illness")
        XCTAssertEqual(LifeSituation.traveling.rawValue, "traveling")
        XCTAssertEqual(LifeSituation.facingDifficulty.rawValue, "facing_difficulty")
        XCTAssertEqual(LifeSituation.beforeDecision.rawValue, "before_decision")
        XCTAssertEqual(LifeSituation.seekingForgiveness.rawValue, "seeking_forgiveness")
    }

    func testLifeSituationDisplayNames() {
        XCTAssertEqual(LifeSituation.duringIllness.displayName, "During Illness")
        XCTAssertEqual(LifeSituation.traveling.displayName, "Traveling")
        XCTAssertEqual(LifeSituation.seekingForgiveness.displayName, "Seeking Forgiveness")
    }

    func testLifeSituationArabicNames() {
        XCTAssertEqual(LifeSituation.duringIllness.arabicName, "عند المرض")
        XCTAssertEqual(LifeSituation.traveling.arabicName, "السفر")
        XCTAssertEqual(LifeSituation.seekingForgiveness.arabicName, "الاستغفار")
    }

    func testLifeSituationIcons() {
        XCTAssertEqual(LifeSituation.duringIllness.icon, "heart.circle.fill")
        XCTAssertEqual(LifeSituation.traveling.icon, "airplane.departure")
        XCTAssertEqual(LifeSituation.facingDifficulty.icon, "mountain.2.fill")
    }

    func testLifeSituationHasDescriptions() {
        for situation in LifeSituation.allCases {
            XCTAssertFalse(situation.description.isEmpty, "\(situation) should have a description")
        }
    }

    func testLifeSituationIdentifiable() {
        let situation = LifeSituation.duringIllness
        XCTAssertEqual(situation.id, situation.rawValue)
    }
}
