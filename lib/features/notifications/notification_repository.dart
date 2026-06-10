import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mindow/features/notifications/fcm_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository handling FCM token registration and refresh.
///
/// Follows the single-Supabase-boundary pattern: holds a nullable client and
/// throws on [_requireClient] if Supabase is not initialized. Token storage
/// is non-critical — callers must catch and swallow exceptions.
class NotificationRepository {
  const NotificationRepository(this._supabaseClient, this._fcmClient);

  final SupabaseClient? _supabaseClient;
  final FcmClient _fcmClient;

  SupabaseClient _requireClient() {
    final client = _supabaseClient;
    if (client == null) {
      throw StateError('Supabase client not available — cannot save FCM token');
    }
    return client;
  }

  Future<NotificationSettings> requestPermission() =>
      _fcmClient.requestPermission();

  Future<String?> getFcmToken() => _fcmClient.getToken();

  /// Upserts the [token] for the current user and [platform].
  ///
  /// [platform] must be one of `'ios'`, `'android'`, `'web'`, `'other'`.
  /// `user_id` is not sent explicitly — it is enforced server-side via
  /// `DEFAULT auth.uid()` on the `user_fcm_tokens` table.
  Future<void> saveFcmToken(String token, String platform) async {
    await _requireClient().from('user_fcm_tokens').upsert(
      <String, dynamic>{
        'fcm_token': token,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,platform',
    );
  }

  Stream<String> get onTokenRefresh => _fcmClient.onTokenRefresh;
}
