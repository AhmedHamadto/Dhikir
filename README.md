# Dhikir - Islamic Remembrance

Beautiful iOS app for daily Islamic remembrance (dhikir) — 72 authentic duas from Quran & Hadith, 7 languages, fully offline.

## What is Dhikir?

Dhikir helps Muslims maintain a connection with Allah through contextual remembrance. Tell the app how you're feeling — anxious, grateful, sad, hopeful — and it presents duas specifically chosen for that moment.

> "Verily, in the remembrance of Allah do hearts find rest." — Quran 13:28

## Features

- **Emotion-Based Selection** — 10 emotional states and 10 life situations, each with curated duas
- **72 Authentic Dhikirs** — Every dua sourced from the Quran or authenticated Hadith (Bukhari, Muslim, Tirmidhi)
- **7 Languages** — Arabic + English, Urdu, Indonesian, Turkish, French, and Malay translations
- **Repetition Counter** — Track your dhikir count with haptic feedback
- **Favorites & History** — Save meaningful duas and track your spiritual journey
- **Daily Streak** — Build a consistent habit of remembrance
- **Fully Offline** — No internet required. No data collected. Everything stays on your device.
- **Dark Mode** — Easy on your eyes during night prayers
- **Accessibility** — VoiceOver support, reduced motion support, 44pt touch targets

## Privacy

Dhikir collects **zero** personal data. No analytics, no tracking, no accounts, no servers. All data (favorites, history, streaks, preferences) is stored locally on your device using Apple's SwiftData framework. Delete the app and it's all gone.

See [Privacy Policy](PRIVACY_POLICY.md) for full details.

## Tech Stack

| Component | Technology |
|-----------|------------|
| UI | SwiftUI |
| Minimum iOS | 17.0 |
| Persistence | SwiftData |
| Architecture | MVVM with @Observable |
| Design System | Custom design tokens (AppTokens) |

## Building

Requires Xcode 15+ and iOS 17+ SDK.

```bash
# Clone
git clone https://github.com/AhmedHamadto/Dhikir.git

# Open in Xcode
open Dhikir.xcodeproj

# Or build from command line
xcodebuild -scheme Dhikir -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Project Structure

```
Dhikir/
├── App/           # Entry point, app delegate, root view
├── Models/        # Data models (Dhikir, EmotionalState, LifeSituation, etc.)
├── Views/         # SwiftUI views organized by feature
├── Services/      # Database, notifications, streaks, haptics, localization
├── Design/        # Design tokens and reusable modifiers
├── Data/          # dhikirs.json — the dhikir database
├── Resources/     # Colors, assets
└── Extensions/    # Date helpers
```

## Content Accuracy

All dhikirs are sourced from the Quran and authenticated Hadith collections. If you find an error in any Arabic text, transliteration, translation, or source reference, please [open an issue](https://github.com/AhmedHamadto/Dhikir/issues).

See [Legal Disclaimers](LEGAL_DISCLAIMERS.md) for full terms.

## License

[MIT](LICENSE) — Ahmed Hamadto
