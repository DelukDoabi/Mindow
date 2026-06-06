import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/onboarding/onboarding_answers.dart';
import 'package:mindow/features/onboarding/onboarding_consent_screen.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

/// In-memory onboarding repository tracking the AI-consent flag.
class _FakeOnboardingRepository extends OnboardingRepository {
  bool? consent;

  @override
  Future<OnboardingAnswers> load() async => const OnboardingAnswers();

  @override
  Future<void> save(OnboardingAnswers answers) async {}

  @override
  Future<void> setAiConsent({required bool granted}) async => consent = granted;

  @override
  Future<bool> isAiConsentGranted() async => consent ?? false;
}

void main() {
  Future<void> pumpConsent(
    WidgetTester tester, {
    required _FakeOnboardingRepository onboarding,
  }) async {
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboarding),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/onboarding/consent',
      routes: [
        GoRoute(
          path: '/onboarding/consent',
          builder: (context, state) => const OnboardingConsentScreen(),
        ),
        GoRoute(
          path: '/onboarding/account',
          builder: (context, state) => const Text('account'),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Text('home'),
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

  testWidgets('renders the privacy notice, consent action, and "Passer"', (
    tester,
  ) async {
    await pumpConsent(tester, onboarding: _FakeOnboardingRepository());

    expect(find.text('Tes mots restent à toi'), findsOneWidget);
    expect(find.text("J'ai compris, j'accepte"), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
    expect(
      find.textContaining("envoyé à notre partenaire d'IA"),
      findsOneWidget,
    );
  });

  testWidgets('tapping accept records consent and routes to account', (
    tester,
  ) async {
    final onboarding = _FakeOnboardingRepository();

    await pumpConsent(tester, onboarding: onboarding);
    await tester.tap(find.text("J'ai compris, j'accepte"));
    await tester.pumpAndSettle();

    expect(onboarding.consent, isTrue);
    expect(find.text('account'), findsOneWidget);
  });

  testWidgets('tapping "Passer" leaves consent not-granted and routes home', (
    tester,
  ) async {
    final onboarding = _FakeOnboardingRepository();

    await pumpConsent(tester, onboarding: onboarding);
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(onboarding.consent, isNull);
    expect(find.text('home'), findsOneWidget);
  });
}
