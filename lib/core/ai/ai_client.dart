import 'dart:async';

import 'package:mindow/core/ai/ai_failure.dart';
import 'package:mindow/core/data/supabase_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ai_client.g.dart';

/// The outcome of a successful AI Analysis round-trip.
///
/// Either the worry was weighed ([AiAnalysisSuccess]) or the crisis-gate
/// tripped first ([AiCrisisDetected]) — in which case NO weight is produced and
/// the caller must show support resources instead (AC2). Transport/decode
/// problems are signalled out-of-band as an [AiFailure] thrown by
/// [AiClient.analyze].
sealed class AiAnalysisResult {
  const AiAnalysisResult();
}

/// The worry was analyzed and weighed.
class AiAnalysisSuccess extends AiAnalysisResult {
  /// Creates a successful analysis result.
  const AiAnalysisSuccess({
    required this.category,
    required this.mentalWeightKg,
    required this.effortScore,
    required this.estimatedDurationMinutes,
    required this.weightModelVersion,
  });

  /// The assigned Category (one of the fixed nine).
  final String category;

  /// The assigned Mental Weight in kilograms (1-20).
  final int mentalWeightKg;

  /// The assigned Effort Score (1-5).
  final int effortScore;

  /// The estimated time to resolve, in minutes.
  final int estimatedDurationMinutes;

  /// The server-stamped model/prompt version this weight came from.
  final String weightModelVersion;
}

/// The crisis-gate tripped: the content signals distress, not a chore.
///
/// Carries no weight or category by design (AC2): the user is shown calm
/// support resources and the item is never weighed or gamified.
class AiCrisisDetected extends AiAnalysisResult {
  /// Creates a crisis result.
  const AiCrisisDetected();
}

/// Calls the server-side `ai-analyze` Edge Function to weigh a Preoccupation.
///
/// The OpenAI key lives ONLY in the Edge runtime (AC1) — the client never sees
/// it and only ever talks to our function. The crisis-gate runs server-side
/// FIRST (AC2); when it trips the function returns `{ "is_crisis": true }` and
/// this client surfaces an [AiCrisisDetected] without any weight.
class AiClient {
  /// Creates a client over the authenticated [supabase] instance.
  AiClient(SupabaseClient supabase) : _supabase = supabase;

  final SupabaseClient _supabase;

  /// The Edge Function name.
  static const String _functionName = 'ai-analyze';

  /// Analyzes [content] (written in [languageCode]) and returns its weight, or
  /// signals a crisis. Throws an [AiFailure] on any transport/decode error.
  Future<AiAnalysisResult> analyze({
    required String content,
    required String languageCode,
  }) async {
    final session = _supabase.auth.currentSession;
    final FunctionResponse response;
    try {
      response = await _supabase.functions.invoke(
        _functionName,
        body: <String, dynamic>{
          'content': content,
          'language': languageCode,
        },
        headers: session == null
            ? null
            : <String, String>{
                'Authorization': 'Bearer ${session.accessToken}',
              },
      );
    } on FunctionException catch (_) {
      // Never leak the transport exception; map onto the domain taxonomy.
      throw const AiNetworkFailure();
    } on TimeoutException catch (_) {
      throw const AiTimeoutFailure();
    } on Object catch (_) {
      throw const AiNetworkFailure();
    }

    final data = response.data;
    if (data is! Map) throw const AiMalformedResponseFailure();
    final body = Map<String, dynamic>.from(data);

    if (body['is_crisis'] == true) return const AiCrisisDetected();

    try {
      return AiAnalysisSuccess(
        category: body['category'] as String,
        mentalWeightKg: (body['mental_weight_kg'] as num).toInt(),
        effortScore: (body['effort_score'] as num).toInt(),
        estimatedDurationMinutes: (body['estimated_duration_minutes'] as num)
            .toInt(),
        weightModelVersion: body['weight_model_version'] as String,
      );
    } on Object catch (_) {
      throw const AiMalformedResponseFailure();
    }
  }
}

/// Provides the shared [AiClient] over the authenticated Supabase client.
@riverpod
AiClient aiClient(Ref ref) => AiClient(ref.watch(supabaseClientProvider));
