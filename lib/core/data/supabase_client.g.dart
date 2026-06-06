// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the initialized Supabase client to the rest of the app.
///
/// Reading this before `Supabase.initialize` has run (e.g. when no backend is
/// configured for the current flavor) will throw — call sites in feature code
/// are only reached after a configured session exists.

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// Exposes the initialized Supabase client to the rest of the app.
///
/// Reading this before `Supabase.initialize` has run (e.g. when no backend is
/// configured for the current flavor) will throw — call sites in feature code
/// are only reached after a configured session exists.

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Exposes the initialized Supabase client to the rest of the app.
  ///
  /// Reading this before `Supabase.initialize` has run (e.g. when no backend is
  /// configured for the current flavor) will throw — call sites in feature code
  /// are only reached after a configured session exists.
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'3db2a4c212c7f24cea9810e376225aa1a6cab012';
