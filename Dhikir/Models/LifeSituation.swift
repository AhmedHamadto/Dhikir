import Foundation
import SwiftUI

enum LifeSituation: String, CaseIterable, Identifiable {
    case morning = "morning"
    case evening = "evening"
    case beforeSleep = "before_sleep"
    case uponWaking = "upon_waking"
    case duringIllness = "during_illness"
    case traveling = "traveling"
    case facingDifficulty = "facing_difficulty"
    case beforeDecision = "before_decision"
    case afterSalah = "after_salah"
    case seekingForgiveness = "seeking_forgiveness"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .evening: return "Evening"
        case .beforeSleep: return "Before Sleep"
        case .uponWaking: return "Upon Waking"
        case .duringIllness: return "During Illness"
        case .traveling: return "Traveling"
        case .facingDifficulty: return "Facing Difficulty"
        case .beforeDecision: return "Before a Decision"
        case .afterSalah: return "After Salah"
        case .seekingForgiveness: return "Seeking Forgiveness"
        }
    }

    var arabicName: String {
        switch self {
        case .morning: return "الصباح"
        case .evening: return "المساء"
        case .beforeSleep: return "قبل النوم"
        case .uponWaking: return "عند الاستيقاظ"
        case .duringIllness: return "عند المرض"
        case .traveling: return "السفر"
        case .facingDifficulty: return "عند الشدة"
        case .beforeDecision: return "قبل القرار"
        case .afterSalah: return "بعد الصلاة"
        case .seekingForgiveness: return "الاستغفار"
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise"
        case .evening: return "sunset"
        case .beforeSleep: return "moon.stars"
        case .uponWaking: return "sun.and.horizon"
        case .duringIllness: return "heart.text.square"
        case .traveling: return "airplane"
        case .facingDifficulty: return "mountain.2"
        case .beforeDecision: return "arrow.triangle.branch"
        case .afterSalah: return "hands.and.sparkles"
        case .seekingForgiveness: return "arrow.uturn.backward.circle"
        }
    }

    var color: Color {
        switch self {
        case .morning: return Color(red: 1.0, green: 0.85, blue: 0.6)
        case .evening: return Color(red: 0.8, green: 0.6, blue: 0.7)
        case .beforeSleep: return Color(red: 0.4, green: 0.5, blue: 0.7)
        case .uponWaking: return Color(red: 0.9, green: 0.8, blue: 0.6)
        case .duringIllness: return Color(red: 0.7, green: 0.8, blue: 0.7)
        case .traveling: return Color(red: 0.6, green: 0.8, blue: 0.9)
        case .facingDifficulty: return Color(red: 0.6, green: 0.6, blue: 0.7)
        case .beforeDecision: return Color(red: 0.7, green: 0.7, blue: 0.8)
        case .afterSalah: return Color(red: 0.6, green: 0.8, blue: 0.7)
        case .seekingForgiveness: return Color(red: 0.7, green: 0.8, blue: 0.8)
        }
    }

    var description: String {
        switch self {
        case .morning: return "Start your day with remembrance"
        case .evening: return "End your day peacefully"
        case .beforeSleep: return "Prepare for restful sleep"
        case .uponWaking: return "Thank Allah for a new day"
        case .duringIllness: return "Seek healing and patience"
        case .traveling: return "Protection for your journey"
        case .facingDifficulty: return "Strength through hardship"
        case .beforeDecision: return "Seek divine guidance"
        case .afterSalah: return "Complete your prayer"
        case .seekingForgiveness: return "Return to Allah"
        }
    }
}
