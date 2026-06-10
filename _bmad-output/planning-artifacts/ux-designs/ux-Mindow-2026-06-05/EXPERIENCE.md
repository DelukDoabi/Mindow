---
name: Mindow
status: final
created: 2026-06-05
updated: 2026-06-10
sources:
  - ../../prds/prd-Mindow-2026-06-05/prd.md
---

# Mindow — Experience Spine

> Single-surface mobile (iOS / Android parity, Web responsive). Consumer launch posture, calm and anti-guilt by default. Paired with `DESIGN.md` (Direction C · Aurore). Both spines win on conflict with any mock or import. Demonstrates: positive-only progress framing, weight-not-tasks metaphor, gentleness as a gating discipline. Key-screen mocks: `.working/screens-aurore.html`.

## Foundation

Single-surface mobile, iOS + Android with parity, Web responsive down to one column. No external UI system named — inherits platform conventions for navigation, system gestures, dynamic type, and safe areas. `DESIGN.md` is the visual identity reference; this spine owns behavior, states, and flows. Offline-capable (local store); the app must remain fully usable for capture and reading without a network.

The product's organizing metaphor is a **mental backpack** measured in kilos. Every interaction either *adds* weight (depositing what occupies the mind) or *removes* it (completing, decomposing, releasing). The experience never frames the backpack as a debt to repay — only as a load that can get lighter.

## Information Architecture

| Surface | Reached from | Purpose |
|---|---|---|
| Onboarding | First launch (cold) | Promise + first deposit. Skippable. |
| Home — Sac à Dos Mental | App open (returning) | Current mental weight, backpack, week stats, deposit input |
| Daily Mission | Home primary path / notification | One portable action for today |
| Item detail | Backpack item tap | Read / edit / release one mental item |
| Decomposition (Premium) | Item detail → "Découper" | Break a heavy item into weighted steps |
| Garden / Progress | Tab / Home stats tap | Weight released over time, gentle visual growth |
| Couple Mode (Premium) | Tab / settings | Shared visibility of household load between partners |
| Paywall | Any Premium-gated entry | Premium value + subscribe |
| Settings | Home header | Account, notifications, privacy/export, partner link |

Bottom tab bar: **Sac à dos** (Home) / **Jardin** (Progress) / **À deux** (Couple) / **Réglages**. No drawer. Premium surfaces are reachable but gated by the paywall. Modal stacks one level deep, never two.

→ Composition reference: `.working/screens-aurore.html` (Home, Onboarding, Daily Mission, Decomposition). Spine wins on conflict.

## Voice and Tone

Microcopy. Brand voice and aesthetic posture live in `DESIGN.md.Brand & Style`. Mindow uses French **tutoiement**, warm and emotional, addressing the user by first name. Gentleness is a hard gate: no copy may induce guilt, urgency, or failure.

| Do | Don't |
|---|---|
| "Respire, Camille ✨" | "Tu as 12 tâches en retard" |
| "Qu'est-ce qui occupe ton esprit ?" | "Ajouter une tâche" |
| "−6 kg cette semaine" | "Tu n'as rien fait depuis 3 jours" |
| "Pas le moment ? Aucun souci." 🌱 | "N'oublie pas !" / "Dépêche-toi" |
| "Ton sac s'allège d'autant." | "Objectif non atteint" |
| Soft, reassuring, first-person-warm. | Exclamatory pressure, red alarms, debt language. |

**Gate:** every string ships only if it leaves the user feeling lighter. A counter (e.g. items still open) is always paired with a positive frame; it is never the headline.

## Component Patterns

Behavioral. Visual specs live in `DESIGN.md.Components`.

