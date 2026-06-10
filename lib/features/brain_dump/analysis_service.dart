import 'dart:async';

import 'package:mindow/core/ai/ai_client.dart';
import 'package:mindow/core/ai/ai_failure.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:mindow/features/brain_dump/domain/analysis_constants.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/brain_dump/domain/weight_assigned_event.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';
import 'package:uuid/uuid.dart';

// Collaborators are kept in private fields; named parameters cannot be private
// initializing formals, so they are assigned in the initializer list.
// ignore_for_file: prefer_initializing_formals

/// The result of analyzing a single Preoccupation.
enum AnalysisOutcome {
  /// The worry was weighed and a `weight.assigned` event was emitted.
  weighed,

  /// The crisis-gate tripped; NO weight emitted, support resources surfaced.
  crisis,

  /// The user has not consented to AI; the item stays pending, no event, no
  /// error (AC3).
  skippedNoConsent,

  /// The user is not authenticated yet; analysis is deferred.
  skippedNoAuth,

  /// AI failed past the retry budget; a neutral fallback weight was emitted.
  fallback,

  /// Another analysis for the same id is already running (guarded out).
  skippedInFlight,
}

/// Default exponential-ish backoff between analysis retries.
Duration _defaultBackoff(int attempt) =>
    Duration(milliseconds: 400 * (attempt + 1));

/// Orchestrates consent-gated AI Analysis of pending Preoccupations (FR-6).
///
/// Never blocks capture (NFR-2): it is invoked fire-and-forget after a worry is
/// put down, and again on resume to sweep anything still pending. The flow is:
/// consent → [AiClient.analyze] → branch on crisis / success / failure, with a
/// bounded retry budget and a fallback floor so an item never stays pending
/// forever. A per-id in-flight guard prevents the same worry being analyzed
/// twice concurrently (NFR-11 cost guardrail).
class AnalysisService {
  /// Creates the service over its collaborators.
  ///
  /// [readPending] yields the current pending Preoccupations (injected so the
  /// service stays decoupled from the repository/projection). [onCrisis] and
  /// [onProjectionChanged] are UI-side side-effects (surface the crisis view,
  /// refresh the list) wired by the provider. [backoff] and [maxRetries] are
  /// injectable so tests run instantly and deterministically.
  AnalysisService({
    required AiClient aiClient,
    required OnboardingRepository onboardingRepository,
    required SyncQueue syncQueue,
    required List<Preoccupation> Function() readPending,
    bool Function() isAuthenticated = _alwaysAuthenticated,
    void Function(String id)? onCrisis,
    void Function()? onProjectionChanged,
    String languageCode = 'fr',
    Uuid uuid = const Uuid(),
    Clock clock = systemUtcClock,
    int maxRetries = kMaxAnalysisRetries,
    Duration Function(int attempt) backoff = _defaultBackoff,
  }) : _aiClient = aiClient,
       _onboarding = onboardingRepository,
       _syncQueue = syncQueue,
       _readPending = readPending,
      _isAuthenticated = isAuthenticated,
       _onCrisis = onCrisis,
       _onProjectionChanged = onProjectionChanged,
       _languageCode = languageCode,
       _uuid = uuid,
       _clock = clock,
       _maxRetries = maxRetries,
       _backoff = backoff;

  final AiClient _aiClient;
  final OnboardingRepository _onboarding;
  final SyncQueue _syncQueue;
  final List<Preoccupation> Function() _readPending;
  final bool Function() _isAuthenticated;
  final void Function(String id)? _onCrisis;
  final void Function()? _onProjectionChanged;
  final String _languageCode;
  final Uuid _uuid;
  final Clock _clock;
  final int _maxRetries;
  final Duration Function(int attempt) _backoff;

  /// Ids currently being analyzed, to suppress duplicate concurrent work.
  final Set<String> _inFlight = <String>{};

  /// Sweeps every still-pending Preoccupation through analysis.
  ///
  /// Called after capture and on resume. If consent is absent, returns
  /// immediately leaving everything pending with no error (AC3). Each item is
  /// analyzed fire-and-forget so one slow round-trip never blocks the others.
  Future<void> analyzePendingPreoccupations() async {
    if (!await _onboarding.isAiConsentGranted()) return;
    if (!_isAuthenticated()) return;
    for (final preoccupation in _readPending()) {
      if (_inFlight.contains(preoccupation.id)) continue;
      // Intentionally not awaited: independent items analyze in parallel.
      unawaited(
        analyzePreoccupation(
          id: preoccupation.id,
          content: preoccupation.content,
        ),
      );
    }
  }

  /// Analyzes the single Preoccupation [id] carrying [content].
  ///
  /// Returns the [AnalysisOutcome]. Emits at most one `weight.assigned` event
  /// (on success or fallback); crisis and no-consent emit none.
  Future<AnalysisOutcome> analyzePreoccupation({
    required String id,
    required String content,
  }) async {
    if (_inFlight.contains(id)) return AnalysisOutcome.skippedInFlight;
    if (!await _onboarding.isAiConsentGranted()) {
      return AnalysisOutcome.skippedNoConsent;
    }
    if (!_isAuthenticated()) {
      return AnalysisOutcome.skippedNoAuth;
    }

    _inFlight.add(id);
    try {
      for (var attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          final result = await _aiClient.analyze(
            content: content,
            languageCode: _languageCode,
          );
          switch (result) {
            case AiCrisisDetected():
              _onCrisis?.call(id);
              return AnalysisOutcome.crisis;
            case AiAnalysisSuccess(
              :final category,
              :final mentalWeightKg,
              :final effortScore,
              :final estimatedDurationMinutes,
              :final weightModelVersion,
            ):
              await _emitWeight(
                aggregateId: id,
                category: category,
                mentalWeightKg: mentalWeightKg,
                effortScore: effortScore,
                estimatedDurationMinutes: estimatedDurationMinutes,
                weightModelVersion: weightModelVersion,
              );
              return AnalysisOutcome.weighed;
          }
        } on AiFailure {
          final isLastAttempt = attempt >= _maxRetries - 1;
          if (isLastAttempt) break;
          await Future<void>.delayed(_backoff(attempt));
        }
      }

      // Retry budget exhausted: emit a neutral fallback so the item never
      // stays pending forever (AC5).
      await _emitWeight(
        aggregateId: id,
        category: kFallbackCategory,
        mentalWeightKg: kFallbackWeightKg,
        effortScore: kFallbackEffortScore,
        estimatedDurationMinutes: kFallbackDurationMinutes,
        weightModelVersion: kFallbackWeightModelVersion,
      );
      return AnalysisOutcome.fallback;
    } finally {
      _inFlight.remove(id);
    }
  }

  Future<void> _emitWeight({
    required String aggregateId,
    required String category,
    required int mentalWeightKg,
    required int effortScore,
    required int estimatedDurationMinutes,
    required String weightModelVersion,
  }) async {
    await _syncQueue.enqueue(
      WeightAssignedEvent(
        eventId: _uuid.v4(),
        aggregateId: aggregateId,
        occurredAt: _clock(),
        mentalWeightKg: mentalWeightKg,
        category: category,
        effortScore: effortScore,
        estimatedDurationMinutes: estimatedDurationMinutes,
        weightModelVersion: weightModelVersion,
      ),
    );
    _onProjectionChanged?.call();
  }
}

bool _alwaysAuthenticated() => true;
