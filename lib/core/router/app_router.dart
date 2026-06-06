import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/auth/account_screen.dart';
import 'package:mindow/features/onboarding/onboarding_context_screen.dart';
import 'package:mindow/features/onboarding/onboarding_mind_volume_screen.dart';
import 'package:mindow/features/onboarding/welcome_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Route path constants. Centralized so deep links and guards stay consistent.
abstract final class Routes {
  Routes._();

  static const String welcome = '/welcome';
  static const String onboardingContext = '/onboarding/context';
  static const String onboardingMindVolume = '/onboarding/mind-volume';
  static const String account = '/onboarding/account';
  static const String home = '/';
}

/// The app's [GoRouter].
///
/// Onboarding begins at the welcome step. Auth and first-launch vs
/// returning-user redirects (Stories 1.4/1.5) and the premium guard (Epic 6)
/// hook into the `redirect` callback added here later.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.welcome,
    routes: [
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.onboardingContext,
        builder: (context, state) => const OnboardingContextScreen(),
      ),
      GoRoute(
        path: Routes.onboardingMindVolume,
        builder: (context, state) => const OnboardingMindVolumeScreen(),
      ),
      GoRoute(
        path: Routes.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const _PlaceholderHome(),
      ),
    ],
  );
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AuroreCanvas(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AuroreSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.homeWelcomeTitle,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuroreSpacing.md),
                Text(
                  l10n.homeWelcomeBody,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AuroreColors.inkMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
