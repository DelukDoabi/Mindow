import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';
import 'package:mindow/features/auth/auth_repository.dart';
import 'package:mindow/features/mental_load/domain/weekly_progression_projection.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

/// In-memory auth repository so the router never initializes Supabase.
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.signedIn = false}) : super(null);

  final bool signedIn;
  final StreamController<AuthSnapshot> _controller =
      StreamController<AuthSnapshot>.broadcast();

  @override
  AuthSnapshot get currentSnapshot =>
      AuthSnapshot(userId: signedIn ? 'user-1' : null);

  @override
  Stream<AuthSnapshot> authStateChanges() => _controller.stream;

  void dispose() => _controller.close();
}

void main() {
  Future<void> pumpRouter(
    WidgetTester tester, {
    required bool signedIn,
    required bool onboardingComplete,
  }) async {
    // Tall viewport: the Home screen layout (hero + backpack + stat pills +
    // list + capture bar) needs more than the default 600px test height.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = _FakeAuthRepository(signedIn: signedIn);
    addTearDown(auth.dispose);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        onboardingCompleteProvider.overrideWithValue(onboardingComplete),
        weeklyProgressionProvider.overrideWithValue(
          const AsyncValue.data(
            WeeklyProgressionProjection(openCount: 0, kgFreedThisWeek: 0),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('returning user (signed in + complete) lands on Home', (
    tester,
  ) async {
    await pumpRouter(tester, signedIn: true, onboardingComplete: true);

    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
    expect(find.text(l10n.onboardingWelcomeHeadline), findsNothing);
  });

  testWidgets('first-time user (signed out) starts on welcome', (tester) async {
    await pumpRouter(tester, signedIn: false, onboardingComplete: false);

    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(find.text(l10n.onboardingWelcomeHeadline), findsOneWidget);
    expect(find.text(l10n.homeWelcomeTitle), findsNothing);
  });

  testWidgets(
    'authenticated but incomplete user is NOT skipped past onboarding',
    (
      tester,
    ) async {
      await pumpRouter(tester, signedIn: true, onboardingComplete: false);

      final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
      expect(find.text(l10n.onboardingWelcomeHeadline), findsOneWidget);
      expect(find.text(l10n.homeWelcomeTitle), findsNothing);
    },
  );

  testWidgets('no backend (signed out, incomplete) degrades to welcome', (
    tester,
  ) async {
    await pumpRouter(tester, signedIn: false, onboardingComplete: false);

    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(find.text(l10n.onboardingWelcomeHeadline), findsOneWidget);
  });
}
