import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Route path constants. Centralized so deep links and guards stay consistent.
abstract final class Routes {
  Routes._();

  static const String home = '/';
}

/// The app's [GoRouter].
///
/// Minimal during the scaffold phase: a single placeholder home route. Auth
/// and onboarding redirects (Epic 1) and the premium guard (Epic 6) hook into
/// the `redirect` callback added here later.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
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

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AuroreColors.canvasGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
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
      ),
    );
  }
}
