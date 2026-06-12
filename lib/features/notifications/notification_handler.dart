import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Background handler — Firebase constraint: MUST be a top-level function.
// Runs in a separate background isolate; no UI, no Riverpod, no Supabase.
// ---------------------------------------------------------------------------

/// Handles FCM messages received while the app is terminated or in the
/// background. Registered via [FirebaseMessaging.onBackgroundMessage].
///
/// Must be a top-level function annotated with `@pragma('vm:entry-point')`
/// to survive Dart AOT tree-shaking. No UI or async state access allowed.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: log only — no UI work permitted here.
  debugPrint(
    '[NotificationHandler] background message received: ${message.messageId}',
  );
}

// ---------------------------------------------------------------------------
// NotificationHandler
// ---------------------------------------------------------------------------

/// Wires FCM incoming-message events to the app's UI and navigation.
///
/// Call [init] exactly once after Firebase and [GoRouter] are available (e.g.
/// from [State.initState] with a [addPostFrameCallback] in the root widget).
///
/// All four MVP notification types route to the Home screen (`/`). Foreground
/// messages are presented as a [SnackBar] via [scaffoldMessengerKey].
///
/// **Tone guardrail (UX-DR16, UX-DR19):** All notification copy is produced
/// server-side by the `send-notification` Edge Function, so no banned phrases
/// can originate from this handler.
class NotificationHandler {
  NotificationHandler._();

  /// Wire into [MaterialApp.scaffoldMessengerKey] so foreground FCM messages
  /// can display a [SnackBar] without a local [BuildContext].
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static StreamSubscription<RemoteMessage>? _foregroundSub;
  static StreamSubscription<RemoteMessage>? _backgroundOpenedSub;

  /// Registers FCM listeners and processes any initial message that opened
  /// the app from a terminated state.
  ///
  /// [router] drives navigation for background-opened and initial messages.
  /// All four notification types route to `'/'` (Home) for MVP.
  ///
  /// Optional injectable overrides for testability:
  /// - [onMessage]: replaces [FirebaseMessaging.onMessage].
  /// - [onMessageOpenedApp]: replaces [FirebaseMessaging.onMessageOpenedApp].
  /// - [getInitialMessage]: replaces [FirebaseMessaging.instance.getInitialMessage].
  /// - [registerBackground]: replaces [FirebaseMessaging.onBackgroundMessage].
  ///   Pass `(_) {}` in unit tests to skip the platform-channel call.
  /// - [navigateOverride]: replaces `router.go(route)` — pass in unit tests
  ///   to avoid constructing a real [GoRouter].
  /// - [foregroundMessageHandler]: replaces the default [_showSnackBar] —
  ///   pass a spy in unit tests to verify foreground message handling without
  ///   a live widget tree.
  static Future<void> init(
    GoRouter? router, {
    Stream<RemoteMessage>? onMessage,
    Stream<RemoteMessage>? onMessageOpenedApp,
    Future<RemoteMessage?> Function()? getInitialMessage,
    @visibleForTesting
    void Function(BackgroundMessageHandler)? registerBackground,
    @visibleForTesting void Function(String)? navigateOverride,
    @visibleForTesting void Function(RemoteMessage)? foregroundMessageHandler,
  }) async {
    assert(
      router != null || navigateOverride != null,
      'NotificationHandler.init: provide either router or navigateOverride.',
    );

    // Register background handler (must be a top-level annotated function).
    // Guarded by the injectable override so tests can skip the platform-channel
    // call that requires real Firebase initialization.
    (registerBackground ?? FirebaseMessaging.onBackgroundMessage)(
      _firebaseMessagingBackgroundHandler,
    );

    final doNavigate =
        navigateOverride ?? (String route) => router!.go(route);

    final foregroundStream = onMessage ?? FirebaseMessaging.onMessage;
    final openedStream =
        onMessageOpenedApp ?? FirebaseMessaging.onMessageOpenedApp;
    final initialGetter =
        getInitialMessage ?? FirebaseMessaging.instance.getInitialMessage;

    // Foreground: show an in-app SnackBar instead of the OS overlay (AC: #4).
    final handleForeground =
        foregroundMessageHandler ?? _showSnackBar;
    await _foregroundSub?.cancel();
    _foregroundSub = foregroundStream.listen(handleForeground);

    // Background → user taps notification: navigate to destination (AC: #3, #5).
    await _backgroundOpenedSub?.cancel();
    _backgroundOpenedSub = openedStream.listen(
      (message) => doNavigate(_routeFor(message)),
    );

    // Terminated state → app opened via notification tap (AC: #5).
    final initial = await initialGetter();
    if (initial != null) {
      doNavigate(_routeFor(initial));
    }
  }

  /// Returns the deep-link route for [message].
  ///
  /// All four MVP types route to Home. Story 5.3 can introduce per-type
  /// routing based on `message.data['type']`.
  static String _routeFor(RemoteMessage message) => '/';

  static void _showSnackBar(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final title = notification.title ?? '';
    final body = notification.body ?? '';
    final display = body.isNotEmpty ? '$title \u2014 $body' : title;
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(display)),
    );
  }

  /// Cancels active subscriptions. Call from [State.dispose] if needed.
  static void dispose() {
    unawaited(_foregroundSub?.cancel() ?? Future<void>.value());
    unawaited(_backgroundOpenedSub?.cancel() ?? Future<void>.value());
  }
}
