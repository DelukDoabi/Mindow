import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mindow/features/notifications/notification_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Orchestrates notification permission, FCM token acquisition, and refresh.
///
/// Fire-and-forget: call [setupNotifications] from [HomeScreen.initState]
/// without awaiting. All failures are caught and reported to Sentry so they
/// never surface to the user or disrupt core flows (AC: #2, #5).
///
/// Idempotent per session via [_setupDone]: calling [setupNotifications]
/// a second time in the same session is a no-op (AC: #6).
class NotificationService {
  NotificationService(this._repository);

  final NotificationRepository _repository;

  bool _setupDone = false;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Requests notification permission, obtains the FCM token, and stores it.
  ///
  /// Safe to call multiple times — only the first call does real work.
  Future<void> setupNotifications() async {
    if (_setupDone) return;
    _setupDone = true;

    try {
      final settings = await _repository.requestPermission();
      final status = settings.authorizationStatus;
      if (status != AuthorizationStatus.authorized &&
          status != AuthorizationStatus.provisional) {
        // Declined — stop here. No error, no reduced UX. (AC: #2)
        return;
      }

      final token = await _repository.getFcmToken();
      if (token == null) {
        // Null token on Web without VAPID key — safe skip.
        return;
      }

      await _repository.saveFcmToken(token, _platformString());
      _listenTokenRefresh();
    } on Object catch (e, st) {
      // Swallow all exceptions — notification setup is non-critical. (AC: #5)
      unawaited(Sentry.captureException(e, stackTrace: st));
    }
  }

  void _listenTokenRefresh() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _repository.onTokenRefresh.listen(
      (newToken) async {
        try {
          await _repository.saveFcmToken(newToken, _platformString());
        } on Object catch (e, st) {
          unawaited(Sentry.captureException(e, stackTrace: st));
        }
      },
    );
  }

  String _platformString() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  void dispose() => _tokenRefreshSub?.cancel();
}
