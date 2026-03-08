import SwiftUI
import SwiftData

struct ShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]
    let dhikir: Dhikir

    private var hapticEnabled: Bool {
        settings.first?.hapticFeedbackEnabled ?? true
    }

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    private var shareText: String {
        """
        \(dhikir.arabicText)

        \(dhikir.transliteration)

        \(dhikir.englishTranslation)

        — \(dhikir.source)
        """
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(L(.shareDhikirTitle, preferredLanguage))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))

                dhikirPreview

                shareOptions

                Spacer()
            }
            .padding()
            .background(Color("BackgroundCream").ignoresSafeArea())
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L(.done, preferredLanguage)) {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(L(.done, preferredLanguage)) {
                        dismiss()
                    }
                }
                #endif
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
                    Text(L(.copyText, preferredLanguage))
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
                    Text(L(.shareVia, preferredLanguage))
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
        #if os(iOS)
        UIPasteboard.general.string = shareText
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(shareText, forType: .string)
        #endif

        if hapticEnabled {
            triggerHaptic(.success)
        }

        dismiss()
    }

    private func shareViaSystem() {
        let fullText = """
        \(dhikir.arabicText)

        \(dhikir.transliteration)

        \(dhikir.englishTranslation)

        — \(dhikir.source)

        Shared from Dhikir App
        """

        #if os(iOS)
        let activityVC = UIActivityViewController(
            activityItems: [fullText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            var topVC = window.rootViewController
            while let presented = topVC?.presentedViewController {
                topVC = presented
            }
            topVC?.present(activityVC, animated: true)
        }
        #elseif os(macOS)
        let picker = NSSharingServicePicker(items: [fullText])
        if let window = NSApplication.shared.keyWindow,
           let contentView = window.contentView {
            picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        }
        #endif
    }
}

#Preview {
    ShareSheet(dhikir: Dhikir(
        arabicText: "\u{062D}\u{064E}\u{0633}\u{0652}\u{0628}\u{064F}\u{0646}\u{064E}\u{0627} \u{0627}\u{0644}\u{0644}\u{0651}\u{064E}\u{0647}\u{064F} \u{0648}\u{064E}\u{0646}\u{0650}\u{0639}\u{0652}\u{0645}\u{064E} \u{0627}\u{0644}\u{0652}\u{0648}\u{064E}\u{0643}\u{0650}\u{064A}\u{0644}\u{064F}",
        transliteration: "Hasbunallahu wa ni'mal wakeel",
        englishTranslation: "Sufficient for us is Allah, and He is the best Disposer of affairs",
        source: "Quran 3:173",
        sourceType: .quran,
        categories: ["anxious"]
    ))
}
