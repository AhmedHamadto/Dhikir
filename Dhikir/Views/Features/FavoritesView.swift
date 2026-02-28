import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserFavorite.dateAdded, order: .reverse) private var favorites: [UserFavorite]
    @Query private var allDhikirs: [Dhikir]

    @State private var selectedDhikir: Dhikir?
    @State private var showDhikirDetail = false

    private var favoriteDhikirs: [Dhikir] {
        let favoriteIds = Set(favorites.map { $0.dhikirId })
        return allDhikirs.filter { favoriteIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream")
                    .ignoresSafeArea()

                if favoriteDhikirs.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(favoriteDhikirs, id: \.id) { dhikir in
                                FavoriteCard(dhikir: dhikir) {
                                    selectedDhikir = dhikir
                                    showDhikirDetail = true
                                } onRemove: {
                                    removeFavorite(dhikir)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .sheet(isPresented: $showDhikirDetail) {
                if let dhikir = selectedDhikir {
                    DhikirDetailSheet(dhikir: dhikir)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundStyle(Color("TextSecondary").opacity(0.5))

            Text("No Favorites Yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            Text("Dhikirs you love will appear here.\nTap the heart icon to save them.")
                .font(.system(size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func removeFavorite(_ dhikir: Dhikir) {
        if let favorite = favorites.first(where: { $0.dhikirId == dhikir.id }) {
            modelContext.delete(favorite)
            try? modelContext.save()
        }
    }
}

struct FavoriteCard: View {
    let dhikir: Dhikir
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dhikir.arabicText)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color("TextPrimary"))
                        .lineLimit(2)

                    Text(dhikir.englishTranslation)
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(2)

                    HStack {
                        Image(systemName: sourceIcon(for: dhikir.sourceType))
                            .font(.system(size: 12))
                            .foregroundStyle(Color("AccentGold"))

                        Text(dhikir.source)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.red)
                }
                .accessibilityLabel("Remove from favorites")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func sourceIcon(for type: SourceType) -> String {
        switch type {
        case .quran: return "book.fill"
        case .hadith: return "text.book.closed.fill"
        case .sunnah: return "person.fill"
        }
    }
}

struct DhikirDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let dhikir: Dhikir

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(dhikir.arabicText)
                        .font(.system(size: 28, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("TextPrimary"))
                        .padding()

                    Text(dhikir.transliteration)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(Color("TextSecondary"))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Translation")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color("AccentGreen"))

                        Text(dhikir.englishTranslation)
                            .font(.system(size: 16))
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                    )

                    HStack {
                        Text(dhikir.source)
                            .font(.system(size: 14, weight: .medium))

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

                    if let benefit = dhikir.benefit {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(Color("AccentGold"))
                                Text("Benefit")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("AccentGold"))
                            }

                            Text(benefit)
                                .font(.system(size: 14))
                                .foregroundStyle(Color("TextSecondary"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("AccentGold").opacity(0.1))
                        )
                    }

                    Text("Repeat \(dhikir.repetitionCount) time(s)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .padding()
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("Dhikir Details")
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
}

#Preview {
    FavoritesView()
        .modelContainer(for: [Dhikir.self, UserFavorite.self], inMemory: true)
}
