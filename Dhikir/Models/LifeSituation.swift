import Foundation
import SwiftUI

enum LifeSituation: String, CaseIterable, Identifiable {
    // Temporarily disabled: morning, evening, beforeSleep, afterSalah
    case uponWaking = "upon_waking"
    case duringIllness = "during_illness"
    case traveling = "traveling"
    case facingDifficulty = "facing_difficulty"
    case beforeDecision = "before_decision"
    case seekingForgiveness = "seeking_forgiveness"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .uponWaking: return "Upon Waking"
        case .duringIllness: return "During Illness"
        case .traveling: return "Traveling"
        case .facingDifficulty: return "Facing Difficulty"
        case .beforeDecision: return "Before a Decision"
        case .seekingForgiveness: return "Seeking Forgiveness"
        }
    }

    var arabicName: String {
        switch self {
        case .uponWaking: return "عند الاستيقاظ"
        case .duringIllness: return "عند المرض"
        case .traveling: return "السفر"
        case .facingDifficulty: return "عند الشدة"
        case .beforeDecision: return "قبل القرار"
        case .seekingForgiveness: return "الاستغفار"
        }
    }

    var icon: String {
        switch self {
        case .uponWaking: return "sun.max.fill"
        case .duringIllness: return "heart.circle.fill"
        case .traveling: return "airplane.departure"
        case .facingDifficulty: return "mountain.2.fill"
        case .beforeDecision: return "hand.raised.fill"
        case .seekingForgiveness: return "arrow.trianglehead.counterclockwise"
        }
    }

    var color: Color {
        switch self {
        case .uponWaking: return Color(red: 0.9, green: 0.8, blue: 0.6)
        case .duringIllness: return Color(red: 0.7, green: 0.8, blue: 0.7)
        case .traveling: return Color(red: 0.6, green: 0.8, blue: 0.9)
        case .facingDifficulty: return Color(red: 0.6, green: 0.6, blue: 0.7)
        case .beforeDecision: return Color(red: 0.7, green: 0.7, blue: 0.8)
        case .seekingForgiveness: return Color(red: 0.7, green: 0.8, blue: 0.8)
        }
    }

    var description: String {
        switch self {
        case .uponWaking: return "Thank Allah for a new day"
        case .duringIllness: return "Seek healing and patience"
        case .traveling: return "Protection for your journey"
        case .facingDifficulty: return "Strength through hardship"
        case .beforeDecision: return "Seek divine guidance"
        case .seekingForgiveness: return "Return to Allah"
        }
    }
}
