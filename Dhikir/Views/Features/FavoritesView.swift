import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserFavorite.dateAdded, order: .reverse) private var favorites: [UserFavorite]
    @Query private var allDhikirs: [Dhikir]
    @Query private var settings: [UserSettings]

    @State private var selectedDhikir: Dhikir?
    @State private var showDhikirDetail = false

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

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
                        LazyVStack(spacing: AppTokens.Spacing.md) {
                            ForEach(favoriteDhikirs, id: \.id) { dhikir in
                                FavoriteCard(dhikir: dhikir, preferredLanguage: preferredLanguage) {
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
            .navigationTitle(L(.tabFavorites, preferredLanguage))
            .sheet(isPresented: $showDhikirDetail) {
                if let dhikir = selectedDhikir {
                    DhikirDetailSheet(dhikir: dhikir)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTokens.Spacing.lg) {
            Image(systemName: "heart")
                .font(AppTokens.Typography.emptyStateIcon)
                .foregroundStyle(Color("TextSecondary").opacity(0.5))

            Text(L(.noFavoritesYet, preferredLanguage))
                .font(AppTokens.Typography.heading)
                .foregroundStyle(Color("TextPrimary"))

            Text(L(.favoritesHint, preferredLanguage))
                .font(AppTokens.Typography.bodySmall)
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
    let preferredLanguage: SupportedLanguage
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: AppTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                Text(dhikir.arabicText)
                    .font(AppTokens.Typography.arabicSmall)
                    .foregroundStyle(Color("TextPrimary"))
                    .lineLimit(2)

                Text(dhikir.translation(for: preferredLanguage))
                    .font(AppTokens.Typography.bodySmall)
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(2)

                HStack {
                    Image(systemName: dhikir.sourceType.icon)
                        .font(AppTokens.Typography.small)
                        .foregroundStyle(Color("AccentGold"))

                    Text(dhikir.source)
                        .font(AppTokens.Typography.small)
                        .foregroundStyle(Color("TextSecondary"))
                }
            }
            .accessibilityLabel(dhikir.arabicText)

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .font(AppTokens.Typography.icon)
                    .foregroundStyle(Color.red)
            }
            .accessibilityLabel(L(.removeFromFavorites, preferredLanguage))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                .fill(Color("CardBackground"))
                .shadow(
                    color: .black.opacity(AppTokens.Shadow.medium.opacity),
                    radius: AppTokens.Shadow.medium.radius,
                    y: AppTokens.Shadow.medium.y
                )
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

}

struct DhikirDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]
    let dhikir: Dhikir

    private var preferredLanguage: SupportedLanguage {
        settings.first?.preferredLanguage ?? .english
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTokens.Spacing.xl) {
                    Text(dhikir.arabicText)
                        .font(AppTokens.Typography.arabic)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("TextPrimary"))
                        .padding()

                    Text(dhikir.transliteration)
                        .font(AppTokens.Typography.transliteration)
                        .italic()
                        .foregroundStyle(Color("TextSecondary"))

                    VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                        Text(L(.translation, preferredLanguage))
                            .font(AppTokens.Typography.captionSemibold)
                            .foregroundStyle(Color("AccentGreen"))

                        Text(dhikir.translation(for: preferredLanguage))
                            .font(AppTokens.Typography.body)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                            .fill(Color("CardBackground"))
                    )

                    HStack {
                        Text(dhikir.source)
                            .font(AppTokens.Typography.caption)

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

                    if let benefit = dhikir.benefit(for: preferredLanguage) {
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppTokens.Radius.large)
                                .fill(Color("AccentGold").opacity(0.1))
                        )
                    }

                    Text("\(dhikir.repetitionCount) \(L(.repeatTimes, preferredLanguage))")
                        .font(AppTokens.Typography.caption)
                        .foregroundStyle(Color("TextSecondary"))
                }
                .padding()
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle(L(.dhikirDetails, preferredLanguage))
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
                ToolbarItem {
                    Button(L(.done, preferredLanguage)) {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [Dhikir.self, UserFavorite.self], inMemory: true)
}
