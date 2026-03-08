import SwiftUI
import Foundation

struct EmotionButton: View {
    let title: String
    let arabicTitle: String
    let icon: String
    let color: Color
    let description: String
    var compact: Bool = false
    var hapticEnabled: Bool = true
    let action: () -> Void

    @State private var isPressed = false

    private var iconSize: CGFloat { compact ? 40 : 50 }
    private var iconFontSize: CGFloat { compact ? 18 : 22 }
    private var titleFontSize: CGFloat { compact ? 12 : 14 }
    private var arabicFontSize: CGFloat { compact ? 10 : 12 }
    private var verticalPadding: CGFloat { compact ? 12 : 16 }

    var body: some View {
        Button(action: {
            if hapticEnabled {
                triggerHaptic(.medium)
            }
            action()
        }) {
            VStack(spacing: AppTokens.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: iconSize, height: iconSize)

                    Image(systemName: icon)
                        .font(.system(size: iconFontSize))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(.system(size: titleFontSize, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))

                Text(arabicTitle)
                    .font(.system(size: arabicFontSize, weight: .medium))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(AppTokens.Shadow.medium.opacity), radius: AppTokens.Shadow.medium.radius, y: AppTokens.Shadow.medium.y)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title), \(arabicTitle)")
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    EmotionButton(
        title: "Anxious",
        arabicTitle: "قلق",
        icon: "wind",
        color: Color.blue,
        description: "Find peace"
    ) {}
    .padding()
    .background(Color("BackgroundCream"))
}
