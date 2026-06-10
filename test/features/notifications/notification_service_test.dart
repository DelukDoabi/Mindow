import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/notifications/fcm_client.dart';
import 'package:mindow/features/notifications/notification_repository.dart';
import 'package:mindow/features/notifications/notification_service.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeFcmClient extends Fake implements FcmClient {
  AuthorizationStatus status;
  String? token;
  final StreamController<String> _refreshController =
      StreamController<String>.broadcast();

  FakeFcmClient({
    this.status = AuthorizationStatus.authorized,
    this.token = 'svc-test-token',
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
  Stream<String> get onTokenRefresh => _refreshController.stream;

  void emitRefresh(String t) => _refreshController.add(t);
  Future<void> close() => _refreshController.close();
}

NotificationSettings _fakeSettings(AuthorizationStatus status) =>
    NotificationSettings(
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

/// Spy repository tracking [saveFcmToken] calls and throwing when requested.
class SpyNotificationRepository extends NotificationRepository {
  SpyNotificationRepository(FakeFcmClient fcm, {this.throwOnSave = false})
      : super(null, fcm);

  bool throwOnSave;
  final List<(String token, String platform)> savedTokens = [];

  @override
  Future<void> saveFcmToken(String token, String platform) async {
    if (throwOnSave) throw Exception('Supabase write failed');
    savedTokens.add((token, platform));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeFcmClient fakeFcm;
  late SpyNotificationRepository spyRepo;
  late NotificationService service;

  setUp(() {
    fakeFcm = FakeFcmClient();
    spyRepo = SpyNotificationRepository(fakeFcm);
    service = NotificationService(spyRepo);
  });

  tearDown(() async {
    service.dispose();
    await fakeFcm.close();
  });

  group('NotificationService.setupNotifications', () {
    test('saves token when permission granted and token available', () async {
      await service.setupNotifications();
      expect(spyRepo.savedTokens, hasLength(1));
      expect(spyRepo.savedTokens.first.$1, 'svc-test-token');
    });

    test('does not save when permission denied', () async {
      fakeFcm = FakeFcmClient(status: AuthorizationStatus.denied);
      spyRepo = SpyNotificationRepository(fakeFcm);
      service = NotificationService(spyRepo);

      await service.setupNotifications();
      expect(spyRepo.savedTokens, isEmpty);
    });

    test('does not save when token is null', () async {
      fakeFcm = FakeFcmClient(token: null);
      spyRepo = SpyNotificationRepository(fakeFcm);
      service = NotificationService(spyRepo);

      await service.setupNotifications();
      expect(spyRepo.savedTokens, isEmpty);
    });

    test('swallows exception on save failure', () async {
      spyRepo.throwOnSave = true;

      // Must not throw
      await expectLater(service.setupNotifications(), completes);
    });

    test('idempotent — second call is a no-op', () async {
      await service.setupNotifications();
      await service.setupNotifications();
      expect(spyRepo.savedTokens, hasLength(1));
    });

    test('saves refreshed token via onTokenRefresh listener', () async {
      await service.setupNotifications();
      expect(spyRepo.savedTokens, hasLength(1));

      fakeFcm.emitRefresh('refreshed-token');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(spyRepo.savedTokens, hasLength(2));
      expect(spyRepo.savedTokens[1].$1, 'refreshed-token');
    });

    test('dispose cancels token refresh subscription', () async {
      await service.setupNotifications();
      service.dispose();

      fakeFcm.emitRefresh('token-after-dispose');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // No third save after dispose
      expect(spyRepo.savedTokens, hasLength(1));
    });
  });
}
