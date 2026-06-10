# Investigation: ai-analyze 401 Unauthorized

## Hand-off Brief

1. **What happened.** The web app POSTs to `supabase/functions/v1/ai-analyze` and receives `401 Unauthorized`; the browser request shows both `authorization` and `apikey` headers carrying the Supabase anon key rather than a user JWT.
2. **Where the case stands.** The function-level auth gate is working as written; the remaining question is whether the app is invoking analysis while the user is effectively signed out or whether the client is failing to attach the restored session token.
3. **What's needed next.** Trace the auth/session path from onboarding skip through `AiClient.analyze()` to confirm whether the user has a valid session at the moment the request is sent.

## Case Info

| Field            | Value                                                                      |
| ---------------- | -------------------------------------------------------------------------- |
| Ticket           | N/A                                                                        |
| Date opened      | 2026-06-10                                                                 |
| Status           | Active                                                                     |
| System           | Windows                                                                     |
| Evidence sources | browser network trace, source code, Supabase Edge Function logs, repo code |

## Problem Statement

The production web version of `ai-analyze` returns `401 Unauthorized` after a user skips onboarding or otherwise reaches the app without a valid authenticated session.

## Evidence Inventory

| Source | Status   | Notes |
| ------ | -------- | ----- |
| Browser network trace | Available | POST to `https://knnnhrynruyyjofoxvet.supabase.co/functions/v1/ai-analyze` returned 401; headers show anon key in `authorization` and `apikey`. |
| Edge function source | Available | `supabase/functions/ai-analyze/index.ts` rejects requests without `Authorization` and calls `supabase.auth.getUser()`. |
| Client AI caller | Available | `lib/core/ai/ai_client.dart` invokes the Edge function using the authenticated Supabase client. |
| Auth/session source | Available | `lib/features/auth/auth_repository.dart` and `lib/core/router/app_router.dart` derive signed-in state from the restored Supabase session. |
| Project context | Missing | No `project-context.md` was present under `docs/` or the repo root. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --------------- | -------- | ------ | ----- |
| 1 | `lib/features/auth/*` session restore and skip flow | High | Open | Determine whether skip leaves the user signed out or unauthenticated. |
| 2 | `lib/features/brain_dump/analysis_service.dart` trigger conditions | High | Open | Confirm whether analysis can run before a valid session exists. |
| 3 | `lib/core/ai/ai_client.dart` header behavior on web | High | Open | Verify whether the user JWT is attached or only the anon key is present. |
| 4 | Supabase auth restore on web startup | Medium | Open | Check whether session persistence is failing in the browser. |

## Timeline of Events

| Time        | Event | Source | Confidence |
| ----------- | ----- | ------ | ---------- |
| 2026-06-10 15:46 UTC | Browser POST to `ai-analyze` returned 401 Unauthorized | Browser network trace | Confirmed |
| 2026-06-10 15:46 UTC | Request headers contained anon key in `authorization` and `apikey` | Browser network trace | Confirmed |
| 2026-06-10 16:?? UTC | Edge function requires a real Authorization header and calls `supabase.auth.getUser()` | `supabase/functions/ai-analyze/index.ts` | Confirmed |

## Confirmed Findings

### Finding 1: The failing request is not sending a user JWT

**Evidence:** Browser network trace supplied by the user.

**Detail:** The `authorization` and `apikey` headers both contain the anon key value, which is sufficient for public API access but not for `supabase.auth.getUser()`.

### Finding 2: The Edge Function auth gate is explicit and active

**Evidence:** `supabase/functions/ai-analyze/index.ts`

**Detail:** The handler returns `401` when `Authorization` is missing and then validates the caller with `supabase.auth.getUser()` before any model call.

### Finding 3: The client path expects an authenticated Supabase session

**Evidence:** `lib/core/ai/ai_client.dart`

**Detail:** The AI client is constructed over `Supabase.instance.client` and invokes the function through the Supabase SDK.

## Deduced Conclusions

### Deduction 1: The 401 is produced before Groq/Gemini is involved

**Based on:** Finding 1, Finding 2

**Reasoning:** The request fails at the auth gate before the provider code runs, so provider migration is not the direct cause of the 401.

**Conclusion:** The current blocker is authentication/session state, not the model API.

## Hypothesized Paths

### Hypothesis 1: Skip onboarding leaves the user effectively signed out

**Status:** Open

**Theory:** The skip path bypasses account creation/login, so the app later triggers `ai-analyze` without a restored Supabase session.

