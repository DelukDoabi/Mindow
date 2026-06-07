/// Domain-level failures for AI Analysis (Story 2.3).
///
/// The transport's `FunctionException` (from `supabase_flutter`) is an
/// implementation detail; the orchestration layer must never see it. The
/// `AiClient` maps every transport/decode error onto one of these so the
/// fallback path can branch on intent (retry vs. give up) without depending on
/// Supabase types.
library;

/// Base type for every AI Analysis failure surfaced to the app.
sealed class AiFailure implements Exception {
  const AiFailure();
}

/// The request could not reach the backend (connectivity/transport error).
class AiNetworkFailure extends AiFailure {
  /// Creates a network failure.
  const AiNetworkFailure();
}

/// The backend did not answer within the allotted time.
class AiTimeoutFailure extends AiFailure {
  /// Creates a timeout failure.
  const AiTimeoutFailure();
}

/// The backend answered, but the body did not match the expected contract.
class AiMalformedResponseFailure extends AiFailure {
  /// Creates a malformed-response failure.
  const AiMalformedResponseFailure();
}
