// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the shared [AiClient] over the authenticated Supabase client.

@ProviderFor(aiClient)
final aiClientProvider = AiClientProvider._();

/// Provides the shared [AiClient] over the authenticated Supabase client.

final class AiClientProvider
    extends $FunctionalProvider<AiClient, AiClient, AiClient>
    with $Provider<AiClient> {
  /// Provides the shared [AiClient] over the authenticated Supabase client.
  AiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiClientHash();

  @$internal
  @override
  $ProviderElement<AiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiClient create(Ref ref) {
    return aiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiClient>(value),
    );
  }
}

String _$aiClientHash() => r'6e3657f9dbba618857b662364b2192e9a6323914';
