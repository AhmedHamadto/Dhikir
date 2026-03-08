import SwiftUI

struct FloatingCounter: View {
    let count: Int
    let target: Int
    let onTap: () -> Void
    var onNext: (() -> Void)?
    var hasNext: Bool = false
    var language: SupportedLanguage = .english

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulseScale: CGFloat = 1.0
    @State private var showNext = false

    private var progress: Double {
        guard target > 0 else { return 0 }
        return Double(count) / Double(target)
    }

    private var isComplete: Bool { count >= target }

    var body: some View {
        VStack(spacing: AppTokens.Spacing.sm) {
            Button(action: {
                onTap()
                if !reduceMotion {
                    withAnimation(.spring(response: 0.2)) {
                        pulseScale = 1.15
                    }
                    withAnimation(.spring(response: 0.2).delay(0.1)) {
                        pulseScale = 1.0
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(Color("AccentGreen").opacity(0.3), lineWidth: AppTokens.Counter.strokeWidth)
                        .frame(width: AppTokens.Counter.floatingSize, height: AppTokens.Counter.floatingSize)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color("AccentGreen"), style: StrokeStyle(lineWidth: AppTokens.Counter.strokeWidth, lineCap: .round))
                        .frame(width: AppTokens.Counter.floatingSize, height: AppTokens.Counter.floatingSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)

                    VStack(spacing: AppTokens.Spacing.xs) {
                        Text("\(count)")
                            .font(AppTokens.Typography.counter)
                            .foregroundStyle(Color("TextPrimary"))

                        Text("/ \(target)")
                            .font(AppTokens.Typography.counterSmall)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
                .scaleEffect(pulseScale)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(L(.tapToCount, language))
            .accessibilityValue("\(count) / \(target)")
            .accessibilityHint(L(.tapToCount, language))

            if isComplete {
                Text(L(.completed, language))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("AccentGreen"))
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            }

            if isComplete && hasNext && showNext {
                Button(action: { onNext?() }) {
                    HStack(spacing: AppTokens.Spacing.xs) {
                        Text(L(.next, language))
                            .font(AppTokens.Typography.caption)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(Color("AccentGreen"))
                }
                .transition(.opacity)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTokens.Radius.xl))
        .onChange(of: count) { _, _ in
            showNext = false
        }
        .onChange(of: isComplete) { _, newValue in
            if newValue && hasNext {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showNext = true
                    }
                }
            }
        }
    }
}
