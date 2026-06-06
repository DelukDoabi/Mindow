import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/widgets/progress_dots.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/onboarding/welcome_screen.dart';

void main() {
  Future<void> pumpWelcome(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
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

  testWidgets('shows the localized promise headline and body', (tester) async {
    await pumpWelcome(tester);

    expect(
      find.text("Décharge ton esprit. On s'occupe du reste."),
      findsOneWidget,
    );
    expect(
      find.text(
        'Dépose tout ce qui occupe ton esprit. '
        "Mindow t'aide à porter moins, un objet à la fois.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('always offers a "Passer" secondary action', (tester) async {
    await pumpWelcome(tester);

    final skip = find.text('Passer');
    expect(skip, findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('shows the "Commencer" primary CTA', (tester) async {
    await pumpWelcome(tester);

    expect(find.text('Commencer'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('renders 3 progress dots with the first active', (tester) async {
    await pumpWelcome(tester);

    final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
    expect(dots.count, 3);
    expect(dots.activeIndex, 0);
  });
}
