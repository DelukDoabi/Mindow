import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mindow/app/env.dart';
import 'package:mindow/core/data/supabase_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

/// A minimal, backend-agnostic snapshot of the current authentication state.
///
/// Deliberately does NOT expose any `supabase_flutter` type so that screens
/// and controllers never depend on the backend SDK — [AuthRepository] is the
/// single boundary.
class AuthSnapshot {
  const AuthSnapshot({this.userId});

  /// The authenticated user's id, or `null` when signed out.
  final String? userId;

  /// Whether a user is currently authenticated.
  bool get isSignedIn => userId != null;
}

/// Thrown when an authentication action is attempted but no backend is
/// configured for the current flavor (UI-only scaffold builds).
class AuthUnavailableException implements Exception {
  const AuthUnavailableException();
}

/// The single boundary to Supabase Auth.
///
/// Every authentication action funnels through here so the rest of the app
/// depends on this abstraction (mirrors the offline-first repository pattern).
/// When no backend is configured ([SupabaseClient] is `null`), reads degrade
/// to a signed-out snapshot and actions throw [AuthUnavailableException] only
/// when actually invoked — construction and screen build never throw.
class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient? _client;

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) throw const AuthUnavailableException();
    return client;
  }

  /// The current snapshot, derived from the persisted Supabase session.
  AuthSnapshot get currentSnapshot =>
      AuthSnapshot(userId: _client?.auth.currentSession?.user.id);

  /// Emits a new snapshot whenever the auth state changes (sign-in, sign-out,
  /// token refresh, session restore on relaunch).
  Stream<AuthSnapshot> authStateChanges() {
    final client = _client;
    if (client == null) {
      return const Stream<AuthSnapshot>.empty();
    }
    return client.auth.onAuthStateChange.map(
      (state) => AuthSnapshot(userId: state.session?.user.id),
    );
  }

  /// Starts the Apple OAuth sign-in flow.
  Future<void> signInWithApple() => _requireClient().auth.signInWithOAuth(
    OAuthProvider.apple,
    redirectTo: _webRedirectTo,
  );

  /// Starts the Google OAuth sign-in flow.
  Future<void> signInWithGoogle() => _requireClient().auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: _webRedirectTo,
  );

  /// On Flutter web, returns the canonical app origin + path so that the PKCE
  /// `?code=` callback lands on a URL that exactly matches the allowed redirect
  /// URLs configured in the Supabase dashboard. The hash fragment (/#/route)
  /// is excluded so it does not corrupt the redirect URL matching.
  ///
  /// Returns `null` on native platforms where the deep-link scheme is used.
  static String? get _webRedirectTo {
    if (!kIsWeb) return null;
    final base = Uri.base;
    // `authority` already includes the port when non-standard (e.g. localhost).
    return '${base.scheme}://${base.authority}${base.path}';
  }

  /// Signs in with email + password, creating the account if it does not yet
  /// exist. Sign-in is attempted first; on failure a sign-up is performed.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _requireClient();
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthException {
      await client.auth.signUp(email: email, password: password);
    }
  }

  /// Signs the current user out.
  Future<void> signOut() => _requireClient().auth.signOut();

  /// Requests a GDPR data export (NFR-10).
  ///
  /// Invokes the `account-export` Edge Function, which gathers the user's
  /// Preoccupations and derived data server-side and handles delivery. The
  /// full data cascade completes with the Epic 2 data model.
  Future<void> exportData() async {
    await _requireClient().functions.invoke('account-export');
  }

  /// Permanently deletes the current account and all its data (NFR-10).
  ///
  /// Invokes the `account-delete` Edge Function, which cascade-erases the
  /// user's Preoccupations and derived data server-side, then signs out.
  Future<void> deleteAccount() async {
    await _requireClient().functions.invoke('account-delete');
    await signOut();
  }
}

/// Provides the shared [AuthRepository].
///
/// Passes a `null` client when the active flavor has no Supabase backend so
/// the scaffold still boots; otherwise reuses [supabaseClientProvider].
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final env = ref.watch(envProvider);
  final client = env.hasSupabase ? ref.watch(supabaseClientProvider) : null;
  return AuthRepository(client);
}
