import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/mental_load/domain/mental_load_projection.dart';
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
