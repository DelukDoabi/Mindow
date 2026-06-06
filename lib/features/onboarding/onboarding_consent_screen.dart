import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

/// AI-processing consent step (Story 1.6, NFR-9 Standard posture).
///
/// Shows a calm, clear privacy notice and captures explicit consent before
/// any worry can later be sent to the AI (the AI Analysis itself, and its
/// consent gate, land in Epic 2). Consent is recorded only on the explicit
/// affirmative action; "Passer" leaves it not-granted and exits to home.
class OnboardingConsentScreen extends ConsumerWidget {
  const OnboardingConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    Future<void> accept() async {
      await ref.read(onboardingRepositoryProvider).setAiConsent(granted: true);
      if (context.mounted) context.go(Routes.account);
    }

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(Routes.home),
                  style: TextButton.styleFrom(
                    foregroundColor: AuroreColors.inkMuted,
                  ),
                  child: Text(l10n.onboardingSkip),
                ),
              ),
              const Spacer(),
              Text(
                l10n.consentTitle,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuroreSpacing.lg),
              Text(
                l10n.consentBody,
                style: textTheme.bodyLarge?.copyWith(
                  color: AuroreColors.inkMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: accept,
                child: Text(l10n.consentAccept),
              ),
              const SizedBox(height: AuroreSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
