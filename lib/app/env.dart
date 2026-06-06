import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build flavors for Mindow. Each flavor maps to a distinct backend project,
/// bundle id suffix, and observability environment.
enum Flavor {
  dev,
  staging,
  prod;

  /// Human-readable label, surfaced in diagnostics and the app title.
  String get label => switch (this) {
    Flavor.dev => 'Mindow Dev',
    Flavor.staging => 'Mindow Staging',
    Flavor.prod => 'Mindow',
  };

  bool get isProduction => this == Flavor.prod;
}

/// Resolved runtime configuration for a given [Flavor].
///
/// Only PUBLIC values live here (Supabase anon key, PostHog public key,
/// Sentry DSN). Secrets never ship in the client — they live exclusively in
/// Supabase Edge Functions. All values are injected at build time via
/// `--dart-define` and default to empty so the app still boots without a
/// configured backend (useful for UI-only scaffold work).
class Env {
  const Env({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.posthogApiKey,
    required this.posthogHost,
  });

  /// Builds the [Env] for [flavor] from compile-time `--dart-define` values.
  factory Env.of(Flavor flavor) => Env(
    flavor: flavor,
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    sentryDsn: const String.fromEnvironment('SENTRY_DSN'),
    posthogApiKey: const String.fromEnvironment('POSTHOG_API_KEY'),
    posthogHost: const String.fromEnvironment(
      'POSTHOG_HOST',
      defaultValue: 'https://eu.i.posthog.com',
    ),
  );

  final Flavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String sentryDsn;
  final String posthogApiKey;
  final String posthogHost;

  bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  bool get hasSentry => sentryDsn.isNotEmpty;
  bool get hasPostHog => posthogApiKey.isNotEmpty;
}

/// Provides the active [Env]. Overridden in `bootstrap()` with the concrete
/// configuration for the launched flavor.
final envProvider = Provider<Env>(
  (ref) => throw UnimplementedError(
    'envProvider must be overridden in bootstrap() before use.',
  ),
);
