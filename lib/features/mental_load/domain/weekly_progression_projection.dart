/// A read-only projection combining open-items count and weekly kg freed.
///
/// `openCount` is derived from `openPreoccupationsProvider.length`.
/// `kgFreedThisWeek` is a stub returning 0 in Epic 2 (no validation flow
/// yet). It will be wired to closed-preoccupation history in Story 3.3.
class WeeklyProgressionProjection {
  const WeeklyProgressionProjection({
    required this.openCount,
    required this.kgFreedThisWeek,
  });

  /// Number of currently open preoccupations.
  final int openCount;

  /// Kg freed in the trailing 7 days. Always 0 until Story 3.3.
  final int kgFreedThisWeek;
}
