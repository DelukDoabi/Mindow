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
