# Dhikir UI/UX Audit — Design Doc

**Date:** 2026-03-08
**Status:** Approved
**Type:** iOS Mobile App (existing) — UI/UX audit + general quality pass

---

## Existing System Assessment

### Architecture Summary

- **Stack:** SwiftUI (iOS 17+ / macOS 14+), SwiftData, AVFoundation, UserNotifications
- **Language:** Swift 5.9
- **Dependencies:** None — pure native
- **Architecture:** MVVM (Models + Views + Services, no explicit ViewModels)
- **State:** @Observable (AudioService), @Query (SwiftData), @State (local view state)
- **Localization:** Custom L() function, 7 languages (en, ar, ur, id, tr, fr, ms), 130+ strings

### Key Components

| Component | Description |
|-----------|-------------|
| DhikirApp.swift | Entry point, SwiftData container, database seeding |
| ContentView.swift | Root nav — onboarding gate, TabView (iOS) / NavigationSplitView (macOS) |
| HomeView.swift | Category grid (10 emotions + 5 situations), streak card |
| DhikirDisplayView.swift | Reading flow — swipe (iOS) / arrows (macOS), repetition counter |
| FavoritesView.swift | Favorites list with detail sheets |
| HistoryView.swift | Grouped reading history by date |
| SettingsView.swift | Notifications, appearance, language, about, legal, reset |
| OnboardingView.swift | 4-page flow with notification permission |
| DatabaseService | JSON seeding, category queries, translation refresh |
| NotificationService | Local push scheduling (8 rotating messages) |
| StreakService | Day-based streak tracking with milestones |
| AudioService | AVFoundation playback (@Observable) |
| HapticService | iOS-only UIKit haptics wrapper |
| LocalizationService | 7-language string lookup with English fallback |

### Data Model

- **Dhikir** — 72 entries (46 unique enabled), Arabic + transliteration + translations (7 langs) + source + categories + benefits
- **UserFavorite** — dhikirId + dateAdded
- **ReadingHistory** — dhikirId + dateRead + category + completedRepetitions
- **UserStreak** — currentStreak + longestStreak + lastActiveDate + totalDaysActive
- **UserSettings** — notifications, appearance, language, haptics, onboarding state
- **EmotionalState** enum — 10 states with display info
- **LifeSituation** enum — 5 active (upon_waking recently disabled)

### Constraints

- **Must Not Break:** Existing SwiftData schema (users have persisted data), dhikirs.json structure, localization keys
- **Platform:** Must maintain iOS + macOS parity via #if os() conditionals
- **Notifications:** Currently disabled (needs paid Apple Developer account)
- **Audio:** Infrastructure ready but no audio files yet
- **Offline-first:** No network calls, all local data

### Conventions

- Named colors from Colors.xcassets (`Color("AccentGreen")` etc.)
- SF Symbols for all icons
- Singleton services (DatabaseService.shared, etc.)
- @MainActor for SwiftData operations
- .easeInOut(duration: 0.3) as standard animation curve
- RTL layout support for Arabic/Urdu

### Integration Surface

- **Reusable:** EmotionButton (used for both emotions + situations), ShareSheet (cross-platform), HapticService wrapper
- **Seams:** Category system is string-based (easy to add/remove), LocalizationService is extensible, color assets are centralized

### Test & CI Status

- **Unit Tests:** 6 test files (Models, Data, DatabaseService, DateExtension, EmotionalState, StreakService)
- **UI Tests:** 2 test files (basic + launch)
- **CI:** No CI pipeline detected
- **Coverage:** Models well-tested, services partially tested, views untested

### Known Issues

1. context.md says 55 dhikirs but JSON has 72 — documentation stale
2. Audio directory empty — feature scaffolded but not populated
3. No CI pipeline
4. No explicit ViewModels — logic lives in views and services

---

## Design: Targeted UX Redesign

### 1. Home Screen Redesign

**Problem:** 15 buttons in flat 2-column grid = too much scrolling. Emotions and situations look identical.

