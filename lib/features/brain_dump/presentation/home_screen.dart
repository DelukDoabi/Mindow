import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/brain_dump/presentation/crisis_support_view.dart';
import 'package:mindow/features/brain_dump/presentation/edit_preoccupation_sheet.dart';
import 'package:mindow/features/mental_load/presentation/backpack_widget.dart';
import 'package:mindow/features/mental_load/presentation/mental_load_hero.dart';
import 'package:mindow/features/mental_load/presentation/stat_pill_row.dart';
import 'package:mindow/features/missions/missions_providers.dart';
import 'package:mindow/features/missions/missions_repository.dart';

/// The Mental Backpack home: the single place a user sets a worry down.
///
/// The capture input is reachable in one tap (UX-DR12) and writes through the
/// offline-first sync engine: a submit appends a `preoccupation.captured` event
/// to the local outbox and the item appears immediately in pending state, with
/// no wait on the network or AI (NFR-1, NFR-3). The animated backpack and kg
/// figure land in later stories — here the list stays intentionally minimal.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  final _listScrollController = ScrollController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _scrollListToTop() {
    if (!_listScrollController.hasClients) return;
    unawaited(
      _listScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onTextChanged() {
    final canSubmit = _controller.text.trim().isNotEmpty;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await ref.read(brainDumpRepositoryProvider).capturePreoccupation(content);
    _controller.clear();
    ref.invalidate(openPreoccupationsProvider);
    // Fire-and-forget: analysis never blocks capture (NFR-2).
    unawaited(ref.read(analysisServiceProvider).analyzePendingPreoccupations());

    if (!mounted) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.captureSuccess)));
  }

  Future<void> _runMissionValidation(String preoccupationId) async {
    final mission = ref
        .read(todayMissionProvider)
        .maybeWhen(
          data: (result) => result.mission,
          orElse: () => null,
        );
    if (mission == null || mission.preoccupationId != preoccupationId) {
      ref
              .read(validationRequestedMissionIdProvider.notifier)
              .requestedMissionId =
          null;
      return;
    }

    final result = await ref
        .read(missionValidationServiceProvider)
        .validate(mission);

    ref.read(validationRequestedMissionIdProvider.notifier).requestedMissionId =
        null;
    ref.read(projectionRevisionProvider.notifier).bump();
    refreshTodayMission(ref);

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final message = result.wasAlreadyValidated
        ? l10n.dailyMissionValidationAlreadyDone
        : l10n.dailyMissionValidationSuccess(result.kgFreed);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final preoccupations = ref.watch(openPreoccupationsProvider);
    final todayMission = ref.watch(todayMissionProvider);

    ref.listen<List<String>>(crisisAlertsProvider, (previous, next) {
      final previousIds = previous ?? const <String>[];
      final newIds = next.where((id) => !previousIds.contains(id)).toList();
      if (newIds.isEmpty) return;
      // Show only the first new crisis dialog. If multiple items trip the gate
      // simultaneously, further ids are already in the provider's state and
      // will surface the next time the dialog is dismissed (sequential, not
      // stacked).
      final id = newIds.first;
      unawaited(
        showCrisisSupport(
          context,
          languageCode: Localizations.localeOf(context).languageCode,
        ).then(
          (_) => ref.read(crisisAlertsProvider.notifier).dismiss(id),
        ),
      );
    });

    ref.listen<String?>(validationRequestedMissionIdProvider, (previous, next) {
      if (next == null) return;
      unawaited(_runMissionValidation(next));
    });

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => context.go(Routes.settings),
                  color: AuroreColors.inkMuted,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
              Text(
                l10n.homeWelcomeTitle,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AuroreSpacing.lg),
              const MentalLoadHero(),
              const SizedBox(height: AuroreSpacing.lg),
              Center(
                child: BackpackWidget(onTap: _scrollListToTop),
              ),
              const SizedBox(height: AuroreSpacing.md),
              const StatPillRow(),
              const SizedBox(height: AuroreSpacing.lg),
              _DailyMissionSection(mission: todayMission),
              const SizedBox(height: AuroreSpacing.lg),
              Expanded(
                child: preoccupations.when(
                  data: (items) => items.isEmpty
                      ? _EmptyBackpack(message: l10n.homeEmptyBackpack)
                      : _PreoccupationList(
                          items: items,
                          controller: _listScrollController,
                          pendingLabel: l10n.capturePendingLabel,
                          weightUnitLabel: l10n.weightKgLabel,
                          categoryLabel: (token) => _categoryLabel(token, l10n),
                          onTapItem: (item) => showEditPreoccupationSheet(
                            context,
                            item: item,
                          ),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      _EmptyBackpack(message: l10n.homeEmptyBackpack),
                ),
              ),
              const SizedBox(height: AuroreSpacing.lg),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _canSubmit ? _submit() : null,
                decoration: InputDecoration(
                  hintText: l10n.captureInputPlaceholder,
                ),
              ),
              const SizedBox(height: AuroreSpacing.md),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                child: Text(l10n.captureSubmitButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyMissionSection extends ConsumerWidget {
  const _DailyMissionSection({required this.mission});

  final AsyncValue<DailyMissionResult> mission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return mission.when(
      loading: () => const SizedBox(height: 88),
      error: (_, _) => _buildEmptyCard(context, l10n, textTheme),
      data: (result) {
        final dailyMission = result.mission;
        if (dailyMission == null) {
          return _buildEmptyCard(context, l10n, textTheme);
        }
        if (isMissionDeferred(ref, dailyMission)) {
          return _buildEmptyCard(context, l10n, textTheme);
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AuroreColors.glass,
            borderRadius: BorderRadius.circular(AuroreRadii.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AuroreSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyMissionTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AuroreSpacing.sm),
                Text(
                  dailyMission.preoccupationContent,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AuroreSpacing.md),
                Text(
                  l10n.dailyMissionEstimatedDuration(
                    dailyMission.estimatedDurationMinutes,
                  ),
                  style: textTheme.labelMedium?.copyWith(
                    color: AuroreColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AuroreSpacing.xs),
                Text(
                  l10n.dailyMissionEstimatedKgGain(
                    dailyMission.estimatedKgGain,
                  ),
                  style: textTheme.labelMedium?.copyWith(
                    color: AuroreColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AuroreSpacing.md),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        unawaited(
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => _MissionContextSheet(
                              content: dailyMission.preoccupationContent,
                              title: l10n.dailyMissionContextTitle,
                              subtitle: l10n.dailyMissionContextSubtitle(
                                dailyMission.estimatedDurationMinutes,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(l10n.dailyMissionStartAction),
                    ),
                    const SizedBox(width: AuroreSpacing.sm),
                    TextButton(
                      onPressed: () {
                        deferMission(ref, dailyMission);
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(l10n.dailyMissionDeferredNote),
                            ),
                          );
                      },
                      child: Text(l10n.dailyMissionDeferAction),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        requestMissionValidation(ref, dailyMission);
                      },
                      child: Text(l10n.dailyMissionDoneAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuroreColors.glass,
        borderRadius: BorderRadius.circular(AuroreRadii.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AuroreSpacing.lg),
        child: Text(
          l10n.dailyMissionEmptyState,
          style: textTheme.bodyLarge?.copyWith(
            color: AuroreColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _MissionContextSheet extends StatelessWidget {
  const _MissionContextSheet({
    required this.title,
    required this.subtitle,
    required this.content,
  });

  final String title;
  final String subtitle;
  final String content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AuroreSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AuroreSpacing.sm),
            Text(subtitle, style: textTheme.labelMedium),
            const SizedBox(height: AuroreSpacing.lg),
            Text(content, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

/// The calm empty-state shown when the backpack holds nothing yet.
class _EmptyBackpack extends StatelessWidget {
  const _EmptyBackpack({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Text(
        message,
        style: textTheme.bodyLarge?.copyWith(color: AuroreColors.inkMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Maps a canonical Category token (FR source of truth) to its localized label.
String _categoryLabel(String token, AppLocalizations l10n) => switch (token) {
  'Administratif' => l10n.categoryAdministrative,
  'Famille' => l10n.categoryFamily,
  'Santé' => l10n.categoryHealth,
  'Travail' => l10n.categoryWork,
  'Finance' => l10n.categoryFinance,
  'Maison' => l10n.categoryHome,
  'Personnel' => l10n.categoryPersonal,
  'Voyage' => l10n.categoryTravel,
  _ => l10n.categoryOther,
};

/// A minimal list of captured Preoccupations, most recent first.
class _PreoccupationList extends StatelessWidget {
  const _PreoccupationList({
    required this.items,
    required this.controller,
    required this.pendingLabel,
    required this.weightUnitLabel,
    required this.categoryLabel,
    required this.onTapItem,
  });

  final List<Preoccupation> items;
  final ScrollController controller;
  final String pendingLabel;
  final String weightUnitLabel;
  final String Function(String token) categoryLabel;
  final void Function(Preoccupation item) onTapItem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView.separated(
      controller: controller,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AuroreSpacing.sm),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(AuroreRadii.md),
          onTap: () => onTapItem(item),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AuroreColors.glass,
              borderRadius: BorderRadius.circular(AuroreRadii.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AuroreSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(item.content, style: textTheme.bodyLarge),
                  ),
                  if (item.isPending) ...[
                    const SizedBox(width: AuroreSpacing.md),
                    Text(
                      pendingLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: AuroreColors.inkMuted,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: AuroreSpacing.md),
                    if (item.category != null)
                      _CategoryChip(label: categoryLabel(item.category!)),
                    const SizedBox(width: AuroreSpacing.sm),
                    Text(
                      '${item.mentalWeightKg} $weightUnitLabel',
                      style: textTheme.labelMedium?.copyWith(
                        color: AuroreColors.ink,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A small pill rendering a Preoccupation's Category.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuroreColors.glassStrong,
        borderRadius: BorderRadius.circular(AuroreRadii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AuroreSpacing.sm,
          vertical: AuroreSpacing.xs,
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: AuroreColors.ink),
        ),
      ),
    );
  }
}
