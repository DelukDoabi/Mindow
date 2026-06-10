import 'package:firebase_messaging/firebase_messaging.dart';

/// Abstraction over [FirebaseMessaging] for testability.
///
/// Production code uses [RealFcmClient]; tests inject a fake implementation
/// so no real Firebase platform init is required.
abstract class FcmClient {
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });

  Future<String?> getToken({String? vapidKey});

  Stream<String> get onTokenRefresh;
}

/// Production implementation delegating to [FirebaseMessaging.instance].
class RealFcmClient implements FcmClient {
  const RealFcmClient();

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) =>
      FirebaseMessaging.instance.requestPermission(
        alert: alert,
        badge: badge,
        sound: sound,
      );

  @override
  Future<String?> getToken({String? vapidKey}) =>
      FirebaseMessaging.instance.getToken(vapidKey: vapidKey);

  @override
  Stream<String> get onTokenRefresh => FirebaseMessaging.instance.onTokenRefresh;
}