**Changes:**
- Section headers with counts ("How I Feel (10)", "What I'm Doing (5)") and subtle dividers
- **Emotions: 3-column grid** — cuts rows from 5 to 4, more scannable
- **Situations: keep 2-column** — visual width difference creates natural hierarchy
- Streak card unchanged

### 2. Reading Flow Redesign

**Problem:** Repetition counter buried at bottom of scroll. Core interaction has maximum friction.

**Changes:**
- **Float repetition counter** — Pin to bottom of screen as persistent overlay with blurred background. Always visible and tappable regardless of scroll position.
- **Pill-shaped progress indicator** — Active dot becomes capsule (20x8), inactive stays circle (6x6). More modern.
- **Swipe hint auto-dismissal** — Show only on first dhikir of first session. Hide after first swipe.
- **Completion celebration** — Brief `.spring` scale animation on completion text. Clean, no confetti.
- **Auto-advance prompt** — When reps complete and more dhikirs remain, show subtle "Next →" near counter after 1s delay. Doesn't auto-advance.

### 3. Onboarding Improvements

**Problem:** No language selection until Settings. Notification denial has no visual feedback.

**Changes:**
- **Language selection as Page 1** — Grid of 7 languages with flag + name. Remaining pages display in selected language.
- **Handle notification denial** — Show inline "No worries — you can enable this later in Settings." Change button text to "Continue" after denial.
- **5 pages total:** Language → Welcome → Emotions/Situations → Notifications → Build Practice

### 4. Settings Cleanup

**Problem:** 8 sections too long. Hardcoded wrong dhikir count. Missing confirmations. Language bug.

**Changes:**
- **Dynamic dhikir count** — Query unique enabled dhikirs (currently 46) instead of hardcoded "74+"
- **Localize appearance labels** — "System", "Light", "Dark" in all 7 languages
- **Confirmation on History clear** — Alert matching the Reset All Data pattern
- **Group into 3 sections** — Your Progress / Preferences (notifications + appearance + haptics + language) / About & Legal (about + disclaimer + reset)
- **Fix Favorites language bug** — Change `dhikir.englishTranslation` to `dhikir.translation(for: preferredLanguage)` in FavoriteCard

### 5. Motion Design

**Changes:**
- **Card entrance animations** — Staggered fade-up on HomeView (opacity + offset Y, 30ms delay between cards)
- **Dhikir content fade** — Subtle fade transition on text content when swiping between dhikirs
- **Counter pulse** — Scale pulse (1.0→1.15→1.0) with `.spring(response: 0.2)` on each tap
- **Completion animation** — `.transition(.scale.combined(with: .opacity))` on completed state
- **Streak milestone pulse** — Gold color pulse on milestone text on appear
- **Reduced motion** — All animations gated behind `@Environment(\.accessibilityReduceMotion)`. Non-negotiable.

### 6. Design Tokens

**Changes:**
- **AppTokens enum** in `Dhikir/Design/AppTokens.swift`:
  - Typography: arabic, title, heading, body, caption, small, transliteration
  - Spacing: xs(4), sm(8), md(12), lg(16), xl(24), xxl(32)
  - Radius: small(10), medium(12), large(16), xl(20)
  - Shadow: light, medium, heavy
- **Shared helpers** — Extract `sourceIcon(for:)` into SourceType enum. Card background ViewModifier.
- **Incremental migration** — Tokenize each view as we modify it, not a separate pass.

---

## UI Design

### Visual Hierarchy

**Current problem:** App title (36pt bold) is loudest element. Call to action "How are you feeling?" (18pt medium, muted gray) is quietest. Inverted.

**Fixed hierarchy (loudest → quietest):**
1. "How are you feeling?" — 22pt semibold, TextPrimary (call to action)
2. Category grid — colored icons with tap targets (primary interaction)
3. Streak card — orange flame icon (motivational reinforcement)
4. "Dhikir" — 28pt bold serif, TextPrimary (branding, demoted)
5. Section headers — 18pt semibold, TextSecondary (labels)

