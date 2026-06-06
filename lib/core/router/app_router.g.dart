// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter].
///
/// Onboarding begins at the welcome step. Auth and first-launch vs
/// returning-user redirects (Stories 1.4/1.5) and the premium guard (Epic 6)
/// hook into the `redirect` callback added here later.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's [GoRouter].
///
/// Onboarding begins at the welcome step. Auth and first-launch vs
/// returning-user redirects (Stories 1.4/1.5) and the premium guard (Epic 6)
/// hook into the `redirect` callback added here later.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter].
  ///
  /// Onboarding begins at the welcome step. Auth and first-launch vs
  /// returning-user redirects (Stories 1.4/1.5) and the premium guard (Epic 6)
  /// hook into the `redirect` callback added here later.
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

String _$appRouterHash() => r'2621273dc753b5b65b6f993a9a35f39358dd553b';
