/// Neutral fallback constants for AI Analysis (Resolved Decision #2).
///
/// When AI Analysis fails (network/timeout/malformed/non-crisis error), the
/// item must not stay pending forever. It falls back to these low, neutral
/// values so a later real (heavier) weight never feels like a punishing jump,
/// while staying distinguishable from the `null` pending signal.
library;

/// Fallback Mental Weight in kg (a low, neutral floor; never `null`).
const int kFallbackWeightKg = 3;

/// Fallback Effort Score (mid of the 1-5 scale).
const int kFallbackEffortScore = 3;

/// Fallback Estimated Duration in minutes.
const int kFallbackDurationMinutes = 30;

/// Fallback Category — the catch-all of the fixed nine.
const String kFallbackCategory = 'Autre';

/// Marks a weight produced by the fallback path (not the AI model).
const String kFallbackWeightModelVersion = 'fallback-v1';

/// Maximum number of analysis attempts before giving up (NFR-11 guardrail).
const int kMaxAnalysisRetries = 3;
