# Stix → iPhone beta (TestFlight) — runbook

Goal: get Stix onto iPhones for beta testers, built in the cloud (no Mac to own),
distributed via TestFlight. Most of the code is already iOS-ready; this is setup.

Bundle ID: `com.stixapp.stix`  ·  App Group: `group.com.stixapp.stix`

---

## Phase 1 — Apple Developer account (DO THIS FIRST, ~10 min + up to 48h approval)
1. Go to **developer.apple.com/programs/enroll**.
2. Sign in with your Apple ID (enable two-factor auth if asked).
3. Entity type: **Individual / Sole Proprietor** (Organization needs a business
   D-U-N-S number — not needed for a beta).
4. Pay **$99/year**. Wait for the approval email.

## Phase 2 — GitHub repo (5 min)
1. Create a free account at **github.com** if needed.
2. New repo → name **`stix`** → **Private** → DO NOT add README/.gitignore/license.
3. Send me the repo URL (e.g. `https://github.com/you/stix.git`) and I'll push the code.
   (Or run it yourself from `E:\AI\MobileApps\Stixs\stix`:
   `git remote add origin <URL>` then `git push -u origin main`.)

## Phase 3 — Cloud Mac: add the Share Extension target (~30 min, ONE TIME)
You only need a Mac for this single Xcode step. Use **MacinCloud** (managed server,
pay-as-you-go ~$1/hr or a cheap day pass) — Xcode is pre-installed. No Flutter needed.

On the Mac:
1. `git clone <your repo URL>` and `cd stix`.
2. Open **`ios/Runner.xcodeproj`** in Xcode (the `.xcodeproj`, not a workspace).
3. **File → New → Target… → Share Extension**. Name it **exactly** `Share Extension`.
   Click Finish. If asked "Activate scheme?", click **Cancel** (don't need it).
4. Xcode created a `Share Extension` group with `ShareViewController.swift`,
   `Info.plist`, and `MainInterface.storyboard`. Replace two of them with the
   versions I prepared in **`ios/ShareExtension_prep/`**:
   - Copy the contents of `ShareExtension_prep/ShareViewController.swift` over the
     generated `Share Extension/ShareViewController.swift`.
   - Copy the contents of `ShareExtension_prep/Info.plist` over the generated
     `Share Extension/Info.plist`.
   - Leave `MainInterface.storyboard` as Xcode generated it.
5. **App Groups capability** (both targets):
   - Select the **Runner** target → **Signing & Capabilities** → **+ Capability** →
     **App Groups** → add **`group.com.stixapp.stix`**.
   - Select the **Share Extension** target → same thing → add the **same** group.
6. **Signing** (both targets): under Signing & Capabilities, set **Team** to your
   Apple Developer team and keep "Automatically manage signing" checked.
7. Set the **Share Extension** target's **iOS Deployment Target** to **13.0**
   (match Runner) under Build Settings if it defaults higher.
8. Commit + push:
   `git add -A && git commit -m "Add iOS Share Extension target" && git push`

That's the only Mac step. Everything after is cloud/automatic.

## Phase 4 — App Store Connect app record (5 min, after Phase 1 approved)
1. **appstoreconnect.apple.com → Apps → +** → New App.
2. Platform iOS, name **Stix**, primary language, **bundle ID `com.stixapp.stix`**
   (register it first at developer.apple.com → Identifiers if it's not listed),
   SKU `stix-001`.
3. Create an **App Store Connect API key**: Users and Access → Integrations →
   App Store Connect API → **+** → Access: **App Manager** → download the `.p8`
   (you can only download once) and note the **Key ID** and **Issuer ID**.

## Phase 5 — Codemagic (10 min)
1. Sign up at **codemagic.io** (free tier) with your GitHub.
2. Add the **`stix`** repo as an application.
3. **Teams → Integrations → App Store Connect → Connect**: upload the `.p8`,
   Key ID, Issuer ID. **Name the key exactly `Stix ASC Key`** (matches
   `codemagic.yaml`; change one to match the other if you prefer).
4. The repo already has **`codemagic.yaml`** — Codemagic will detect it.
5. Start a build of the **`ios-testflight`** workflow. Codemagic builds, signs, and
   uploads to TestFlight automatically.

## Phase 6 — TestFlight testers
1. In App Store Connect → your app → **TestFlight**.
2. **Internal testers** (up to 100, instant): add people on your team → they get
   the build immediately.
3. **External testers** (up to 10,000): create a group (e.g. "Stix Beta"), add
   testers by email or enable the **public link**. First external build needs a
   quick **Beta App Review** (usually hours).
4. Testers install the **TestFlight** app from the App Store and tap your invite.

---

## Order / timeline
- Today: Phase 1 (enroll) + Phase 2 (GitHub) in parallel.
- When you have ~30 min of Mac time: Phase 3.
- After Apple approval: Phases 4–6. First testers can be on it the same day.

## Notes
- Caption shoutout uses `#Stix` (no real social handle yet) — easy to swap for a
  real `@handle` later.
- The iOS app shares ONE codebase with Android; future features ship to both.
- If you ever want to skip the Mac step entirely, we can ship the first beta
  without share-into-Stix (manual add still works) and add it later.
