import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/auth/account_screen.dart';
import 'package:mindow/features/auth/auth_controller.dart';
import 'package:mindow/features/auth/auth_repository.dart';
import 'package:mindow/features/onboarding/onboarding_consent_screen.dart';
import 'package:mindow/features/onboarding/onboarding_context_screen.dart';
import 'package:mindow/features/onboarding/onboarding_mind_volume_screen.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';
import 'package:mindow/features/onboarding/welcome_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Route path constants. Centralized so deep links and guards stay consistent.
abstract final class Routes {
  Routes._();

  static const String welcome = '/welcome';
  static const String onboardingContext = '/onboarding/context';
  static const String onboardingMindVolume = '/onboarding/mind-volume';
  static const String onboardingConsent = '/onboarding/consent';
  static const String account = '/onboarding/account';
  static const String home = '/';
}

/// Whether [location] belongs to the welcome/onboarding flow that a returning,
/// onboarded user should be redirected away from.
bool _isOnboardingRoute(String location) =>
    location == Routes.welcome || location.startsWith('/onboarding');

/// The app's [GoRouter].
///
/// Onboarding begins at the welcome step. A returning, authenticated user who
/// has already completed onboarding is redirected straight to the Mental
/// Backpack (Home) by the `redirect` guard below (Story 1.5); the redirect is
/// re-evaluated reactively whenever the auth state changes. The premium guard
/// (Epic 6) hooks into the same `redirect` later.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Re-run `redirect` on auth changes without rebuilding the router (which
  // would drop the navigation stack): a side-effect listen bumps a notifier.
  final refresh = ValueNotifier<int>(0);
  ref
    ..onDispose(refresh.dispose)
    ..listen(authStateProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref
          .read(authRepositoryProvider)
          .currentSnapshot
          .isSignedIn;
      final onboardingComplete = ref.read(onboardingCompleteProvider);
      if (signedIn &&
          onboardingComplete &&
          _isOnboardingRoute(state.matchedLocation)) {
        return Routes.home;
      }
      return null;
    },
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
        path: Routes.onboardingConsent,
        builder: (context, state) => const OnboardingConsentScreen(),
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
