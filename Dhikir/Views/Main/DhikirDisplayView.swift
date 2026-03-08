import SwiftUI
import SwiftData

struct DhikirDisplayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [UserFavorite]
    @Query private var settings: [UserSettings]

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    private var hapticFeedbackEnabled: Bool {
        settings.first?.hapticFeedbackEnabled ?? true
    }

    let category: String

    @State private var dhikirs: [Dhikir] = []
    @State private var currentIndex: Int = 0
    @State private var repetitionCount: Int = 0
    @State private var showShareSheet = false

    #if os(macOS)
    @FocusState private var isDetailFocused: Bool
    #endif

    private var currentDhikir: Dhikir? {
        guard !dhikirs.isEmpty, currentIndex < dhikirs.count else { return nil }
        return dhikirs[currentIndex]
    }

    private var isFavorite: Bool {
        guard let dhikir = currentDhikir else { return false }
        return favorites.contains { $0.dhikirId == dhikir.id }
    }

    private var progress: Double {
        guard let dhikir = currentDhikir, dhikir.repetitionCount > 0 else { return 0 }
        return Double(repetitionCount) / Double(dhikir.repetitionCount)
    }

    var body: some View {
        ZStack {
            Color("BackgroundCream")
                .ignoresSafeArea()

            if dhikirs.isEmpty {
                emptyState
            } else {
                #if os(iOS)
                iOSPageView
                #elseif os(macOS)
                macOSScrollView
                #endif
            }
        }
        .navigationTitle(categoryTitle)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .topBarTrailing) {
                shareButton
                favoriteButton
            }
            #else
            ToolbarItemGroup(placement: .automatic) {
                shareButton
                favoriteButton
            }
            #endif
        }
        .onAppear {
            loadDhikirs()
        }
        .sheet(isPresented: $showShareSheet) {
            if let dhikir = currentDhikir {
                ShareSheet(dhikir: dhikir)
            }
        }
    }

    private var shareButton: some View {
        Button(action: { showShareSheet = true }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("AccentGreen"))
        }
        .accessibilityLabel(L(.shareDhikir, preferredLanguage))
    }

    private var favoriteButton: some View {
        Button(action: {
            if let dhikir = currentDhikir {
                toggleFavorite(dhikir)
            }
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isFavorite ? Color.red : Color("AccentGreen"))
        }
        .accessibilityLabel(isFavorite ? L(.removeFromFavorites, preferredLanguage) : L(.addToFavorites, preferredLanguage))
    }

    // MARK: - iOS Page View

    #if os(iOS)
    private var iOSPageView: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(dhikirs.enumerated()), id: \.element.id) { index, dhikir in
                ScrollView {
                    dhikirContent(dhikir)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: currentIndex) { oldValue, newValue in
            if oldValue != newValue {
                onDhikirChanged()
            }
        }
    }
    #endif

    // MARK: - macOS Scroll View

    #if os(macOS)
    private var macOSScrollView: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let dhikir = currentDhikir {
                    dhikirContent(dhikir)
                }
            }

            if let dhikir = currentDhikir {
                macOSCounterArea(dhikir)
            }

            macOSNavigationBar
        }
        .focusable()
        .focused($isDetailFocused)
        .onKeyPress(.leftArrow) {
            goToPrevious()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            goToNext()
            return .handled
        }
        .onKeyPress(.space) {
            if let dhikir = currentDhikir {
                incrementRepetition(dhikir)
            }
            return .handled
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isDetailFocused = true
            }
        }
        .onChange(of: currentIndex) { _, _ in
            isDetailFocused = true
        }
    }

    private func macOSCounterArea(_ dhikir: Dhikir) -> some View {
        VStack(spacing: 8) {
            Button(action: {
                incrementRepetition(dhikir)
            }) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color("AccentGreen").opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color("AccentGreen"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: progress)

                        VStack(spacing: 4) {
                            Text("\(repetitionCount)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(Color("TextPrimary"))

                            Text("/ \(dhikir.repetitionCount)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }

                    if repetitionCount >= dhikir.repetitionCount {
                        Text(L(.completed, preferredLanguage))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("AccentGreen"))
                    }

                    Text(L(.clickOrSpaceToCount, preferredLanguage))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("TextSecondary").opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Repetition counter, \(repetitionCount) of \(dhikir.repetitionCount)")
            .accessibilityHint("Click to increment count")
        }
        .frame(maxHeight: .infinity)
        .padding(.vertical, 8)
    }

    private var macOSNavigationBar: some View {
        HStack(spacing: 16) {
            Button(action: goToPrevious) {
                Label(L(.previous, preferredLanguage), systemImage: "chevron.left")
            }
            .disabled(currentIndex <= 0)

            Text("\(currentIndex + 1) \(L(.ofCount, preferredLanguage)) \(dhikirs.count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))

            Button(action: goToNext) {
                Label(L(.next, preferredLanguage), systemImage: "chevron.right")
            }
            .disabled(currentIndex >= dhikirs.count - 1)
        }
        .padding()
        .background(Color("CardBackground"))
    }

    private func goToPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
            onDhikirChanged()
        }
    }

    private func goToNext() {
        if currentIndex < dhikirs.count - 1 {
            currentIndex += 1
            onDhikirChanged()
        }
    }
    #endif

    // MARK: - Shared Content

    private func dhikirContent(_ dhikir: Dhikir) -> some View {
        VStack(spacing: 24) {
            progressIndicator

            arabicTextSection(dhikir)

            transliterationSection(dhikir)

            translationSection(dhikir)

            sourceSection(dhikir)

            if let benefit = dhikir.benefit(for: preferredLanguage) {
                benefitSection(benefit)
            }

            #if os(iOS)
            repetitionSection(dhikir)
            #endif

            if dhikir.audioFileName != nil {
                audioButton(dhikir)
            }

            #if os(iOS)
            swipeHint
            #endif
        }
        .padding()
    }

    private var categoryTitle: String {
        if let emotion = EmotionalState(rawValue: category) {
            return emotion.displayName(for: preferredLanguage)
        } else if let situation = LifeSituation(rawValue: category) {
            return situation.displayName(for: preferredLanguage)
        }
        return L(.appName, preferredLanguage)
    }

    private var progressIndicator: some View {
        VStack(spacing: AppTokens.Spacing.sm) {
            Text("\(currentIndex + 1) \(L(.ofCount, preferredLanguage)) \(dhikirs.count)")
                .font(AppTokens.Typography.caption)
                .foregroundStyle(Color("TextSecondary"))

            PillProgressIndicator(count: dhikirs.count, current: currentIndex)
        }
    }

    private func arabicTextSection(_ dhikir: Dhikir) -> some View {
        VStack(spacing: 16) {
            Text(dhikir.arabicText)
                .font(.system(size: 32, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("TextPrimary"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("CardBackground"))
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                )
        }
    }

    private func transliterationSection(_ dhikir: Dhikir) -> some View {
        Text(dhikir.transliteration)
            .font(.system(size: 18, weight: .medium, design: .serif))
            .italic()
            .multilineTextAlignment(.center)
            .foregroundStyle(Color("TextSecondary"))
            .padding(.horizontal)
    }

    private func translationSection(_ dhikir: Dhikir) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L(.translation, preferredLanguage))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("AccentGreen"))

                Spacer()

                Text("\(preferredLanguage.flag) \(preferredLanguage.displayName)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("TextSecondary"))
            }

            Text(dhikir.translation(for: preferredLanguage))
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color("TextPrimary"))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        )
    }

    private func sourceSection(_ dhikir: Dhikir) -> some View {
        HStack {
            Image(systemName: dhikir.sourceType.icon)
                .foregroundStyle(Color("AccentGold"))

            Text(dhikir.source)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))

            Spacer()

            Text(dhikir.sourceType.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color("AccentGreen"))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color("AccentGreen").opacity(0.1))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
        )
    }

    private func benefitSection(_ benefit: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color("AccentGold"))

                Text(L(.benefit, preferredLanguage))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("AccentGold"))
            }

            Text(benefit)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("AccentGold").opacity(0.1))
        )
    }

    private func repetitionSection(_ dhikir: Dhikir) -> some View {
        VStack(spacing: 16) {
            Text(L(.tapToCount, preferredLanguage))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))

            Button(action: {
                incrementRepetition(dhikir)
            }) {
                ZStack {
                    Circle()
                        .stroke(Color("AccentGreen").opacity(0.3), lineWidth: 8)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color("AccentGreen"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)

                    VStack(spacing: 4) {
                        Text("\(repetitionCount)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))

                        Text("/ \(dhikir.repetitionCount)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Repetition counter, \(repetitionCount) of \(dhikir.repetitionCount)")
            .accessibilityHint("Tap to increment count")

            if repetitionCount >= dhikir.repetitionCount {
                Text(L(.completed, preferredLanguage))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("AccentGreen"))
            }
        }
        .padding(.vertical)
    }

    private func audioButton(_ dhikir: Dhikir) -> some View {
        Button(action: { playAudio(dhikir) }) {
            HStack(spacing: 12) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color("AccentGreen"))

                Text(L(.listenToRecitation, preferredLanguage))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    #if os(iOS)
    private var swipeHint: some View {
        HStack(spacing: 8) {
            if currentIndex > 0 {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .medium))
            }

            Text(L(.swipeToNavigate, preferredLanguage))
                .font(.system(size: 14, weight: .medium))

            if currentIndex < dhikirs.count - 1 {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
            }
        }
        .foregroundStyle(Color("TextSecondary").opacity(0.6))
        .padding(.vertical, 8)
    }
    #endif

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundStyle(Color("TextSecondary"))

            Text(L(.noDhikirsFound, preferredLanguage))
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))

            Button(L(.goBack, preferredLanguage)) {
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color("AccentGreen"))
        }
    }

    private func loadDhikirs() {
        dhikirs = DatabaseService.shared.getDhikirs(for: category, context: modelContext).shuffled()
        if let dhikir = currentDhikir {
            saveToHistory(dhikir)
        }
    }

    private func incrementRepetition(_ dhikir: Dhikir) {
        if hapticFeedbackEnabled {
            triggerHaptic(.light)
        }

        if repetitionCount < dhikir.repetitionCount {
            repetitionCount += 1

            if repetitionCount == dhikir.repetitionCount && hapticFeedbackEnabled {
                triggerHaptic(.success)
            }
        }
    }

    private func toggleFavorite(_ dhikir: Dhikir) {
        if hapticFeedbackEnabled {
            triggerHaptic(.medium)
        }

        if let existing = favorites.first(where: { $0.dhikirId == dhikir.id }) {
            modelContext.delete(existing)
        } else {
            let favorite = UserFavorite(dhikirId: dhikir.id)
            modelContext.insert(favorite)
        }

        try? modelContext.save()
    }

    private func saveToHistory(_ dhikir: Dhikir) {
        let history = ReadingHistory(
            dhikirId: dhikir.id,
            category: category,
            completedRepetitions: 0
        )
        modelContext.insert(history)
        try? modelContext.save()
    }

    private func playAudio(_ dhikir: Dhikir) {
        guard let fileName = dhikir.audioFileName else { return }
        AudioService.shared.play(fileName: fileName)
    }

    private func onDhikirChanged() {
        repetitionCount = 0
        if let dhikir = currentDhikir {
            saveToHistory(dhikir)
        }
        if hapticFeedbackEnabled {
            triggerHaptic(.light)
        }
    }
}

#Preview {
    NavigationStack {
        DhikirDisplayView(category: "anxious")
    }
    .modelContainer(for: [Dhikir.self, UserFavorite.self, ReadingHistory.self], inMemory: true)
}
