import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/auth/account_screen.dart';
import 'package:mindow/features/auth/auth_repository.dart';
import 'package:mindow/features/onboarding/onboarding_answers.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

/// In-memory auth repository so the screen never initializes Supabase.
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.shouldThrow = false}) : super(null);

  final bool shouldThrow;
  int appleCalls = 0;

  @override
  Future<void> signInWithApple() async {
    appleCalls++;
    if (shouldThrow) throw const AuthUnavailableException();
  }
}

/// In-memory onboarding repository tracking the completion flag.
class _FakeOnboardingRepository extends OnboardingRepository {
  bool completed = false;

  @override
  Future<OnboardingAnswers> load() async => const OnboardingAnswers();

  @override
  Future<void> save(OnboardingAnswers answers) async {}

  @override
  Future<void> markComplete() async => completed = true;

  @override
  Future<bool> isComplete() async => completed;
}

void main() {
  Future<void> pumpAccount(
    WidgetTester tester, {
    required _FakeAuthRepository auth,
    required _FakeOnboardingRepository onboarding,
  }) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(onboarding),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/onboarding/account',
      routes: [
        GoRoute(
          path: '/onboarding/account',
          builder: (context, state) => const AccountScreen(),
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

  testWidgets('renders the three providers and an always-available "Passer"', (
    tester,
  ) async {
    await pumpAccount(
      tester,
      auth: _FakeAuthRepository(),
      onboarding: _FakeOnboardingRepository(),
    );

    expect(find.text('Garde tes progrès'), findsOneWidget);
    expect(find.text('Continuer avec Apple'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Continuer avec un e-mail'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
  });

  testWidgets('successful sign-in marks onboarding complete and routes home', (
    tester,
  ) async {
    final auth = _FakeAuthRepository();
    final onboarding = _FakeOnboardingRepository();
    await pumpAccount(tester, auth: auth, onboarding: onboarding);

    await tester.tap(find.text('Continuer avec Apple'));
    await tester.pumpAndSettle();

    expect(auth.appleCalls, 1);
    expect(onboarding.completed, isTrue);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a failed sign-in shows a calm error and stays on the screen', (
    tester,
  ) async {
    final auth = _FakeAuthRepository(shouldThrow: true);
    final onboarding = _FakeOnboardingRepository();
    await pumpAccount(tester, auth: auth, onboarding: onboarding);

    await tester.tap(find.text('Continuer avec Apple'));
    await tester.pumpAndSettle();

    expect(
      find.text('Petit souci de connexion. On réessaie ?'),
      findsOneWidget,
    );
    expect(onboarding.completed, isFalse);
    expect(find.text('home'), findsNothing);
  });
}
