import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/mental_load/domain/mental_load_projection.dart';
import 'package:mindow/features/mental_load/domain/weekly_progression_projection.dart';
import 'package:mindow/features/missions/missions_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mental_load_providers.g.dart';

/// The current Mental Load, derived from `openPreoccupationsProvider`.
///
/// Rebuilds automatically whenever `openPreoccupationsProvider` rebuilds,
/// which in turn rebuilds whenever `projectionRevisionProvider` bumps —
/// capture, edit, delete, and weight-assignment all propagate here without
/// additional wiring.
@riverpod
Future<MentalLoadProjection> mentalLoad(Ref ref) async {
  final items = await ref.watch(openPreoccupationsProvider.future);
  return MentalLoadProjection.fromPreoccupations(items);
}

/// Open-items count and weekly kg freed.
///
/// `kgFreedThisWeek` is always 0 in Epic 2 — the validation flow that closes
/// preoccupations is introduced in Story 3.3. The stub keeps the UI wired and
/// testable without blocking this story.
@riverpod
Future<WeeklyProgressionProjection> weeklyProgression(Ref ref) async {
  final items = await ref.watch(openPreoccupationsProvider.future);
  final kgFreedThisWeek = ref.watch(missionKgFreedThisWeekProvider);
  return WeeklyProgressionProjection(
    openCount: items.length,
    kgFreedThisWeek: kgFreedThisWeek,
  );
}
