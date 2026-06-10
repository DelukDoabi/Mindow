import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/data/supabase_client.dart';
import 'package:mindow/features/notifications/fcm_client.dart';
import 'package:mindow/features/notifications/notification_repository.dart';
import 'package:mindow/features/notifications/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the [FcmClient] implementation.
///
/// Override in tests with a fake to avoid real Firebase platform init.
final fcmClientProvider = Provider<FcmClient>(
  (_) => const RealFcmClient(),
);

/// Provides the [NotificationRepository].
///
/// Resolves [SupabaseClient] safely: if Supabase is not initialized (e.g.
/// in flavor without a backend), the client is null and token saves will
/// throw inside [NotificationRepository._requireClient] — which is caught by
/// [NotificationService.setupNotifications].
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  SupabaseClient? client;
  try {
    client = ref.watch(supabaseClientProvider);
  } on Object {
    client = null;
  }
  final fcm = ref.watch(fcmClientProvider);
  return NotificationRepository(client, fcm);
});

/// Provides the [NotificationService].
///
/// Disposed via [ref.onDispose] which cancels the token-refresh subscription.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final service = NotificationService(repo);
  ref.onDispose(service.dispose);
  return service;
});
