import SwiftUI

struct CardModifier: ViewModifier {
    var shadow: (radius: CGFloat, y: CGFloat, opacity: Double) = AppTokens.Shadow.medium
    var radius: CGFloat = AppTokens.Radius.large

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(shadow.opacity), radius: shadow.radius, y: shadow.y)
            )
    }
}

extension View {
    func cardBackground(
        shadow: (radius: CGFloat, y: CGFloat, opacity: Double) = AppTokens.Shadow.medium,
        radius: CGFloat = AppTokens.Radius.large
    ) -> some View {
        modifier(CardModifier(shadow: shadow, radius: radius))
    }
}
