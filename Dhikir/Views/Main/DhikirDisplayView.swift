import SwiftUI
import SwiftData

struct DhikirDisplayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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

    #if os(iOS)
    @AppStorage("hasSeenSwipeHint") private var hasSeenSwipeHint = false
    #endif

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
                .font(AppTokens.Typography.iconSmall)
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
                .font(AppTokens.Typography.iconSmall)
                .foregroundStyle(isFavorite ? Color.red : Color("AccentGreen"))
        }
        .accessibilityLabel(isFavorite ? L(.removeFromFavorites, preferredLanguage) : L(.addToFavorites, preferredLanguage))
    }

    // MARK: - iOS Page View

    #if os(iOS)
    private var iOSPageView: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(dhikirs.enumerated()), id: \.element.id) { index, dhikir in
                    ScrollView {
                        dhikirContent(dhikir)
                            .transition(reduceMotion ? .identity : .opacity)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: currentIndex)
            .onChange(of: currentIndex) { oldValue, newValue in
                if oldValue != newValue {
                    hasSeenSwipeHint = true
                    onDhikirChanged()
                }
            }

            if let dhikir = currentDhikir {
                FloatingCounter(
                    count: repetitionCount,
                    target: dhikir.repetitionCount,
                    onTap: { incrementRepetition(dhikir) },
                    onNext: {
                        if currentIndex < dhikirs.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                            onDhikirChanged()
                        }
                    },
                    hasNext: currentIndex < dhikirs.count - 1,
                    language: preferredLanguage
                )
                .padding(.bottom, AppTokens.Spacing.lg)
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
                        .transition(reduceMotion ? .identity : .opacity)
                }
            }
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: currentIndex)

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
        VStack(spacing: AppTokens.Spacing.sm) {
            Button(action: {
                incrementRepetition(dhikir)
            }) {
                VStack(spacing: AppTokens.Spacing.md) {
                    ZStack {
                        Circle()
                            .stroke(Color("AccentGreen").opacity(0.3), lineWidth: AppTokens.Counter.inlineStrokeWidth)
                            .frame(width: AppTokens.Counter.inlineSize, height: AppTokens.Counter.inlineSize)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color("AccentGreen"), style: StrokeStyle(lineWidth: AppTokens.Counter.inlineStrokeWidth, lineCap: .round))
                            .frame(width: AppTokens.Counter.inlineSize, height: AppTokens.Counter.inlineSize)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: progress)

                        VStack(spacing: AppTokens.Spacing.xs) {
                            Text("\(repetitionCount)")
                                .font(AppTokens.Typography.counterLarge)
                                .foregroundStyle(Color("TextPrimary"))

                            Text("/ \(dhikir.repetitionCount)")
                                .font(AppTokens.Typography.counterSmall)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }

                    if repetitionCount >= dhikir.repetitionCount {
                        Text(L(.completed, preferredLanguage))
                            .font(AppTokens.Typography.bodySemibold)
                            .foregroundStyle(Color("AccentGreen"))
                            .transition(reduceMotion ? .identity : .scale.combined(with: .opacity))
                    }

                    Text(L(.clickOrSpaceToCount, preferredLanguage))
                        .font(AppTokens.Typography.small)
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
        .padding(.vertical, AppTokens.Spacing.sm)
    }

    private var macOSNavigationBar: some View {
        HStack(spacing: AppTokens.Spacing.lg) {
            Button(action: goToPrevious) {
                Label(L(.previous, preferredLanguage), systemImage: "chevron.left")
            }
            .disabled(currentIndex <= 0)

            Text("\(currentIndex + 1) \(L(.ofCount, preferredLanguage)) \(dhikirs.count)")
                .font(AppTokens.Typography.caption)
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
        VStack(spacing: AppTokens.Spacing.xl) {
            progressIndicator

            arabicTextSection(dhikir)

            transliterationSection(dhikir)

            translationSection(dhikir)

            sourceSection(dhikir)

            if let benefit = dhikir.benefit(for: preferredLanguage) {
                benefitSection(benefit)
            }

            if dhikir.audioFileName != nil {
                audioButton(dhikir)
            }

            #if os(iOS)
            if !hasSeenSwipeHint {
                swipeHint
            }

            // Extra space so content isn't hidden behind the floating counter
            Spacer()
                .frame(height: AppTokens.Counter.floatingSize + AppTokens.Spacing.xxl * 2)
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
        VStack(spacing: AppTokens.Spacing.lg) {
            Text(dhikir.arabicText)
                .font(AppTokens.Typography.arabic)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("TextPrimary"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppTokens.Radius.xl)
                        .fill(Color("CardBackground"))
                        .shadow(color: .black.opacity(AppTokens.Shadow.heavy.opacity), radius: AppTokens.Shadow.heavy.radius, y: AppTokens.Shadow.heavy.y)
                )
        }
    }

    private func transliterationSection(_ dhikir: Dhikir) -> some View {
        Text(dhikir.transliteration)
            .font(AppTokens.Typography.transliteration)
            .italic()
            .multilineTextAlignment(.center)
            .foregroundStyle(Color("TextSecondary"))
            .padding(.horizontal)
    }

    private func translationSection(_ dhikir: Dhikir) -> some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            HStack {
                Text(L(.translation, preferredLanguage))
                    .font(AppTokens.Typography.captionSemibold)
                    .foregroundStyle(Color("AccentGreen"))

                Spacer()

                Text("\(preferredLanguage.flag) \(preferredLanguage.displayName)")
                    .font(AppTokens.Typography.small)
                    .foregroundStyle(Color("TextSecondary"))
            }

            Text(dhikir.translation(for: preferredLanguage))
                .font(AppTokens.Typography.body)
                .foregroundStyle(Color("TextPrimary"))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                .fill(Color("CardBackground"))
                .shadow(color: .black.opacity(AppTokens.Shadow.medium.opacity), radius: AppTokens.Shadow.medium.radius, y: AppTokens.Shadow.medium.y)
        )
    }

    private func sourceSection(_ dhikir: Dhikir) -> some View {
        HStack {
            Image(systemName: dhikir.sourceType.icon)
                .foregroundStyle(Color("AccentGold"))

            Text(dhikir.source)
                .font(AppTokens.Typography.caption)
                .foregroundStyle(Color("TextSecondary"))

            Spacer()

            Text(dhikir.sourceType.rawValue)
                .font(AppTokens.Typography.smallSemibold)
                .foregroundStyle(Color("AccentGreen"))
                .padding(.horizontal, AppTokens.Spacing.md)
                .padding(.vertical, AppTokens.Spacing.xs)
                .background(
                    Capsule()
                        .fill(Color("AccentGreen").opacity(0.1))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                .fill(Color("CardBackground"))
        )
    }

    private func benefitSection(_ benefit: String) -> some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color("AccentGold"))

                Text(L(.benefit, preferredLanguage))
                    .font(AppTokens.Typography.captionSemibold)
                    .foregroundStyle(Color("AccentGold"))
            }

            Text(benefit)
                .font(AppTokens.Typography.bodySmall)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                .fill(Color("AccentGold").opacity(0.1))
        )
    }

    private func audioButton(_ dhikir: Dhikir) -> some View {
        Button(action: { playAudio(dhikir) }) {
            HStack(spacing: AppTokens.Spacing.md) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(AppTokens.Typography.icon)
                    .foregroundStyle(Color("AccentGreen"))

                Text(L(.listenToRecitation, preferredLanguage))
                    .font(AppTokens.Typography.bodyMedium)
                    .foregroundStyle(Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(AppTokens.Shadow.light.opacity), radius: AppTokens.Shadow.light.radius, y: AppTokens.Shadow.light.y)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    #if os(iOS)
    private var swipeHint: some View {
        HStack(spacing: AppTokens.Spacing.sm) {
            if currentIndex > 0 {
                Image(systemName: "chevron.left")
                    .font(AppTokens.Typography.small)
            }

            Text(L(.swipeToNavigate, preferredLanguage))
                .font(AppTokens.Typography.caption)

            if currentIndex < dhikirs.count - 1 {
                Image(systemName: "chevron.right")
                    .font(AppTokens.Typography.small)
            }
        }
        .foregroundStyle(Color("TextSecondary").opacity(0.6))
        .padding(.vertical, AppTokens.Spacing.sm)
    }
    #endif

    private var emptyState: some View {
        VStack(spacing: AppTokens.Spacing.lg) {
            Image(systemName: "book.closed")
                .font(AppTokens.Typography.emptyStateIcon)
                .foregroundStyle(Color("TextSecondary"))

            Text(L(.noDhikirsFound, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextSecondary"))

            Button(L(.goBack, preferredLanguage)) {
                dismiss()
            }
            .font(AppTokens.Typography.bodySemibold)
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
