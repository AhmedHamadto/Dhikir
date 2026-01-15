import SwiftUI

struct ShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    let dhikir: Dhikir

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Share Dhikir")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))

                dhikirPreview

                shareOptions

                Spacer()
            }
            .padding()
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var dhikirPreview: some View {
        VStack(spacing: 16) {
            Text(dhikir.arabicText)
                .font(.system(size: 24, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("TextPrimary"))

            Text(dhikir.transliteration)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .italic()
                .foregroundStyle(Color("TextSecondary"))

            Text(dhikir.englishTranslation)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("TextSecondary"))

            Text("— \(dhikir.source)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color("AccentGold"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }

    private var shareOptions: some View {
        VStack(spacing: 12) {
            Button(action: copyToClipboard) {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Text")
                    Spacer()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("TextPrimary"))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardBackground"))
                )
            }

            Button(action: shareViaSystem) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share via...")
                    Spacer()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("TextPrimary"))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardBackground"))
                )
            }
        }
    }

    private func copyToClipboard() {
        let text = """
        \(dhikir.arabicText)

        \(dhikir.transliteration)

        \(dhikir.englishTranslation)

        — \(dhikir.source)
        """

        UIPasteboard.general.string = text

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }

    private func shareViaSystem() {
        let text = """
        \(dhikir.arabicText)

        \(dhikir.transliteration)

        \(dhikir.englishTranslation)

        — \(dhikir.source)

        Shared from Dhikir App
        """

        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    ShareSheet(dhikir: Dhikir(
        arabicText: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
        transliteration: "Hasbunallahu wa ni'mal wakeel",
        englishTranslation: "Sufficient for us is Allah, and He is the best Disposer of affairs",
        source: "Quran 3:173",
        sourceType: .quran,
        categories: ["anxious"]
    ))
}
