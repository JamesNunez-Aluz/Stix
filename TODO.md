# Stix — TODO / status

_Last updated: 2026-06-01_

## 🔭 Current focus: ANDROID improvements
Polishing the Android app first. iOS beta is **PAUSED** (intentionally) and will be
picked back up after the Android improvements. Nothing below is blocked by code —
it's account setup + one short Mac session.

---

## ⏸️ iOS beta — REMAINING WORK (resume later)
Full step-by-step is in **`IOS_SETUP.md`**. High-level checklist:

**Already done (code side, committed + pushed):**
- [x] iOS project added (`ios/`), bundle id `com.stixapp.stix`
- [x] Info.plist: camera/photo permissions + share URL scheme
- [x] Share Extension files pre-written (`ios/ShareExtension_prep/`)
- [x] `ios/Podfile` wired for the Share Extension target
- [x] `codemagic.yaml` (cloud build → TestFlight)
- [x] Code on GitHub: https://github.com/JamesNunez-Aluz/Stix

**Still to do (all user/account steps):**
- [ ] **Apple Developer Program** enrollment — $99/yr, developer.apple.com/programs/enroll (Individual). *Can take up to ~48h — start early.*
- [ ] **~30 min on a cloud Mac (MacinCloud)** — create the "Share Extension" target in Xcode + add App Groups to both targets. See `IOS_SETUP.md` Phase 3. (Only Mac step needed.)
- [ ] **App Store Connect**: create app record (bundle id `com.stixapp.stix`) + App Store Connect API key (.p8 + Key ID + Issuer ID).
- [ ] **Codemagic**: connect GitHub repo, add the ASC API key named `Stix ASC Key`, run the `ios-testflight` workflow.
- [ ] **TestFlight**: add internal/external testers, send invite link.

Optional iOS fallback: ship the first beta WITHOUT share-into-Stix (manual add still
works), add the Share Extension later — skips the Mac step for now.

---

## 📱 Android improvements — backlog / ideas
(Add new ones here as we go.)
- [ ] _(in progress — see what we decide next)_
- [ ] Edit an existing idea
- [ ] Reorder jars
- [ ] Search across jars
- [ ] Save polaroids to the phone's camera roll (optional)
- [ ] Real social `@handle` in the share caption (once an account exists)
