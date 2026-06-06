import 'package:mindow/features/auth/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Streams the current [AuthSnapshot] for the app.
///
/// This is the source the router `redirect` watches (Story 1.5) to decide
/// whether a returning, authenticated user should skip onboarding and land on
/// the Mental Backpack. It seeds with the persisted session restored on
/// relaunch, then follows live auth-state changes.
@riverpod
Stream<AuthSnapshot> authState(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
}
