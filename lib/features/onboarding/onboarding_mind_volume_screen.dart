import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/design_system/widgets/aurore_choice_chip.dart';
import 'package:mindow/core/design_system/widgets/progress_dots.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';
import 'package:mindow/features/onboarding/onboarding_answers.dart';
import 'package:mindow/features/onboarding/onboarding_controller.dart';

/// Third onboarding step: how many subjects occupy the user's mind (FR-3
/// buckets). Skippable; persists via [OnboardingDraft]. Both "Passer" and
/// "Continuer" leave onboarding (account creation arrives in Story 1.4).
class OnboardingMindVolumeScreen extends ConsumerWidget {
  const OnboardingMindVolumeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final answers = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);

    void finish() => context.go(Routes.home);

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: finish,
                  style: TextButton.styleFrom(
                    foregroundColor: AuroreColors.inkMuted,
                  ),
                  child: Text(l10n.onboardingSkip),
                ),
              ),
              const Spacer(),
              Text(
                l10n.onboardingMindVolumeTitle,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AuroreSpacing.sm),
              Text(
                l10n.onboardingMindVolumeSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AuroreColors.inkMuted,
                ),
              ),
              const SizedBox(height: AuroreSpacing.xl),
              Wrap(
                spacing: AuroreSpacing.sm,
                runSpacing: AuroreSpacing.sm,
                children: [
                  for (final value in MindVolumeBucket.values)
                    AuroreChoiceChip(
                      label: _bucketLabel(l10n, value),
                      selected: answers.mindVolumeBucket == value,
                      onTap: () => controller.setMindVolumeBucket(value),
                    ),
                ],
              ),
              const Spacer(),
              const Center(child: ProgressDots(count: 3, activeIndex: 2)),
              const SizedBox(height: AuroreSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: finish,
                  child: Text(l10n.onboardingContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _bucketLabel(AppLocalizations l10n, MindVolumeBucket value) =>
    switch (value) {
      MindVolumeBucket.upTo10 => l10n.onboardingMindVolumeUpTo10,
      MindVolumeBucket.from10to20 => l10n.onboardingMindVolume10to20,
      MindVolumeBucket.from20to50 => l10n.onboardingMindVolume20to50,
      MindVolumeBucket.over50 => l10n.onboardingMindVolumeOver50,
    };
