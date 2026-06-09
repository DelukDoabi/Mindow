import 'package:mindow/features/brain_dump/domain/preoccupation.dart';

/// Derived read-model summarising the user's current Mental Load.
///
/// Computed on every `openPreoccupationsProvider` rebuild; never persisted to
/// Hive and allocated no `typeId`. A `Preoccupation` is "pending" when its
/// Mental Weight has not yet been assigned by AI analysis — pending items count
/// as open (they are visible in the list) but contribute 0 kg to the sum.
class MentalLoadProjection {
  /// Creates a Mental Load projection.
  const MentalLoadProjection({
    required this.totalKg,
    required this.hasPendingItems,
  });

  /// Computes the projection from a list of open [Preoccupation]s in a single
  /// pass for efficiency.
  factory MentalLoadProjection.fromPreoccupations(
    List<Preoccupation> items,
  ) {
    var totalKg = 0;
    var hasPending = false;
    for (final item in items) {
      if (item.isPending) {
        hasPending = true;
      } else {
        totalKg += item.mentalWeightKg!;
      }
    }
    return MentalLoadProjection(
      totalKg: totalKg,
      hasPendingItems: hasPending,
    );
  }

  /// Sum of assigned Mental Weights across all open Preoccupations (kg).
  ///
  /// Pending items (awaiting AI analysis) contribute 0 to this sum.
  final int totalKg;

  /// Whether at least one open Preoccupation is awaiting AI analysis.
  ///
  /// Shown as a `~` suffix on the hero numeral to set the user's expectation.
  final bool hasPendingItems;
}
