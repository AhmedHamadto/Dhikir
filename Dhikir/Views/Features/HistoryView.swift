import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReadingHistory.dateRead, order: .reverse) private var history: [ReadingHistory]
    @Query private var allDhikirs: [Dhikir]
    @Query private var settings: [UserSettings]

    @State private var selectedDhikir: Dhikir?
    @State private var showDhikirDetail = false
    @State private var showingClearAlert = false

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    private var groupedHistory: [(String, [ReadingHistory])] {
        let grouped = Dictionary(grouping: history) { item in
            formatDate(item.dateRead)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream")
                    .ignoresSafeArea()

                if history.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTokens.Spacing.xl) {
                            ForEach(groupedHistory, id: \.0) { date, items in
                                VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
                                    Text(date)
                                        .font(AppTokens.Typography.bodySemibold)
                                        .foregroundStyle(Color("TextPrimary"))

                                    ForEach(items, id: \.id) { item in
                                        if let dhikir = findDhikir(for: item.dhikirId) {
                                            HistoryCard(
                                                dhikir: dhikir,
                                                history: item
                                            ) {
                                                selectedDhikir = dhikir
                                                showDhikirDetail = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(L(.tabHistory, preferredLanguage))
            .toolbar {
                if !history.isEmpty {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(L(.clear, preferredLanguage)) {
                            showingClearAlert = true
                        }
                        .foregroundStyle(Color.red)
                    }
                    #else
                    ToolbarItem {
                        Button(L(.clear, preferredLanguage)) {
                            showingClearAlert = true
                        }
                        .foregroundStyle(Color.red)
                    }
                    #endif
                }
            }
            .alert(L(.clearHistory, preferredLanguage), isPresented: $showingClearAlert) {
                Button(L(.cancel, preferredLanguage), role: .cancel) {}
                Button(L(.clear, preferredLanguage), role: .destructive) {
                    clearHistory()
                }
            } message: {
                Text(L(.clearHistoryWarning, preferredLanguage))
            }
            .sheet(isPresented: $showDhikirDetail) {
                if let dhikir = selectedDhikir {
                    DhikirDetailSheet(dhikir: dhikir)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTokens.Spacing.lg) {
            Image(systemName: "clock.arrow.circlepath")
                .font(AppTokens.Typography.emptyStateIcon)
                .foregroundStyle(Color("TextSecondary").opacity(0.5))

            Text(L(.noHistoryYet, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextPrimary"))

            Text(L(.historyHint, preferredLanguage))
                .font(AppTokens.Typography.bodySmall)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return L(.today, preferredLanguage)
        } else if calendar.isDateInYesterday(date) {
            return L(.yesterday, preferredLanguage)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }

    private func findDhikir(for id: UUID) -> Dhikir? {
        allDhikirs.first { $0.id == id }
    }

    private func clearHistory() {
        for item in history {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}

struct HistoryCard: View {
    @Query private var settings: [UserSettings]
    let dhikir: Dhikir
    let history: ReadingHistory
    let onTap: () -> Void

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    private var categoryName: String {
        if let emotion = EmotionalState(rawValue: history.category) {
            return emotion.displayName(for: preferredLanguage)
        } else if let situation = LifeSituation(rawValue: history.category) {
            return situation.displayName(for: preferredLanguage)
        }
        return history.category
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: history.dateRead)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dhikir.arabicText)
                        .font(AppTokens.Typography.bodyMedium)
                        .foregroundStyle(Color("TextPrimary"))
                        .lineLimit(1)

                    Text(dhikir.translation(for: preferredLanguage))
                        .font(.system(size: 13))
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(1)

                    HStack(spacing: AppTokens.Spacing.sm) {
                        Text(categoryName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color("AccentGreen"))
                            .padding(.horizontal, AppTokens.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color("AccentGreen").opacity(0.1))
                            )

                        Text(formatTime(history.dateRead))
                            .font(.system(size: 11))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(AppTokens.Typography.bodySmall)
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTokens.Radius.medium)
                    .fill(Color("CardBackground"))
                    .shadow(
                        color: .black.opacity(AppTokens.Shadow.light.opacity),
                        radius: AppTokens.Shadow.light.radius,
                        y: AppTokens.Shadow.light.y
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("History: \(dhikir.arabicText), read on \(formattedDate)")
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Dhikir.self, ReadingHistory.self], inMemory: true)
}
