# Stix — Project Handoff

_Last updated: 2026-06-01_

Orientation for anyone (human or AI) picking up Stix. Start here, then read the
linked docs.

## What Stix is
A mobile app to **save date/food ideas you find on social media, then pull a random
one when you can't decide** — and log what you actually did (with a polaroid you can
share). Flutter, Android-first, one codebase for iOS too.

## 📌 The plan / vision → see **[ROADMAP.md](ROADMAP.md)**
`ROADMAP.md` is the source of truth for **where we're going and in what order**
(north star, guardrails, milestones M1→M3, and what's deliberately deferred).
**Read it before proposing or building new features.** TL;DR: retention first,
user-value-before-data-value, private by default, don't build the "intent network"
before the app is loved. Next step is **M1: category tags + smarter randomizer**.

## Current status (what's built)
- Custom jars; share-a-post intake; **Quick Save** one-tap card (returns you to your
  feed instantly); randomizer; **completion tracking** (Tried It + rating + photo +
  notes); **polaroid memories** + social share-out; link thumbnails.
- Local SQLite, offline, no account. **Android is live on a real device.**
- **iOS is prepped but not built** — see **[IOS_SETUP.md](IOS_SETUP.md)** (paused by
  choice; needs Apple enrollment + a ~30-min cloud-Mac step + Codemagic).
- Running task list / quick backlog: **[TODO.md](TODO.md)**.
- Original product spec: **DESIGN.md** (in the parent folder `..\DESIGN.md`).

## Repo & layout
- GitHub: https://github.com/JamesNunez-Aluz/Stix  (branch `main`)
- Local: `E:\AI\MobileApps\Stixs\stix`
- Code map:
  - `lib/main.dart` — app entry + share handling (`_ShareGate`).
  - `lib/data/` — `stix_database.dart` (SQLite, schema v3), `stix_repository.dart`
    (single source of truth, `ChangeNotifier`).
  - `lib/models/` — `jar.dart`, `idea.dart` (status `in_jar`/`tried`).
  - `lib/screens/` — home, jar detail, pull, tried-it (polaroid wall), save-to-stix.
  - `lib/widgets/` — quick_save_sheet, polaroid_view, review_sheet, editors, etc.
  - `lib/utils/` — link parsing/preview, photo capture, polaroid share, caption.

## Build / run / install (Windows host, Android)
Toolchain lives at `C:\dev\flutter`, `C:\dev\jdk-17`, `C:\Android` (env vars set).
```
cd E:\AI\MobileApps\Stixs\stix
flutter run -d <deviceId>                      # live dev (emulator: flutter_pixel)
flutter build apk --release                    # standalone build
adb -s <deviceId> install -r build/app/outputs/flutter-apk/app-release.apk
```

## Gotchas already solved (keep these — they bite again if reverted)
- **JVM target**: `android/build.gradle.kts` bumps every Android *library* module's
  Java to 17 (plugins ship Java 11 + Kotlin 17 → Gradle rejects the mismatch).
- **Kotlin incremental off**: `kotlin.incremental=false` in `android/gradle.properties`
  (Windows fails to close the .tab cache otherwise).
- **INTERNET permission** is declared in the main `AndroidManifest.xml` — Flutter only
  auto-adds it for debug, so release needs it for thumbnails.
- **Never call `RenderObject.debugNeedsPaint` in app code** — it throws in release
  builds. Use `await WidgetsBinding.instance.endOfFrame` before `toImage` (see
  `utils/polaroid_share.dart`).
- **Debug builds boot slowly (~16s)** on the emulator; release starts fast. Don't
  mistake slow-boot for a bug.

## Next actions
1. **Build M1** (category tags + smarter randomizer) — see ROADMAP.md.
2. **iOS beta** when ready — follow IOS_SETUP.md (Apple enrollment is the long pole).
3. Keep TODO.md and ROADMAP.md current as things ship.
