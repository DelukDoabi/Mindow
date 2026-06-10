import 'package:supabase_flutter/supabase_flutter.dart';

/// Low-level transport client for Daily Mission generation.
class MissionsClient {
  MissionsClient(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  SupabaseClient _requireClient() {
    final client = _supabaseClient;
    if (client == null) {
      throw const MissionsClientUnavailableException();
    }
    return client;
  }

  Future<Map<String, dynamic>> generateTodayMission({
    required List<Map<String, dynamic>> candidates,
    String? profileTimezone,
  }) async {
    final response = await _requireClient().functions.invoke(
      'mission-generate',
      body: <String, dynamic>{
        'profile_timezone': profileTimezone,
        'candidates': candidates,
      },
    );

    final data = response.data;
    if (data is! Map) {
      throw const MissionsClientMalformedResponseException();
    }
    return Map<String, dynamic>.from(data);
  }
}

class MissionsClientUnavailableException implements Exception {
  const MissionsClientUnavailableException();
}

class MissionsClientMalformedResponseException implements Exception {
  const MissionsClientMalformedResponseException();
}
