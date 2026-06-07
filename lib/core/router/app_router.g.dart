// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter].
///
/// Onboarding begins at the welcome step. A returning, authenticated user who
/// has already completed onboarding is redirected straight to the Mental
/// Backpack (Home) by the `redirect` guard below (Story 1.5); the redirect is
/// re-evaluated reactively whenever the auth state changes. The premium guard
/// (Epic 6) hooks into the same `redirect` later.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's [GoRouter].
///
/// Onboarding begins at the welcome step. A returning, authenticated user who
/// has already completed onboarding is redirected straight to the Mental
/// Backpack (Home) by the `redirect` guard below (Story 1.5); the redirect is
/// re-evaluated reactively whenever the auth state changes. The premium guard
/// (Epic 6) hooks into the same `redirect` later.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter].
  ///
  /// Onboarding begins at the welcome step. A returning, authenticated user who
  /// has already completed onboarding is redirected straight to the Mental
  /// Backpack (Home) by the `redirect` guard below (Story 1.5); the redirect is
  /// re-evaluated reactively whenever the auth state changes. The premium guard
  /// (Epic 6) hooks into the same `redirect` later.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'0c2938e2cc3d3c29422d638d6a676d489d2a83e9';
