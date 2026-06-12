import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/notifications/notification_handler.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RemoteMessage _makeMessage({
  Map<String, String> data = const {},
  RemoteNotification? notification,
}) {
  return RemoteMessage(
    messageId: 'test-msg',
    data: data,
    notification: notification,
  );
}

Future<void> _initHandler({
  required List<String> routes,
  StreamController<RemoteMessage>? foreground,
  StreamController<RemoteMessage>? backgroundOpened,
  Future<RemoteMessage?> Function()? initialMessage,
  List<RemoteMessage>? capturedForeground,
}) =>
    NotificationHandler.init(
      null,
      onMessage: foreground?.stream ?? const Stream<RemoteMessage>.empty(),
      onMessageOpenedApp:
          backgroundOpened?.stream ?? const Stream<RemoteMessage>.empty(),
      getInitialMessage: initialMessage ?? () async => null,
      registerBackground: (_) {},
      navigateOverride: routes.add,
      foregroundMessageHandler:
          capturedForeground != null ? capturedForeground.add : null,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  tearDown(NotificationHandler.dispose);

  // -------------------------------------------------------------------------
  // Routing
  // -------------------------------------------------------------------------
  group('NotificationHandler - routing', () {
    for (final type in [
      'daily_mission',
      'streak',
      'achievement',
      'mental_load_reduced',
    ]) {
      test('routes $type to home (/)', () async {
        final routes = <String>[];
        final opened = StreamController<RemoteMessage>();
        addTearDown(opened.close);

        await _initHandler(routes: routes, backgroundOpened: opened);

        opened.add(_makeMessage(data: {'type': type}));
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(routes, equals(['/']));
      });
    }

    test('navigates on getInitialMessage when not null', () async {
      final routes = <String>[];

      await _initHandler(
        routes: routes,
        initialMessage: () async =>
            _makeMessage(data: {'type': 'daily_mission'}),
      );

      expect(routes, equals(['/']));
    });

    test('does not navigate when getInitialMessage returns null', () async {
      final routes = <String>[];
      await _initHandler(routes: routes);
      expect(routes, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Foreground handler (injectable — avoids FakeAsync / widget-tree issues)
  // -------------------------------------------------------------------------
  group('NotificationHandler - foreground handler', () {
    test('delivers message with notification to injected handler', () async {
      final captured = <RemoteMessage>[];
      final foreground = StreamController<RemoteMessage>();
      addTearDown(foreground.close);

      await _initHandler(
        routes: [],
        foreground: foreground,
        capturedForeground: captured,
      );

      const notification = RemoteNotification(
        title: 'Ta mission du jour',
        body: 'Go!',
      );
      foreground.add(_makeMessage(notification: notification));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(captured, hasLength(1));
      expect(captured.first.notification?.title, 'Ta mission du jour');
    });

    test('delivers message with title only to injected handler', () async {
      final captured = <RemoteMessage>[];
      final foreground = StreamController<RemoteMessage>();
      addTearDown(foreground.close);

      await _initHandler(
        routes: [],
        foreground: foreground,
        capturedForeground: captured,
      );

      foreground.add(
        _makeMessage(
          notification: const RemoteNotification(title: 'Keep it up!'),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(captured, hasLength(1));
      expect(captured.first.notification?.title, 'Keep it up!');
    });

    test('delivers data-only message (null notification) to handler',
        () async {
      final captured = <RemoteMessage>[];
      final foreground = StreamController<RemoteMessage>();
      addTearDown(foreground.close);

      await _initHandler(
        routes: [],
        foreground: foreground,
        capturedForeground: captured,
      );

      foreground.add(_makeMessage(data: {'type': 'streak'}));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(captured, hasLength(1));
      // No notification payload — _showSnackBar would skip display.
      expect(captured.first.notification, isNull);
    });

    test('scaffoldMessengerKey is a valid GlobalKey', () {
      expect(NotificationHandler.scaffoldMessengerKey, isNotNull);
      expect(
        NotificationHandler.scaffoldMessengerKey,
        isA<GlobalKey<ScaffoldMessengerState>>(),
      );
    });
  });
}

