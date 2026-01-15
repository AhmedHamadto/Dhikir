import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReadingHistory.dateRead, order: .reverse) private var history: [ReadingHistory]
    @Query private var allDhikirs: [Dhikir]

    @State private var selectedDhikir: Dhikir?
    @State private var showDhikirDetail = false

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
                        LazyVStack(spacing: 20) {
                            ForEach(groupedHistory, id: \.0) { date, items in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(date)
                                        .font(.system(size: 16, weight: .semibold))
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
            .navigationTitle("History")
            .toolbar {
                if !history.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            clearHistory()
                        }
                        .foregroundStyle(Color.red)
                    }
                }
            }
            .sheet(isPresented: $showDhikirDetail) {
                if let dhikir = selectedDhikir {
                    DhikirDetailSheet(dhikir: dhikir)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(Color("TextSecondary").opacity(0.5))

            Text("No History Yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            Text("Your reading history will appear here\nas you explore dhikirs.")
                .font(.system(size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
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
    let dhikir: Dhikir
    let history: ReadingHistory
    let onTap: () -> Void

    private var categoryName: String {
        if let emotion = EmotionalState(rawValue: history.category) {
            return emotion.displayName
        } else if let situation = LifeSituation(rawValue: history.category) {
            return situation.displayName
        }
        return history.category
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dhikir.arabicText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("TextPrimary"))
                        .lineLimit(1)

                    Text(dhikir.englishTranslation)
                        .font(.system(size: 13))
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(categoryName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color("AccentGreen"))
                            .padding(.horizontal, 8)
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
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
