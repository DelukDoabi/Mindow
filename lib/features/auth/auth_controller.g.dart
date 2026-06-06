// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams the current [AuthSnapshot] for the app.
///
/// This is the source the router `redirect` watches (Story 1.5) to decide
/// whether a returning, authenticated user should skip onboarding and land on
/// the Mental Backpack. It seeds with the persisted session restored on
/// relaunch, then follows live auth-state changes.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Streams the current [AuthSnapshot] for the app.
///
/// This is the source the router `redirect` watches (Story 1.5) to decide
/// whether a returning, authenticated user should skip onboarding and land on
/// the Mental Backpack. It seeds with the persisted session restored on
/// relaunch, then follows live auth-state changes.

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthSnapshot>,
          AuthSnapshot,
          Stream<AuthSnapshot>
        >
    with $FutureModifier<AuthSnapshot>, $StreamProvider<AuthSnapshot> {
  /// Streams the current [AuthSnapshot] for the app.
  ///
  /// This is the source the router `redirect` watches (Story 1.5) to decide
  /// whether a returning, authenticated user should skip onboarding and land on
  /// the Mental Backpack. It seeds with the persisted session restored on
  /// relaunch, then follows live auth-state changes.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthSnapshot> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'f4afb6516b06a974e98fef898d0a38669d2c2b47';
