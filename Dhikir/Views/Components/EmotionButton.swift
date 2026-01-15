import SwiftUI

struct EmotionButton: View {
    let title: String
    let arabicTitle: String
    let icon: String
    let color: Color
    let description: String
    var hapticEnabled: Bool = true
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if hapticEnabled {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))

                Text(arabicTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
