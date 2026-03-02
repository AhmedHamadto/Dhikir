# Dhikir macOS App — Design Doc

**Date:** 2026-03-02
**Status:** Approved

## Goal

Add macOS 14+ support to the existing Dhikir iOS app using a single shared codebase with platform conditionals.

## Architecture

**Approach:** Multiplatform target. One codebase, `#if os(iOS)` / `#if os(macOS)` guards around the ~6 UIKit-specific touchpoints. No separate project or target — same source files compile for both platforms.

### What stays unchanged (zero modifications)

- All 7 SwiftData models (`Dhikir`, `UserFavorite`, `ReadingHistory`, `UserStreak`, `UserSettings`, `EmotionalState`, `LifeSituation`)
- `DatabaseService`, `StreakService`, `AudioService`
- `NotificationService` (UserNotifications works on macOS)
- `dhikirs.json`, all color assets
- All view layout code (cards, grids, sections)

### What changes

| File | iOS-specific code | macOS replacement |
|------|------------------|-------------------|
| `DhikirApp.swift` | `@UIApplicationDelegateAdaptor` | `@NSApplicationDelegateAdaptor` |
| `AppDelegate.swift` | `UIApplicationDelegate` | `NSApplicationDelegate` |
| `ContentView.swift` | `TabView` + `UITabBarAppearance` | `NavigationSplitView` with sidebar |
| `DhikirDisplayView.swift` | `.tabViewStyle(.page)` + haptics | Arrow buttons + keyboard `.onKeyPress` + trackpad swipe |
| `ShareSheet.swift` | `UIPasteboard` + `UIActivityViewController` | `NSPasteboard` + `NSSharingServicePicker` |
| `EmotionButton.swift` | `UIImpactFeedbackGenerator` | No-op (no haptics on Mac) |
| `OnboardingView.swift` | `.tabViewStyle(.page)` | Step-based navigation with buttons |

## macOS Window Layout

```
+------------------------------------------+
|  Dhikir                                   |
+----------+-------------------------------+
|          |                                |
|  * Home  |   [Main Content Area]          |
|  * Favs  |                                |
|  * Hist  |   Adapts based on sidebar      |
|  * Set   |   selection                    |
|          |                                |
+----------+-------------------------------+
```

- `NavigationSplitView` with `.sidebar` column
- Content area shows the selected section
- Default window size ~800x600, minimum ~600x400
- Sidebar is collapsible

## Dhikir Reading View (macOS)

Three navigation methods:
1. **Arrow buttons** — Previous/Next at the bottom of the view
2. **Keyboard arrows** — Left/right arrow keys via `.onKeyPress`
3. **Trackpad swipe** — Horizontal gesture support

Repetition counter works with click. No haptic feedback on macOS.

## Platform Conditional Strategy

### Haptics

A single helper function wraps all haptic calls:

```swift
func triggerHaptic(_ style: HapticStyle) {
    #if os(iOS)
    // UIImpactFeedbackGenerator / UINotificationFeedbackGenerator
    #endif
    // No-op on macOS
}
```

### Share Sheet

Cross-platform `ShareSheet` using:
- macOS: `NSPasteboard` for copy, `NSSharingServicePicker` for share
- iOS: `UIPasteboard` for copy, `UIActivityViewController` for share

### Settings Adaptations

- **Haptic Feedback toggle**: Hidden on macOS via `#if os(iOS)`
- **Notifications**: Works as-is
- **Appearance**: Works as-is
- **All other settings**: No changes

## project.yml Changes

- Add `macOS: "14.0"` deployment target
- Add macOS platform support to the Dhikir target
- Add a macOS scheme alongside the existing iOS scheme
- Same source files compile for both platforms
