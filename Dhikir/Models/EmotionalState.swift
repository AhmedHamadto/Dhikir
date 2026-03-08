import Foundation
import SwiftUI

enum EmotionalState: String, CaseIterable, Identifiable {
    case anxious = "anxious"
    case sad = "sad"
    case angry = "angry"
    case grateful = "grateful"
    case hopeful = "hopeful"
    case lonely = "lonely"
    case overwhelmed = "overwhelmed"
    case fearful = "fearful"
    case joyful = "joyful"
    case lost = "lost"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .anxious: return "Anxious"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .grateful: return "Grateful"
        case .hopeful: return "Hopeful"
        case .lonely: return "Lonely"
        case .overwhelmed: return "Overwhelmed"
        case .fearful: return "Fearful"
        case .joyful: return "Joyful"
        case .lost: return "Lost"
        }
    }

    var arabicName: String {
        switch self {
        case .anxious: return "قلق"
        case .sad: return "حزين"
        case .angry: return "غاضب"
        case .grateful: return "شاكر"
        case .hopeful: return "متفائل"
        case .lonely: return "وحيد"
        case .overwhelmed: return "مرهق"
        case .fearful: return "خائف"
        case .joyful: return "فرحان"
        case .lost: return "تائه"
        }
    }

    var icon: String {
        switch self {
        case .anxious: return "leaf.fill"
        case .sad: return "drop.fill"
        case .angry: return "flame.fill"
        case .grateful: return "hand.raised.fill"
        case .hopeful: return "sunrise.fill"
        case .lonely: return "moon.stars.fill"
        case .overwhelmed: return "water.waves"
        case .fearful: return "shield.lefthalf.filled"
        case .joyful: return "star.fill"
        case .lost: return "safari"
        }
    }

    var color: Color {
        switch self {
        case .anxious: return Color(red: 0.6, green: 0.7, blue: 0.8)
        case .sad: return Color(red: 0.5, green: 0.6, blue: 0.7)
        case .angry: return Color(red: 0.8, green: 0.5, blue: 0.4)
        case .grateful: return Color(red: 0.7, green: 0.8, blue: 0.6)
        case .hopeful: return Color(red: 0.9, green: 0.8, blue: 0.5)
        case .lonely: return Color(red: 0.6, green: 0.6, blue: 0.7)
        case .overwhelmed: return Color(red: 0.7, green: 0.6, blue: 0.7)
        case .fearful: return Color(red: 0.6, green: 0.5, blue: 0.6)
        case .joyful: return Color(red: 0.9, green: 0.7, blue: 0.5)
        case .lost: return Color(red: 0.7, green: 0.7, blue: 0.7)
        }
    }

    var description: String {
        switch self {
        case .anxious: return "Find peace and tranquility"
        case .sad: return "Seek comfort and hope"
        case .angry: return "Find calm and patience"
        case .grateful: return "Express your thankfulness"
        case .hopeful: return "Strengthen your trust"
        case .lonely: return "Remember Allah's companionship"
        case .overwhelmed: return "Find ease and relief"
        case .fearful: return "Seek protection and courage"
        case .joyful: return "Share your happiness"
        case .lost: return "Seek guidance and clarity"
        }
    }

    func displayName(for language: SupportedLanguage) -> String {
        let key: AppString = switch self {
        case .anxious: .emotionAnxious
        case .sad: .emotionSad
        case .angry: .emotionAngry
        case .grateful: .emotionGrateful
        case .hopeful: .emotionHopeful
        case .lonely: .emotionLonely
        case .overwhelmed: .emotionOverwhelmed
        case .fearful: .emotionFearful
        case .joyful: .emotionJoyful
        case .lost: .emotionLost
        }
        return L(key, language)
    }

    func description(for language: SupportedLanguage) -> String {
        let key: AppString = switch self {
        case .anxious: .emotionAnxiousDesc
        case .sad: .emotionSadDesc
        case .angry: .emotionAngryDesc
        case .grateful: .emotionGratefulDesc
        case .hopeful: .emotionHopefulDesc
        case .lonely: .emotionLonelyDesc
        case .overwhelmed: .emotionOverwhelmedDesc
        case .fearful: .emotionFearfulDesc
        case .joyful: .emotionJoyfulDesc
        case .lost: .emotionLostDesc
        }
        return L(key, language)
    }
}
