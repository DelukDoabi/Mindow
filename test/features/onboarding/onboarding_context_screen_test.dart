import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/onboarding/onboarding_answers.dart';
import 'package:mindow/features/onboarding/onboarding_context_screen.dart';
import 'package:mindow/features/onboarding/onboarding_controller.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

/// In-memory repository so the controller never touches Hive in tests.
class _FakeOnboardingRepository extends OnboardingRepository {
  OnboardingAnswers _stored = const OnboardingAnswers();

  @override
  Future<OnboardingAnswers> load() async => _stored;

  @override
  Future<void> save(OnboardingAnswers answers) async => _stored = answers;
}

void main() {
  Future<ProviderContainer> pumpContext(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(
          _FakeOnboardingRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/onboarding/context',
      routes: [
        GoRoute(
          path: '/onboarding/context',
          builder: (context, state) => const OnboardingContextScreen(),
        ),
        GoRoute(
          path: '/onboarding/mind-volume',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
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
    return container;
  }

  testWidgets('shows the title and an always-available "Passer"', (
    tester,
  ) async {
    await pumpContext(tester);

    expect(find.text('Parle-nous un peu de toi'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('selecting an age chip records it in the draft', (tester) async {
    final container = await pumpContext(tester);

    expect(container.read(onboardingDraftProvider).ageRange, isNull);

    await tester.tap(find.text('Moins de 25 ans'));
    await tester.pumpAndSettle();

    expect(
      container.read(onboardingDraftProvider).ageRange,
      AgeRange.under25,
    );
  });
}
