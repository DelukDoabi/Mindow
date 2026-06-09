/// Visual heaviness band derived from `MentalLoadProjection.totalKg`.
///
/// Boundaries (inclusive lower, exclusive upper):
/// - `leger`:      0–19 kg
/// - `modere`:    20–49 kg
/// - `lourd`:     50–79 kg
/// - `tresLourd`: 80+ kg
enum LoadBand {
  leger,
  modere,
  lourd,
  tresLourd;

  /// Returns the band for [totalKg].
  factory LoadBand.fromKg(int totalKg) {
    if (totalKg < 20) return LoadBand.leger;
    if (totalKg < 50) return LoadBand.modere;
    if (totalKg < 80) return LoadBand.lourd;
    return LoadBand.tresLourd;
  }

  /// Maps the band to a continuous [0.0, 3.0] value for animation.
  double get animationValue => switch (this) {
    LoadBand.leger => 0.0,
    LoadBand.modere => 1.0,
    LoadBand.lourd => 2.0,
    LoadBand.tresLourd => 3.0,
  };
}
