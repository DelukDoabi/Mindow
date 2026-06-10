import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/notifications/fcm_client.dart';
import 'package:mindow/features/notifications/notification_repository.dart';

// ---------------------------------------------------------------------------
// Fakes / Mocks
// ---------------------------------------------------------------------------

/// In-memory [FcmClient] for tests — no real Firebase required.
class FakeFcmClient extends Fake implements FcmClient {
  /// Preset the authorization status returned by [requestPermission].
  AuthorizationStatus status;

  /// Preset the token returned by [getToken].
  String? token;

  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  FakeFcmClient({
    this.status = AuthorizationStatus.authorized,
    this.token = 'fake-fcm-token',
  });

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async =>
      _fakeSettings(status);

  @override
  Future<String?> getToken({String? vapidKey}) async => token;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  /// Simulates Firebase refreshing the token on the device.
  void emitRefreshToken(String newToken) =>
      _tokenRefreshController.add(newToken);

  Future<void> close() => _tokenRefreshController.close();
}

/// Minimal [NotificationSettings]-like object with only the status field.
NotificationSettings _fakeSettings(AuthorizationStatus status) {
  return NotificationSettings(
    authorizationStatus: status,
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.notSupported,
    badge: AppleNotificationSetting.enabled,
    carPlay: AppleNotificationSetting.notSupported,
    lockScreen: AppleNotificationSetting.enabled,
    notificationCenter: AppleNotificationSetting.enabled,
    showPreviews: AppleShowPreviewSetting.whenAuthenticated,
    sound: AppleNotificationSetting.enabled,
    timeSensitive: AppleNotificationSetting.notSupported,
    criticalAlert: AppleNotificationSetting.notSupported,
    providesAppNotificationSettings: AppleNotificationSetting.notSupported,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeFcmClient fakeFcm;

  setUp(() {
    fakeFcm = FakeFcmClient();
  });

  tearDown(() async {
    await fakeFcm.close();
  });

  group('NotificationRepository', () {
    test('saveFcmToken throws when Supabase client is null', () async {
      final repo = NotificationRepository(null, fakeFcm);
      expect(
        () => repo.saveFcmToken('token', 'android'),
        throwsStateError,
      );
    });

    test('getFcmToken returns token from FcmClient', () async {
      final repo = NotificationRepository(null, fakeFcm);
      final result = await repo.getFcmToken();
      expect(result, 'fake-fcm-token');
    });

    test('getFcmToken returns null when client returns null', () async {
      fakeFcm = FakeFcmClient(token: null);
      final repo = NotificationRepository(null, fakeFcm);
      final result = await repo.getFcmToken();
      expect(result, isNull);
    });

    test('onTokenRefresh forwards stream from FcmClient', () async {
      final repo = NotificationRepository(null, fakeFcm);
      final received = <String>[];
      final sub = repo.onTokenRefresh.listen(received.add);

      fakeFcm.emitRefreshToken('new-token-1');
      fakeFcm.emitRefreshToken('new-token-2');

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(received, ['new-token-1', 'new-token-2']);
    });

    test('requestPermission delegates to FcmClient', () async {
      fakeFcm = FakeFcmClient(status: AuthorizationStatus.denied);
      final repo = NotificationRepository(null, fakeFcm);
      final settings = await repo.requestPermission();
      expect(settings.authorizationStatus, AuthorizationStatus.denied);
    });
  });
}
