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

/// Second onboarding step: optional context (age, family, stress) — FR-3.
///
/// Every group is skippable; the answers persist via [OnboardingDraft]. Both
/// "Passer" and "Continuer" advance to the mind-volume step.
class OnboardingContextScreen extends ConsumerWidget {
  const OnboardingContextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final answers = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);

    void next() => context.go(Routes.onboardingMindVolume);

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
                  onPressed: next,
                  style: TextButton.styleFrom(
                    foregroundColor: AuroreColors.inkMuted,
                  ),
                  child: Text(l10n.onboardingSkip),
                ),
              ),
              Text(
                l10n.onboardingContextTitle,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AuroreSpacing.sm),
              Text(
                l10n.onboardingContextSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AuroreColors.inkMuted,
                ),
              ),
              const SizedBox(height: AuroreSpacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    _Group(
                      label: l10n.onboardingAgeRangeLabel,
                      children: [
                        for (final value in AgeRange.values)
                          AuroreChoiceChip(
                            label: _ageLabel(l10n, value),
                            selected: answers.ageRange == value,
                            onTap: () => controller.setAgeRange(value),
                          ),
                      ],
                    ),
                    _Group(
                      label: l10n.onboardingFamilyLabel,
                      children: [
                        for (final value in FamilySituation.values)
                          AuroreChoiceChip(
                            label: _familyLabel(l10n, value),
                            selected: answers.familySituation == value,
                            onTap: () => controller.setFamilySituation(value),
                          ),
                      ],
                    ),
                    _Group(
                      label: l10n.onboardingStressLabel,
                      children: [
                        for (final value in StressLevel.values)
                          AuroreChoiceChip(
                            label: _stressLabel(l10n, value),
                            selected: answers.stressLevel == value,
                            onTap: () => controller.setStressLevel(value),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuroreSpacing.lg),
              const Center(child: ProgressDots(count: 3, activeIndex: 1)),
              const SizedBox(height: AuroreSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: next,
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

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AuroreSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.titleSmall?.copyWith(color: AuroreColors.ink),
          ),
          const SizedBox(height: AuroreSpacing.md),
          Wrap(
            spacing: AuroreSpacing.sm,
            runSpacing: AuroreSpacing.sm,
            children: children,
          ),
        ],
      ),
    );
  }
}

String _ageLabel(AppLocalizations l10n, AgeRange value) => switch (value) {
  AgeRange.under25 => l10n.onboardingAgeUnder25,
  AgeRange.from25to34 => l10n.onboardingAge25to34,
  AgeRange.from35to44 => l10n.onboardingAge35to44,
  AgeRange.from45to54 => l10n.onboardingAge45to54,
  AgeRange.over55 => l10n.onboardingAgeOver55,
};

String _familyLabel(AppLocalizations l10n, FamilySituation value) =>
    switch (value) {
      FamilySituation.single => l10n.onboardingFamilySingle,
      FamilySituation.couple => l10n.onboardingFamilyCouple,
      FamilySituation.withChildren => l10n.onboardingFamilyWithChildren,
      FamilySituation.singleParent => l10n.onboardingFamilySingleParent,
    };

String _stressLabel(AppLocalizations l10n, StressLevel value) =>
    switch (value) {
      StressLevel.low => l10n.onboardingStressLow,
      StressLevel.moderate => l10n.onboardingStressModerate,
      StressLevel.high => l10n.onboardingStressHigh,
      StressLevel.veryHigh => l10n.onboardingStressVeryHigh,
    };