| Component | Use | Behavioral rules |
|---|---|---|
| Backpack | Home | Visual anchor for current weight. Tap opens backpack contents (item list). |
| Deposit input | Home | Free-text capture. Submit adds an item; weight estimate assigned, backpack updates. Never blocks on categorization. |
| Stat pill | Home | Read-only week summary. Always positive-framed. Tap → Garden/Progress. |
| Mission card | Daily Mission | One mission per day. Primary "C'est fait ✓" releases its weight; "Plus tard" defers with no penalty. |
| Step row | Decomposition | Tap toggles done; completing fills marker + dims row + subtracts step weight from item. |
| Weight tag | Mission / item / step | Shows kilo estimate. Decorative-behavioral only; never an editable field in v1. |
| Analysis deferred banner | Home | Visible when consent is granted but user is not authenticated. Copy: "Analyse IA en attente" + "Tes entrées sont sauvegardées. Connecte-toi pour lancer l'analyse IA." Primary CTA "Créer mon compte", secondary CTA "Me connecter". |
| Premium badge / Paywall | Gated surfaces | Tapping a gated entry routes to Paywall, never a dead end. |
| Progress dots | Onboarding | Reflect step position; non-interactive. |

## State Patterns

| State | Surface | Treatment |
|---|---|---|
| First launch | Onboarding | Promise sequence; "Passer" always available. Ends at first deposit. |
| Empty backpack | Home | Backpack shown at 0 kg with gentle prompt: "Ton sac est léger. Dépose ce qui t'encombre." No emptiness shame. |
| Cold open | Home | Show cached weight + last stats immediately. No blocking spinner. |
| Offline | Any | Capture, edit, complete all work locally. No error banner; sync silently on next foreground. |
| Consent granted + signed out | Home | Capture remains available. AI analysis does not start. Show deferred banner and auth CTAs. Never show technical 401 copy. |
| Session expired | Home | Preserve local capture and pending entries. Show calm reconnect message: "Ta session a expiré. Tes entrées sont conservées." CTA "Me reconnecter pour continuer l'analyse". |
| Re-auth success with pending entries | Home | Relaunch pending analysis in background with explicit feedback: "Parfait, on lance l'analyse de tes entrées…" |
| No mission today | Daily Mission | "Rien d'urgent aujourd'hui. Profite." — absence framed as relief, not a gap. |
| Deferred mission | Daily Mission | "Plus tard" returns to Home without guilt; weight unchanged, no streak broken. |
| Premium gate hit | Decomposition / Couple | Route to Paywall with the specific value in context; back returns cleanly. |
| Sync error | Settings → Account | Surfaced only here. Never blocks capture or completion. |
| Completion | Mission / step | Weight subtracts with a calm lightening beat (see Interaction Primitives); positive confirmation, no confetti spam. |

## Interaction Primitives

- Tap to act. Long-press reserved for system text selection.
- The signature feedback is **weight release**: on completion, the kg figure animates downward and the backpack subtly lightens/rises — the core reward.
- Deposit is one gesture: type and submit; no mandatory fields, tags, due dates, or priorities.
- Deferral ("Plus tard", "Pas le moment") is always one tap and always penalty-free.
- AI analysis requires both conditions: explicit AI consent and authenticated user session. Missing either condition defers analysis with human copy and clear next action.
- Honor **Reduce Motion**: replace the lightening animation with an immediate state change.
- **Banned:** streaks-as-pressure, overdue badges, red counters, push re-engagement guilt, confetti gamification, carousels, blocking modals over capture.
- **Banned:** technical transport language in user-facing surfaces ("401", "Unauthorized", "JWT", "token invalide").

## Accessibility Floor

Behavioral. Visual contrast lives in `DESIGN.md`.

- VoiceOver / TalkBack: every interactive element labeled with role + state. The kg figure announces current weight and its change on update ("63 kilos, allégé de 6 cette semaine").
- Dynamic type honored through `DESIGN.md` typography tokens; UI legible at the largest setting with no truncated controls or clipped CTAs.
- Reduce Motion: skip weight-release and glow animations; apply end state instantly.
- Tap targets ≥ 44pt (iOS) / 48dp (Android).
- Focus traversal follows reading order: title → weight → backpack → stats → input → CTA.
- Gradient-filled numerals and text must retain a non-gradient fallback fill that meets contrast against the dawn canvas.
- Color is never the sole carrier of meaning (completion also uses a checkmark + dim + announced state).

## Inspiration & Anti-patterns