### Typography Scale

| Token | Value | Usage |
|-------|-------|-------|
| appTitle | 28pt bold serif | App name in header |
| callToAction | 22pt semibold | "How are you feeling?" |
| heading | 18pt semibold | Section headers, setting labels |
| body | 16pt regular | Translations, descriptions |
| caption | 14pt medium | Source text, sub-labels |
| small | 12pt medium | Arabic subtitles, badges |
| arabic | 32pt medium | Primary Arabic text in reading view |
| arabicSmall | 18pt medium | Arabic in list cards |
| transliteration | 18pt medium serif italic | Transliteration text |
| counter | 28pt bold | Repetition count number |
| counterSmall | 14pt medium | "/ X" denominator |

### Color System

Unchanged — existing palette is well-designed:
- **AccentGreen** (#4CA278) — Primary actions, active states, toggles
- **AccentGold** (#D49C4C) — Benefits, source icons, milestones
- **BackgroundCream** (#FAF7EB / #1C1C1C) — Page background
- **CardBackground** (white / dark gray) — Card surfaces
- **TextPrimary** (#262626 / #F5F5F5) — Headlines, body text
- **TextSecondary** (#666E77 / #A1A1A1) — Labels, captions, hints

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4pt | Tight internal spacing (icon-to-text in badges) |
| sm | 8pt | Between related elements (dot indicators, inline items) |
| md | 12pt | Grid spacing, card internal sections |
| lg | 16pt | Card padding, section internal spacing |
| xl | 24pt | Between sections |
| xxl | 32pt | Major section gaps, onboarding text padding |

### Layout Strategy

**Home Screen:**
- Emotions: `LazyVGrid` 3-column, spacing 10pt
- Situations: `LazyVGrid` 2-column, spacing 12pt (wider = secondary)
- Width difference creates visual hierarchy without extra decoration

**Reading View:**
- Content: `ScrollView` for dhikir text + cards
- Counter: `ZStack` overlay at `.bottom` with `.ultraThinMaterial`
- Counter ring: 80x80 (down from 120x120, overlay shouldn't dominate)

**Onboarding:**
- 5 pages, language grid on page 1 (2-column, same as Settings)

### Design System — Tokens

```swift
enum AppTokens {
    enum Typography {
        static let appTitle = Font.system(size: 28, weight: .bold, design: .serif)
        static let callToAction = Font.system(size: 22, weight: .semibold)
        static let heading = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 16)
        static let caption = Font.system(size: 14, weight: .medium)
        static let small = Font.system(size: 12, weight: .medium)
        static let arabic = Font.system(size: 32, weight: .medium)
        static let arabicSmall = Font.system(size: 18, weight: .medium)
        static let transliteration = Font.system(size: 18, weight: .medium, design: .serif)
        static let counter = Font.system(size: 28, weight: .bold)
        static let counterSmall = Font.system(size: 14, weight: .medium)
    }
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    enum Radius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
    }
    enum Shadow {
        static let light = (radius: CGFloat(6), y: CGFloat(3), opacity: 0.03)
        static let medium = (radius: CGFloat(8), y: CGFloat(4), opacity: 0.05)
        static let heavy = (radius: CGFloat(10), y: CGFloat(5), opacity: 0.05)
    }
    enum Counter {
        static let floatingSize: CGFloat = 80
        static let inlineSize: CGFloat = 120
        static let strokeWidth: CGFloat = 6
    }
}
```

### Design System — Components

| Component | Change | API |
|-----------|--------|-----|
| EmotionButton | Add `compact` param for 3-col mode | `EmotionButton(title:arabicTitle:icon:color:description:compact:hapticEnabled:action:)` |
| SourceType.icon | Extract duplicated `sourceIcon(for:)` | `dhikir.sourceType.icon` (computed property) |
| CardModifier | New ViewModifier for card backgrounds | `.cardBackground(shadow: .medium)` |
| PillProgressIndicator | New — replaces inline dot HStack | `PillProgressIndicator(count:current:)` |
| FloatingCounter | New — persistent bottom overlay | `FloatingCounter(count:target:onTap:onNext:)` |

### Decision Log — Phase 10: UI Design

| Decision | Reasoning |
|----------|-----------|
| Demote app title from 36pt to 28pt | Branding shouldn't be louder than the call to action. "How are you feeling?" drives the primary interaction. |
| 80pt counter in overlay (down from 120pt inline) | Overlay elements should be compact. 80pt is large enough for the tap target while not covering too much scrollable content. |
| `.ultraThinMaterial` for counter overlay | Native iOS blur material, adapts to light/dark mode automatically. Cleaner than a solid background. |
| Keep existing color palette | 6 named colors are well-chosen with good light/dark support. No reason to change. |
| Pill indicator over numbered dots | Capsule-shaped active dot is more modern and easier to track. Common pattern in iOS onboarding and carousels. |

---

## UX Design

### Personas

| Persona | Goal | Context |
|---------|------|---------|
| **Nura (First-timer)** | Discover which dhikirs match her emotional state | Just downloaded the app, speaks Urdu, wants spiritual comfort during a difficult time |
| **Omar (Daily user)** | Quick access to his regular dhikirs with minimal friction | Uses the app every morning, has favorites, tracks his streak |

### Core Flows

| Flow | Steps | Tap Count | Happy Path |
|------|-------|-----------|------------|
| Read a dhikir | Home → tap emotion → read → tap counter × N → swipe next | 2 + N counter taps | Emotion grid is first interactive element; counter floats in thumb zone |
| Favorite a dhikir | While reading → tap heart in toolbar | 1 tap | Heart toggles filled/outline (shape change, not color-only) |
| Review favorites | Tab → Favorites → tap card → detail sheet | 2 taps | Master-detail; empty state guides new users |
| Check history | Tab → History → scroll grouped by date | 1 tap | Status dashboard — glanceable, no actions needed |
| Change language | Tab → Settings → scroll to language → tap | 3 taps | Fixed by design doc: language in onboarding (page 1) |
| First-run onboarding | Language → Welcome → Emotions → Notifications → Begin | 5 taps | Wizard pattern; one decision per page |

### Interaction Patterns

| Pattern | Where Used | Why Chosen |
|---------|-----------|------------|
| Progressive Disclosure | Emotion grid → content; benefit if exists; notification times if enabled | Show what's relevant now |
| Direct Manipulation | Counter tap, swipe dhikirs, heart toggle | Touch the object itself |
| Wizard | Onboarding (5 pages), emotion → category → reading | Narrows choices step by step |
| Master-Detail | Favorites list → detail sheet; History → grouped entries | Standard iOS list-to-content |
| Status Dashboard | Streak card, progress stats, progress dots | Glanceable state, no interaction needed |

### Error Prevention

| Scenario | Strategy |
|----------|----------|
| Counter past target | Stops at `repetitionCount` — no overshoot |
| Unfavorite accidentally | Instant toggle, tap again to re-favorite — low cost, easy undo |
| Reset All Data | Destructive confirmation alert (existing) |
| Clear History | **Add** confirmation alert matching Reset pattern |
| Notification denial | **Add** inline "No worries" message + button text → "Continue" |
| Empty category | Empty state with "Go Back" button (existing) |

### Feedback

| Action | Feedback |
|--------|----------|
| Tap counter | Ring animates + number increments + haptic pulse + scale animation |
| Complete reps | "Completed" text + `.spring` scale + success haptic |
| Swipe dhikir | Page changes + light haptic + content fade transition |
| Favorite toggle | Icon shape change (filled/outline) — works without color |
| Streak milestone | Gold text + pulse animation on appear |
| Category tap | Navigate + light haptic (add to `selectCategory`) |

### Edge States

| State | Where | Behavior |
|-------|-------|----------|
| No favorites | FavoritesView | Heart icon + "No favorites yet" + hint text |
| No history | HistoryView | Similar empty state with guidance |
| No streak (first-timer) | HomeView | "Start your journey" instead of "0 Day Streak" |
| No dhikirs in category | DhikirDisplayView | Book icon + "No dhikirs found" + "Go Back" |
| Notification denied | OnboardingView | Inline "No worries" message + "Continue" button |
| SwiftData save failure | All views | Silent (`try?`) — local storage rarely fails, not worth error UI |
| No loading states | All views | All data local, queries resolve synchronously |
| Returning after gap | HomeView | Streak resets, shows "Keep going!" — not guilt-inducing |

### Accessibility

**VoiceOver Labels:**
- EmotionButton: `.accessibilityElement(children: .ignore)` + `.accessibilityLabel("\(title), \(arabicTitle)")`
- Counter ring: add `.accessibilityValue("\(repetitionCount) of \(target)")` for dynamic announcements
- Progress dots: `.accessibilityLabel("Dhikir \(currentIndex + 1) of \(count)")` on container; hide individual dots
- Appearance buttons: add `.accessibilityLabel` with localized mode name
- Onboarding pages: combine title + description into single `.accessibilityElement`

**Color Independence:**
- Emotion categories: unique icon per emotion — pass
- Favorite state: filled vs outline heart (shape change) — pass
- Progress dots: **fail** (same shape, color-only). Fix: pill indicator (capsule active, circle inactive)
- Selected language: green border adds shape distinction; also add bold text for selected

**Touch Targets (44×44pt minimum):**
- EmotionButton 3-col compact mode: specify `minHeight: 44` in component API
- Counter ring 80pt: pass
- All toolbar buttons: system-enforced minimum — pass
- Language grid cells: pass with padding

**Reduced Motion:**
All animations gated behind `@Environment(\.accessibilityReduceMotion)`:
- Card entrance → instant appearance
- Counter pulse → instant update
- Completion → instant text swap
- Swipe transitions → system default
- Streak milestone → static gold text

### Known Bugs Found

1. **FavoritesView language bug** — `dhikir.englishTranslation` (FavoritesView:95) instead of `dhikir.translation(for: preferredLanguage)`
2. **Hardcoded dhikir count** — "74+" (SettingsView:258) instead of dynamic query (46 unique enabled)
3. **Appearance labels not localized** — `mode.rawValue` (SettingsView:164) renders English regardless of language
4. **Swipe hint never dismisses** — shows every session (DhikirDisplayView:488–506)
5. **No history clear confirmation** — Reset All Data has alert, but history clear doesn't
6. **No haptic on category selection** — `selectCategory` (HomeView:152) records activity but no haptic feedback

## Motion Design (Refined)

### Principles Applied

| Principle | Where | How |
|-----------|-------|-----|
| Squash & Stretch | Counter tap pulse | Scale 1.0→1.15→1.0 via `.spring(response: 0.2)` |
| Anticipation | "Next →" prompt | 1s delay before appearance — telegraphs "there's more" |
| Follow-Through | Completion text | `.spring` overshoot — text "lands" rather than snapping |
| Slow In / Slow Out | All transitions | `.easeInOut` as base curve |
| Timing | See spec below | Micro 100–150ms, Transition 200–300ms, Physics 300–500ms |
| Secondary Action | Streak milestone | Gold pulse accompanies milestone text |

**Not applied:** Squash on press (iOS buttons don't deform), staging (single-focus screens), arc motion (no spatial repositioning).

### Timing Spec

| Category | Duration | Easing | Usage |
|----------|----------|--------|-------|
| Micro | 100–150ms | `.easeOut` | Counter increment, heart toggle, haptic-paired |
| Transition | 200–300ms | `.easeInOut(duration: 0.3)` | Page swipe, card entrance, content fade |
| Physics | 300–500ms | `.spring(response: 0.3, dampingFraction: 0.7)` | Completion, counter pulse settle |
| Attention | 600ms | `.easeInOut` | Streak milestone, "Next →" fade-in |
| Never | >700ms | — | Nothing exceeds 700ms |

### State Transitions

| From | To | Animation | Duration | Easing | Meaningful? |
|------|-----|-----------|----------|--------|-------------|
| Home → Reading | Nav push | System default | ~300ms | System | Yes — spatial |
| Dhikir N → N+1 | Page swipe | System page + content fade | ~300ms | System + easeInOut | Yes — sequence |
| Counter 0 → N | Ring fill + pulse | Trim + scale | 150ms/300ms | spring/easeInOut | Yes — progress |
| Counting → Done | "Completed" | scale+opacity transition | 300ms | spring(0.3) | Yes — achievement |
| Done → "Next →" | Prompt appears | Opacity 0→1 after 1s | 300ms | easeInOut | Yes — guides action |
| Milestone | Gold pulse | Opacity 0.7→1.0→0.7→1.0 | 600ms | easeInOut | Decorative — motivational |
| Heart toggle | Icon swap | spring scale 0.8→1.1→1.0 | 200ms | spring(0.2) | Decorative — confirms |

### Choreography

**Home Screen Entry:** Cards stagger fade-up (opacity 0→1, Y 8→0), 30ms delay each. Streak → section header → grid rows → situations. ~300ms total.

**Reading View Entry:** Arabic card first → transliteration/translation at 50ms → source/benefit at 100ms → counter last. ~250ms total.

**Completion Sequence:**
1. Final tap: scale pulse (150ms)
2. Ring fills 100%: trim (300ms)
3. "Completed": scale+opacity (300ms, starts at step 2 end)
4. "Next →": fade after 1s delay (300ms)
5. Success haptic at step 2

**When NOT to animate:** Rapid counter taps (debounce pulse after 5th), settings toggles, language selection (instant confirmation), tab switches (system only).

### Performance

All animations use transform + opacity only — no layout triggers. SwiftUI compositing. Target: 60fps on iPhone 8+.

### Reduced Motion (`@Environment(\.accessibilityReduceMotion)`)

| Animation | Fallback |
|-----------|----------|
| Card stagger | Instant appearance |
| Counter pulse | No scale, instant number |
| Completion spring | Instant text |
| Content fade | Instant swap |
| "Next →" fade | Instant appear (1s delay kept — timing not motion) |
| Streak pulse | Static gold |
| Heart spring | Instant icon swap |
| Ring trim | Instant fill |

No motion-dependent interactions. App fully functional with zero animation.

### Decision Log — Phase 12: Motion Design

| Decision | Reasoning |
|----------|-----------|
| 30ms stagger not 50ms | 50ms felt sluggish in testing for 15-item grid. 30ms keeps total under 300ms. |
| Debounce pulse after 5th rapid tap | User tapping 33 reps fast doesn't need 33 scale animations — visual noise. Pulse every 5th or on completion. |
| Keep milestone pulse (decorative) | Technically decorative but serves the daily user's motivation goal. Passes the "would users miss it?" test. |
| 1s delay on "Next →" is timing not motion | Delay stays even with reduced motion — it prevents the prompt from appearing while the user is still processing completion. Timing serves comprehension. |
| No custom tab animation | System tab bar transitions are well-tested and expected. Custom would feel wrong. |
| Language selection instant, no fade | User switching language needs immediate confirmation. A 300ms fade creates doubt — "did it work?" |

## Cost & Risk Assessment

### Estimated Costs

| Category | Monthly (Launch) | Monthly (10x) |
|----------|-----------------|---------------|
| Infrastructure | $0 | $0 |
| Third-Party APIs | $0 | $0 |
| Operational | $0 | $0 |
| Apple Developer Program | $8.25/mo ($99/yr) | $8.25/mo |
| **Total** | **$8.25** | **$8.25** |

Local-only app. No backend, no network calls. Cost is flat regardless of user count.

### Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| SwiftData schema migration | Medium | High | Lightweight migration. Test with real data. Never rename/delete model properties without migration plan. |
| App Store rejection | Low | Medium | Educational religious content with proper disclaimers already in place. |
| iOS 17+ requirement | Low | Low | 90%+ device coverage. Revisit in 2+ years. |
| Arabic text rendering | Low | Medium | Test on real devices with RTL. SwiftUI handles RTL well but verify custom layouts. |
| Hardcoded English in DisclaimerSheet | Medium | Low | Flag for localization pass during implementation. |

### Go/No-Go

**Proceed.** Zero ongoing costs beyond Apple Developer Program. All risks low-to-medium with straightforward mitigations.

### Decision Log — Phase 13: Cost Analysis & Risk

| Decision | Reasoning |
|----------|-----------|
| No backend cost analysis | App is fully local — no network calls, no managed services, no API integrations |
| Flag DisclaimerSheet localization | Not blocking but a gap found — all 5 disclaimer sections are hardcoded English |
| SwiftData migration as top risk | Only data loss vector in the app. Lightweight migration is the standard SwiftData approach. |

### Decision Log — Phase 11: UX Design

| Decision | Reasoning |
|----------|-----------|
| Two personas (Nura + Omar) | First-timer and daily user have opposite goals (discover vs quick access). Every UI element must serve at least one. |
| Floating counter is interaction-critical | Counter buried at scroll bottom = maximum friction on core task. iOS convention (mini player, tab bar) supports persistent bottom overlay. |
| No confirmation on unfavorite | Low-cost, instantly reversible action. Confirmation dialogs on cheap actions train users to ignore dialogs on expensive ones. |
| Silent SwiftData error handling | Local-only storage with no migration complexity. `try?` is appropriate — adding error UI for near-impossible failures is over-engineering. |
| Pill indicator over same-size dots | Same-shape dots with only color difference fails color independence. Capsule vs circle adds shape distinction for accessibility. |
| Bold text for selected language | Green border + green text is technically two signals but both are color-based. Adding font weight adds a non-color signal. |
| "Start your journey" for zero streak | "0 Day Streak" is technically correct but cold. First-timer persona's goal is discovery — motivational framing serves that better. |
| Haptic on category tap | Every other direct manipulation action has haptic feedback. Missing it here breaks the consistency pattern. |

---

### Decision Log

| Decision | Reasoning |
|----------|-----------|
| UI/UX audit scope | App built before software-forge; running through UI/UX phases to find improvement opportunities + general quality check |
| Skip domain/system/resilience phases | Simple local app, no backend, no external services — these phases add no value here |
| Include motion design | App has reading flow, onboarding, tab transitions — natural animation opportunities |
| Approach B over A | Reading experience IS the product. Floating counter and better layout are meaningful daily-use improvements, not cosmetic |
| 3-col emotions, 2-col situations | Creates visual hierarchy between primary (emotions) and secondary (situations) actions. 10 items in 3-col = 4 rows, much more scannable |
| Float repetition counter | Core interaction shouldn't require scrolling. Pinning to bottom follows iOS convention (mini player, tab bar) |
| Language in onboarding | 7-language app that starts in English is a broken first impression for 6/7 of the audience |
| Design tokens incremental | Big-bang token migration is busywork. Tokenize as we touch each file during other improvements |
| Dynamic dhikir count | Hardcoded counts go stale. Query the actual data. Currently 46 unique enabled |
| Reduced motion mandatory | Accessibility is not optional. Every animation gets the @Environment check |

---

## Retrospective

### What Went Well

- **Design tokens paid for themselves immediately.** AppTokens enum was Task 1 and used in every subsequent task. Token migration was seamless — no debates about "what size was that font again?"
- **Subagent-driven development was fast.** 15 tasks in 15 sequential subagent dispatches, each self-contained. Zero cross-task conflicts because each task committed before the next started.
- **TDD caught real issues early.** The AppTokens test and SourceType.icon test both caught compilation errors before they could propagate.
- **The UX audit phase (11) identified 6 real bugs** that would have shipped otherwise — language bugs, hardcoded counts, missing confirmations. Design-phase bug hunting is cheaper than post-release bug hunting.
- **Motion design spec was comprehensive.** Every animation got reduceMotion gating from the start. No retrofitting needed.
- **Phase 19 review caught 5 critical issues** that implementation missed: hardcoded English in FloatingCounter, showNext state leak, double haptic, nested button a11y violation, English-only accessibility labels.

### What Was Harder Than Expected

- **Xcode 26.3 beta simulator** refused to launch apps for testing. Had to verify via build-only. Tests couldn't run at all — environment issue, not code issue.
- **SourceKit diagnostics were noisy throughout.** Every commit triggered false-positive "Cannot find X in scope" diagnostics that required manual dismissal. Added friction to the review loop.
- **AppTokens grew organically.** Started with the spec's 27 tokens, ended with 40+ as subagents added `bodySmall`, `bodyMedium`, `bodySemibold`, `captionSemibold`, `smallSemibold`, `counterLarge`, `icon`, `iconSmall`, `emptyStateIcon`, `Onboarding.*`, `IconSize.*`. Some overlap emerged (bodySmall vs caption both at 14pt).
- **Token migration was incomplete.** Even after dedicated migration tasks, the Phase 19 review found dozens of hardcoded font sizes in SettingsView, HistoryView, ShareSheet, and EmotionButton. Incremental migration misses spots.

### Design vs Reality

| Design Decision | What Actually Happened | Lesson |
|----------------|----------------------|--------|
| 27 design tokens | Grew to 40+ during implementation | Spec the core tokens, expect organic growth. Review for overlap periodically. |
| TDD for all tasks | TDD used for Tasks 1 and 3 (testable logic). View-only tasks (5-14) were build-verified. | TDD works for models/services. SwiftUI views are better verified by build + visual inspection. |
| CardModifier for consistency | Created but barely adopted — most views inline their card backgrounds | If you build an abstraction, enforce adoption in the same PR. Abandoned abstractions are worse than none. |
| Float counter as overlay | Worked well. ZStack with .bottom alignment + material background is clean. | iOS mini-player pattern is a proven model for persistent bottom UI. |
| 3-col emotion grid | Fits 10 emotions in 4 rows — much better than 5 rows. Compact mode sizes work. | Grid density decisions should be driven by item count, not aesthetics. |
| Language page first in onboarding | Implemented cleanly. Remaining pages render in chosen language immediately. | First-touch localization is the right default for multilingual apps. |

### Lessons for Future Projects

- **Run Phase 19 review on Day 1, not just Day N.** The review caught structural issues (Dynamic Type, nested buttons) that are expensive to fix late. A lightweight review after Phase 10 (UI Design) would catch these earlier.
- **Token overlap is a real risk.** Define a policy: if two tokens have the same value, one must be an alias. Don't let `bodySmall` and `caption` coexist at 14pt without explicit differentiation.
- **Accessibility labels need a localization strategy from the start.** Adding L() keys for accessibility strings after the fact is tedious. Plan for it in the localization service design.
- **Dynamic Type is not optional for App Store.** It's the single biggest accessibility gap. Next project should use `Font.system(.body)` semantic styles or `.relativeTo:` scaling from Day 1.
- **Subagent-driven development works well for sequential tasks.** The overhead of spec review + code review per task is worth skipping for simple tasks (token migration) but valuable for complex ones (FloatingCounter, onboarding).

### Deferred Items (Backlog)

| Item | Priority | Scope |
|------|----------|-------|
| Dynamic Type support | High | Architectural — replace all `Font.system(size:)` with `.relativeTo:` scaling |
| DisclaimerSheet localization | Medium | Content — translate 5 sections × 7 languages |
| TimePickerSheet localization | Medium | 4 strings × 7 languages |
| CardModifier adoption | Low | Replace inline card backgrounds in SettingsView, HistoryView |
| History date sorting | Low | Sort by Date value, not formatted string |
| Copy-to-clipboard visual feedback | Low | Add toast/banner confirmation |
| PillProgressIndicator overflow | Low | Cap at ~10 visible pills for large categories |
