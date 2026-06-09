// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mental_load_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current Mental Load, derived from `openPreoccupationsProvider`.
///
/// Rebuilds automatically whenever `openPreoccupationsProvider` rebuilds,
/// which in turn rebuilds whenever `projectionRevisionProvider` bumps —
/// capture, edit, delete, and weight-assignment all propagate here without
/// additional wiring.

@ProviderFor(mentalLoad)
final mentalLoadProvider = MentalLoadProvider._();

/// The current Mental Load, derived from `openPreoccupationsProvider`.
///
/// Rebuilds automatically whenever `openPreoccupationsProvider` rebuilds,
/// which in turn rebuilds whenever `projectionRevisionProvider` bumps —
/// capture, edit, delete, and weight-assignment all propagate here without
/// additional wiring.

final class MentalLoadProvider
    extends
        $FunctionalProvider<
          AsyncValue<MentalLoadProjection>,
          MentalLoadProjection,
          FutureOr<MentalLoadProjection>
        >
    with
        $FutureModifier<MentalLoadProjection>,
        $FutureProvider<MentalLoadProjection> {
  /// The current Mental Load, derived from `openPreoccupationsProvider`.
  ///
  /// Rebuilds automatically whenever `openPreoccupationsProvider` rebuilds,
  /// which in turn rebuilds whenever `projectionRevisionProvider` bumps —
  /// capture, edit, delete, and weight-assignment all propagate here without
  /// additional wiring.
  MentalLoadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mentalLoadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mentalLoadHash();

  @$internal
  @override
  $FutureProviderElement<MentalLoadProjection> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MentalLoadProjection> create(Ref ref) {
    return mentalLoad(ref);
  }
}

String _$mentalLoadHash() => r'a4de144668d4c5b7e243bdc6ecf37e2eba4c92d7';

/// Open-items count and weekly kg freed.
///
/// `kgFreedThisWeek` is always 0 in Epic 2 — the validation flow that closes
/// preoccupations is introduced in Story 3.3. The stub keeps the UI wired and
/// testable without blocking this story.

@ProviderFor(weeklyProgression)
final weeklyProgressionProvider = WeeklyProgressionProvider._();

/// Open-items count and weekly kg freed.
///
/// `kgFreedThisWeek` is always 0 in Epic 2 — the validation flow that closes
/// preoccupations is introduced in Story 3.3. The stub keeps the UI wired and
/// testable without blocking this story.

final class WeeklyProgressionProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyProgressionProjection>,
          WeeklyProgressionProjection,
          FutureOr<WeeklyProgressionProjection>
        >
    with
        $FutureModifier<WeeklyProgressionProjection>,
        $FutureProvider<WeeklyProgressionProjection> {
  /// Open-items count and weekly kg freed.
  ///
  /// `kgFreedThisWeek` is always 0 in Epic 2 — the validation flow that closes
  /// preoccupations is introduced in Story 3.3. The stub keeps the UI wired and
  /// testable without blocking this story.
  WeeklyProgressionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyProgressionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyProgressionHash();

  @$internal
  @override
  $FutureProviderElement<WeeklyProgressionProjection> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyProgressionProjection> create(Ref ref) {
    return weeklyProgression(ref);
  }
}

String _$weeklyProgressionHash() => r'07dbaa0991c9b8415d21efc344fb76f6c57efba0';
