import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/auth/auth_repository.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';
import 'package:mindow/features/settings/settings_screen.dart';

/// In-memory auth repository so the screen never initializes Supabase.
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.shouldThrow = false}) : super(null);

  final bool shouldThrow;
  int exportCalls = 0;
  int deleteCalls = 0;

  @override
  Future<void> exportData() async {
    exportCalls++;
    if (shouldThrow) throw const AuthUnavailableException();
  }

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    if (shouldThrow) throw const AuthUnavailableException();
  }
}

/// In-memory onboarding repository so the screen never touches Hive.
class _FakeOnboardingRepository extends OnboardingRepository {
  bool _aiConsent = false;

  @override
  Future<bool> isAiConsentGranted() async => _aiConsent;

  @override
  Future<void> setAiConsent({required bool granted}) async {
    _aiConsent = granted;
  }
}

void main() {
  Future<void> pumpSettings(
    WidgetTester tester, {
    required _FakeAuthRepository auth,
    _FakeOnboardingRepository? onboarding,
  }) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(
          onboarding ?? _FakeOnboardingRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const Text('welcome'),
        ),
      ],
    );

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

  testWidgets('renders the title and both GDPR actions', (tester) async {
    await pumpSettings(tester, auth: _FakeAuthRepository());

    expect(find.text('Réglages'), findsOneWidget);
    expect(find.text('Exporter mes données'), findsOneWidget);
    expect(find.text('Supprimer mon compte'), findsOneWidget);
  });

  testWidgets('tapping export requests the export and confirms', (
    tester,
  ) async {
    final auth = _FakeAuthRepository();

    await pumpSettings(tester, auth: auth);
    await tester.tap(find.text('Exporter mes données'));
    await tester.pumpAndSettle();

    expect(auth.exportCalls, 1);
    expect(find.text('Ton export arrive. On te le prépare.'), findsOneWidget);
  });

  testWidgets('cancelling the delete dialog does not delete', (tester) async {
    final auth = _FakeAuthRepository();

    await pumpSettings(tester, auth: auth);
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(auth.deleteCalls, 0);
    expect(find.text('welcome'), findsNothing);
  });

  testWidgets('confirming the delete dialog deletes and routes to welcome', (
    tester,
  ) async {
    final auth = _FakeAuthRepository();

    await pumpSettings(tester, auth: auth);
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(auth.deleteCalls, 1);
    expect(find.text('welcome'), findsOneWidget);
  });

  testWidgets('a failing action shows the calm error and stays put', (
    tester,
  ) async {
    final auth = _FakeAuthRepository(shouldThrow: true);

    await pumpSettings(tester, auth: auth);
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(auth.deleteCalls, 1);
    expect(find.text('welcome'), findsNothing);
    expect(find.text('Petit souci. On réessaie ?'), findsOneWidget);
  });
}
