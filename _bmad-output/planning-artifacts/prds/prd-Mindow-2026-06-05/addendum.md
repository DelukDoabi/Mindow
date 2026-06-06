# Mindow PRD — Addendum

> Depth that supports the PRD but does not belong in it (technical-how, stack decisions, data model, sizing). The PRD stays at the capability level; this is where the "how" lives for the architecture workflow.

## A. Technical Stack (from source brief, for the architect — not binding PRD scope)

**Frontend**
- Flutter — iOS, Android, Web.
- State management: Riverpod.
- Routing: GoRouter.
- Local storage: Hive (supports the offline-first capture NFR).

**Backend**
- Supabase — Auth, PostgreSQL, Storage, Realtime, Edge Functions.

**AI**
- Provider: OpenAI. MVP model: GPT-4o Mini (cost-efficient classification — supports §9.3 cost guardrail).
- Use cases: classification (Category, Mental Weight, Effort, Duration), Decomposition, Coaching, Daily Mission prioritization.

**Notifications**
- Firebase Cloud Messaging (FCM).

**Payments**
- RevenueCat across Apple Store and Google Play.

**Analytics**
- PostHog — funnels, retention, events, A/B testing.

**Monitoring**
- Sentry — crashes, exceptions, performance.

## B. Functional Modules (architecture grouping)

- Auth — login, signup, profile.
- Brain Dump — create, edit, delete.
- Mental Load — calculation, historization.
- Missions — generation, validation.
- Gamification — XP, achievements, garden.
- AI — classification, prioritization, decomposition, coaching.

## C. Proposed Data Model (from source brief — to be validated in architecture)

- `users` — id, email, created_at.
- `mental_items` — id, user_id, content, category, mental_weight, effort_score, estimated_duration, status, created_at.
- `daily_missions` — id, user_id, mental_item_id, mission_date, completed, completed_at.
- `achievements` — id, user_id, achievement_type, unlocked_at.
- `garden_items` — id, user_id, item_type, unlocked_at.
- `subscriptions` — id, user_id, plan, started_at, expires_at.

`[NOTE: Couple Mode requires a Household entity and a membership/link table not present in the source brief — flag for the architecture workflow.]`

## D. Year-1 Business Targets (context, not FRs)

- 50,000 users.
- 5,000 Premium subscribers.
- NPS > 50.
- DAU/MAU > 30%.

## E. Vision Future (out of MVP — captured so it isn't lost)

- Voice assistant capture.
- Mobile home-screen widget (Mental Load + Daily Mission).
- Apple Watch / Wear OS quick add.
- Personal AI agent ("Qu'est-ce qui me soulagerait le plus aujourd'hui ?").