- **Lifted from Headspace / Calm:** the calm-by-default emotional register and warm first-person address — the app feels like a companion, not a tracker.
- **Lifted from one-thing-a-day apps:** the single Daily Mission framing — one portable action, never an inbox of obligations.
- **Rejected — Streaks & overdue badges (most to-do and habit apps):** they weaponize the calendar and manufacture guilt, the exact opposite of mental-load relief. Mindow's reward is weight *leaving*, not a chain unbroken.
- **Rejected — Rich task metadata (priorities, due dates, projects):** capture must cost one gesture. Structure is offered later (decomposition), never demanded at deposit.
- **Rejected — Productivity dashboards:** progress is shown as kilos lifted and a growing garden, never as throughput charts.

## Key Flows

### Flow 1 — First deposit (Camille, evening, kids finally asleep)

1. Camille opens Mindow for the first time.
2. Onboarding shows the promise: *"Allège ta charge mentale."* She can skip but reads it.
3. She taps **Commencer**.
4. Home appears with an empty, light backpack and the prompt *"Qu'est-ce qui occupe ton esprit ?"*
5. She types *"prendre rdv pédiatre"* and submits.
6. The item drops into the backpack; the kg figure rises.
7. **Climax:** the backpack now visibly holds her weight, and the screen says *"Respire, Camille ✨"* — for the first time the invisible load is outside her head and held somewhere safe.

Failure: offline → deposit saved locally, no banner; backpack updates exactly the same.

### Flow 2 — Daily mission (Lucas, morning commute)

1. Lucas opens to his Daily Mission: *"Prendre le rendez-vous chez le pédiatre — ≈ 4 kg."*
2. The card explains gently: *"Tu repousses depuis 9 jours. 5 minutes suffisent."*
3. He makes the call.
4. He taps **C'est fait ✓**.
5. **Climax:** the weight releases — the kg figure animates down by 4, the backpack lightens — proof the day got lighter from one small act.

Alternate: not now → **Plus tard** returns to Home, weight unchanged, no penalty, copy stays kind (*"Aucun souci."*).

### Flow 3 — Decompose a heavy item (Sofia, Premium, Sunday planning)

1. Sofia opens a heavy item: *"Organiser l'anniversaire de Léa — 18 kg."*
2. She taps **Découper** → routed through the Paywall, subscribes to Premium.
3. Decomposition shows the item broken into weighted steps (Choisir la date · Liste des invités · Gâteau · Pochettes).
4. The first step is already done from a prior session; its weight is off.
5. She taps **Commencer le 1er pas**.
6. **Climax:** an unbearable 18 kg becomes four portable pieces — the mountain is now a set of steps she can actually carry, and the first kilos are already gone.

### Flow 4 — Shared load (Camille + partner, Couple Mode, Premium)

1. Camille links her partner in Settings.
2. She opens **À deux**.
3. Both partners' backpacks are visible side by side — the household's total weight and how it's split.
4. She sees an item only she has been carrying and assigns/visibly shares it.
5. **Climax:** the invisible imbalance becomes visible and fair — the mental load is no longer silently hers alone.

Gate: Couple Mode entry without Premium → Paywall framed on shared-visibility value; back returns to the tab cleanly.

### Flow 5 — Consent given, account skipped, then guided recovery (Camille, web)

1. Camille reaches AI consent and taps **J'accepte**.
2. She lands on account creation but taps **Passer** to go directly Home.
3. She deposits a preoccupation from Home.
4. Capture succeeds immediately with neutral confirmation: *"Entrée enregistrée."*
5. Home shows **Analyse IA en attente** banner with copy: *"Tes entrées sont sauvegardées. Connecte-toi pour lancer l'analyse IA."* and two CTAs: **Créer mon compte** / **Me connecter**.
6. She chooses **Me connecter** and completes auth.
7. **Climax:** pending entries start analysis automatically, and Home confirms: *"Parfait, on lance l'analyse de tes entrées…"* — no lost data, no technical error language, no guilt.

Guardrail: in this flow, no user-facing message may include backend error details; all technical auth failures are translated into calm guidance.

## Release Acceptance (Auth × Consent UX)

1. If AI consent is granted and the user is signed out, Home never triggers AI analysis calls.
2. If the user captures while signed out, capture still succeeds locally and the deferred-analysis banner appears.
3. If auth succeeds afterward, deferred entries resume analysis automatically once per session transition.
4. No user-facing string surfaces raw auth/network internals (401, Unauthorized, token).
5. Session expiration keeps capture available and routes through the reconnect pattern without data loss.
