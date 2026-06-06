import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/design_system/widgets/progress_dots.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';

/// The first onboarding step: a calm welcome that states Mindow's promise.
///
/// Presentational only — reads/writes nothing. Both the primary CTA and the
/// always-available "Passer" link advance out of the welcome step (UX-DR7,
/// UX-DR13, UX-DR17 first-launch).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    // "Passer" skips the whole onboarding; "Commencer" enters the context step.
    void skip() => context.go(Routes.home);
    void start() => context.go(Routes.onboardingContext);

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: skip,
                  style: TextButton.styleFrom(
                    foregroundColor: AuroreColors.inkMuted,
                  ),
                  child: Text(l10n.onboardingSkip),
                ),
              ),
              const Spacer(),
              Text(
                l10n.onboardingWelcomeHeadline,
                style: textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuroreSpacing.lg),
              Text(
                l10n.onboardingWelcomeBody,
                style: textTheme.bodyLarge?.copyWith(
                  color: AuroreColors.inkMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const ProgressDots(count: 3, activeIndex: 0),
              const SizedBox(height: AuroreSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: start,
                  child: Text(l10n.onboardingWelcomeCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
