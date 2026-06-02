# Stix — Roadmap & Vision

_Last updated: 2026-06-01_

This is the execution plan. It takes the ambitious "Consumer Intent Network" idea
seriously **as a north star**, but sequences the work so we earn it instead of
over-building infrastructure for users we don't have yet.

---

## North Star (where this could go)
> The long-term asset isn't the app — it's the dataset that answers
> **"what do people want to do next?"** Most companies know what people did
> yesterday; almost none know what people *intend* to do tomorrow.

That vision is real. But it is **fully downstream of one thing**: people loving the
consumer app and coming back to actually *do* the things they save.

## Guiding principles (read before building anything below)
1. **Retention first.** The #1 metric that unlocks everything is: do people come
   back and *complete* ideas? Every "network" feature is a derivative of this.
   If a feature doesn't make someone more likely to return, it waits.
2. **User value before data value.** Only build "data capture" as a side effect of
   a feature that's useful to the user *today* (e.g. tags → a smarter randomizer).
   Never make users feel like they're "feeding a machine."
3. **Private by default.** Data stays on-device until there is (a) a real user base
   and (b) a transparent, opt-in data strategy we deliberately design. We're in
   California — CCPA applies. No selling behavioral data without consent, ever.
4. **Don't build the network before the app is loved.** Regional heatmaps, intent
   graphs, B2B dashboards, and AI prediction need *thousands of active users per
   region* to mean anything. They are Year 2–3, not now.

---

## Where we are now (M0 — shipped)
- Custom jars; share-a-post intake; **Quick Save** one-tap card → back to your feed.
- **Randomizer** ("pull a random idea").
- **Completion layer DONE**: "Tried It" with did-it + 1–5 rating + photo + notes
  (this is the valuable part most apps skip — already built).
- **Polaroid memories** + share-out to socials with a Stix-shoutout caption.
- Link thumbnails. Local SQLite, offline, no account.
- Android live on device; iOS prepped (see `IOS_SETUP.md`).

> Translation to the ChatGPT plan: **Phase 1 (saves) and Phase 2 (completion) are
> effectively already built.** We are further along than that plan assumes.

---

## The plan

### M1 — Structured intent + smarter randomizer  ·  _NOW (cheap, user-facing)_
Make the core loop better **and** structure the data for free.
- **Category/subcategory tags** on each idea (taxonomy: Food→Sushi/Coffee…,
  Date→Romantic/Adventure…, Travel→Weekend/Nature…). Auto-guess from the
  caption + platform + link host; user adjusts in one tap in Quick Save / editor.
- **Smarter randomizer**: "Surprise me" can target a category ("Food → Sushi") and
  weight toward what you actually complete, not pure random.
- **Filter** a jar by category.
- **Private stats screen** (on-device, for *you*): save count, completion rate,
  favorite categories, avg time-to-completion.
- _Maps to plan Phases 1, 3, and a lite Phase 5 — delivered as a real feature._
- _Inflection: none. Stays local/offline._

### M2 — Shared Jars  ·  _NEXT BIG (the viral + group-intent move)_
The single best idea from the vision doc, because it's valuable to the 2 people in
the jar **with zero scale**, and it's the growth loop.
- Couple's jar / friends' jar / family jar; invite by link.
- Shared saves + shared pulls; "we did this" together; shared polaroid wall.
- ⚠️ **Inflection point:** this is the first feature that needs **accounts + a
  backend/sync** — local-only ends here. That's a real cost + architecture
  decision (auth, hosting, conflict handling). Plan it deliberately before coding.
- _Maps to plan Phase 9. Generates individual + group intent as a byproduct._

### M3 — Make it a habit  ·  _ongoing_
- Gentle nudges ("date night Friday? pull something 🫙"), opt-in.
- Keep the magic: fast Quick Save, delightful pulls + polaroids.
- _This is where retention is won. Prioritize ruthlessly._

### Later — Intelligence layer  ·  _only after real scale + consent_
Park these as north-star, build when the numbers justify it:
- Intent graph (Phase 4), user intent scores (Phase 5 full), regional heatmaps
  (Phase 6), **Stix Insights** B2B dashboards (Phase 7), AI intent prediction
  (Phase 8).
- **Gate:** do NOT start until there's a meaningful active-user base per region
  *and* a written, opt-in data/privacy product. These are a separate B2B product,
  not a consumer feature.

---

## Metrics to watch (start lightweight + on-device)
| Metric | Why | When |
|---|---|---|
| Returns / week (retention) | The unlock for everything | from now |
| Saves per user | Engagement | from now |
| Randomizations (pulls) | Core usage | from now |
| Completion rate | Real-world action (the moat) | already trackable |
| Time-to-completion | Intent strength | M1 |
| Shared-jar invites | Viral growth | M2 |
| Category growth | Early trend signal | M1+ |

---

## Honest risks
- **Over-building the "asset" before retention exists** — the real trap. Avoid.
- **Privacy/trust** — the data story can poison the consumer product if mishandled.
- **The backend jump (M2)** — first real infra cost + complexity; don't take it on
  until Shared Jars is genuinely the next thing users want.

## Recommended immediate next step
Build **M1 (category tags + smarter randomizer)** — small, ships this week, makes
the loop better today, and structures the data for the future at near-zero cost.
Then evaluate **M2 (Shared Jars)** as the first growth bet.
