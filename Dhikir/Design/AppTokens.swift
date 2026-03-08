import SwiftUI

enum AppTokens {
    enum Typography {
        static let appTitle = Font.system(size: 28, weight: .bold, design: .serif)
        static let callToAction = Font.system(size: 22, weight: .semibold)
        static let heading = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 16)
        static let bodyMedium = Font.system(size: 16, weight: .medium)
        static let bodySemibold = Font.system(size: 16, weight: .semibold)
        static let caption = Font.system(size: 14, weight: .medium)
        static let captionSemibold = Font.system(size: 14, weight: .semibold)
        static let small = Font.system(size: 12, weight: .medium)
        static let smallSemibold = Font.system(size: 12, weight: .semibold)
        static let arabic = Font.system(size: 32, weight: .medium)
        static let arabicSmall = Font.system(size: 18, weight: .medium)
        static let transliteration = Font.system(size: 18, weight: .medium, design: .serif)
        static let counter = Font.system(size: 28, weight: .bold)
        static let counterLarge = Font.system(size: 36, weight: .bold)
        static let counterSmall = Font.system(size: 14, weight: .medium)
        static let bodySmall = Font.system(size: 14)
        static let icon = Font.system(size: 20)
        static let iconSmall = Font.system(size: 16, weight: .medium)
        static let emptyStateIcon = Font.system(size: 60)
    }

    enum IconSize {
        static let medium: CGFloat = 28
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
    }

    enum Shadow {
        static let light = (radius: CGFloat(6), y: CGFloat(3), opacity: 0.03)
        static let medium = (radius: CGFloat(8), y: CGFloat(4), opacity: 0.05)
        static let heavy = (radius: CGFloat(10), y: CGFloat(5), opacity: 0.05)
    }

    enum Counter {
        static let floatingSize: CGFloat = 80
        static let inlineSize: CGFloat = 120
        static let strokeWidth: CGFloat = 6
        static let inlineStrokeWidth: CGFloat = 8
    }
}
