import SwiftUI

struct PillProgressIndicator: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: AppTokens.Spacing.sm) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color("AccentGreen") : Color.gray.opacity(0.3))
                    .frame(
                        width: index == current ? 20 : 6,
                        height: index == current ? 8 : 6
                    )
                    .animation(.easeInOut(duration: 0.2), value: current)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dhikir \(current + 1) of \(count)")
    }
}