**Supporting indicators:** The browser trace shows anon headers only; the router/auth state are derived from persisted session state.

**Would confirm:** A trace showing `auth.currentSession == null` or a skip branch that never creates a session.

**Would refute:** A confirmed logged-in session at the time of the request with the JWT still absent from the function call.

**Resolution:** Not yet resolved.

### Hypothesis 2: The client fails to attach the restored access token on web

**Status:** Open

**Theory:** The session exists, but the function invocation is being sent without the user access token.

**Supporting indicators:** The browser trace only shows anon credentials; the function invocation relies on the SDK transport.

**Would confirm:** Logging or debugger evidence that `Supabase.instance.client.auth.currentSession` is non-null while the outbound request still lacks the JWT.

**Would refute:** A null session before invocation.

**Resolution:** Not yet resolved.

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | ----- | ------------- |
| Session state at the moment of the AI request | Distinguishes skip-onboarding behavior from client transport failure | Inspect `currentSession` or add a focused log around `AiClient.analyze()` on web. |
| Exact skip branch behavior | Shows whether the product intentionally allows analysis without auth | Read the onboarding flow and any “skip” action handler. |
| Supabase web session restoration details | Confirms whether the browser session is being persisted and restored | Trace the auth bootstrap path and the stored session on web reload. |

## Source Code Trace

| Element       | Detail |
| ------------- | ------ |
| Error origin  | `supabase/functions/ai-analyze/index.ts` in the request handler; returns `401` when `Authorization` is missing or `supabase.auth.getUser()` fails. |
| Trigger       | The web client invokes `AiClient.analyze()` from the brain-dump analysis flow. |
| Condition     | Request sent without a valid Supabase user session, or the session token is not attached. |
| Related files | `lib/core/ai/ai_client.dart`, `lib/features/brain_dump/analysis_service.dart`, `lib/features/auth/auth_repository.dart`, `lib/core/router/app_router.dart` |

## Conclusion

**Confidence:** High

The evidence confirms a server-side auth rejection, not an AI-provider failure. A concrete onboarding path can set AI consent to true and still leave the user unauthenticated (`onboarding_consent_screen.dart:26-27` then `account_screen.dart:75`), after which home capture triggers analysis (`home_screen.dart:85`) and the Edge Function returns 401 at its auth gate (`index.ts:247-265`).

## Recommended Next Steps

### Fix direction

If skip is meant to remain unauthenticated, block AI analysis while signed out (or force account step before any analysis trigger). If skip should still allow analysis, redesign auth expectations and relax/replace `supabase.auth.getUser()` gating in `ai-analyze`.

### Diagnostic

Add a focused log or debugger check on web immediately before `AiClient.analyze()` to capture `auth.currentSession`, then follow the skip action handler that leads into the analysis flow.

## Reproduction Plan

1. Start from a fresh web session.
2. Choose the onboarding skip path.
3. Trigger an AI analysis request.
4. Observe whether `auth.currentSession` is null and whether the network request still uses anon credentials.

## Side Findings

- The production issue is no longer a 502 from the model provider; the current live failure is a 401 auth rejection.
- The Edge Function was already updated to support Groq/Gemini, so the provider migration is not the immediate blocker for this incident.

## Follow-up: 2026-06-10

### New Evidence

- User-supplied browser network trace showing anon credentials in `authorization` and `apikey`.
- Edge Function source confirming the auth gate and user lookup.
- Client source confirming the call path runs through `AiClient.analyze()`.
- Onboarding consent acceptance persists `ai_consent=true` before account creation (`lib/features/onboarding/onboarding_consent_screen.dart:26`).
- Account step allows skip to home without auth completion (`lib/features/auth/account_screen.dart:75`).
- Home capture always triggers background analysis when consent is granted (`lib/features/brain_dump/presentation/home_screen.dart:85` and `lib/features/brain_dump/analysis_service.dart:100`).

### Additional Findings

- The issue sits on the auth boundary, before model selection or crisis classification.

### Updated Hypotheses

- Skip-onboarding after consent leaves the user signed out while AI analysis remains enabled. (Confirmed)
- The session may exist but not be attached to the function request. (Open, lower probability)

### Backlog Changes

- Prioritize inspection of the onboarding skip action and web session restoration before any further AI-provider work.

### Updated Conclusion

- Root cause is confirmed: there is a product flow that can enable AI consent without completing authentication, causing deterministic 401 responses at `ai-analyze` auth checks.
