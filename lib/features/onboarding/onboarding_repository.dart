import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mindow/features/onboarding/onboarding_answers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_repository.g.dart';

/// Local-only persistence for the onboarding draft.
///
/// Stores the [OnboardingAnswers] `toJson` map in a plain Hive box (no
/// `TypeAdapter`/`typeId` — primitives only), so it never touches the Hive
/// type registry. There is no authenticated user during onboarding context
/// capture (account creation is Story 1.4); these values live on the device as
/// a draft and are attached to the account profile later.
class OnboardingRepository {
  static const String _boxName = 'onboarding';
  static const String _key = 'answers';
  static const String _completeKey = 'complete';
  static const String _aiConsentKey = 'ai_consent';

  Box<dynamic>? _box;

  Future<Box<dynamic>> _openBox() async =>
      _box ??= await Hive.openBox<dynamic>(_boxName);

  /// Loads the persisted answers, or empty answers if nothing was saved yet.
  Future<OnboardingAnswers> load() async {
    final box = await _openBox();
    final raw = box.get(_key);
    if (raw is! Map) return const OnboardingAnswers();
    return OnboardingAnswers.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Persists the given answers, replacing any previous draft.
  Future<void> save(OnboardingAnswers answers) async {
    final box = await _openBox();
    await box.put(_key, answers.toJson());
  }

  /// Records that onboarding has been completed (after account creation) so a
  /// returning user never sees onboarding again on this device (FR-1).
  Future<void> markComplete() async {
    final box = await _openBox();
    await box.put(_completeKey, true);
  }

  /// Whether onboarding has been completed on this device.
  Future<bool> isComplete() async {
    final box = await _openBox();
    return box.get(_completeKey) == true;
  }

  /// Records the user's explicit choice on third-party AI processing (NFR-9).
  ///
  /// Only an explicit affirmative action sets `granted: true`; the value is
  /// persisted locally and read back by the Epic 2 AI-Analysis gate before any
  /// Preoccupation is sent to the AI. Server-profile sync rides the Epic 2
  /// sync engine.
  Future<void> setAiConsent({required bool granted}) async {
    final box = await _openBox();
    await box.put(_aiConsentKey, granted);
  }

  /// Whether the user has explicitly consented to AI processing on this device.
  Future<bool> isAiConsentGranted() async {
    final box = await _openBox();
    return box.get(_aiConsentKey) == true;
  }
}

/// Provides the shared [OnboardingRepository].
@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) => OnboardingRepository();

/// Whether onboarding was completed, seeded synchronously at bootstrap.
///
/// The router `redirect` is synchronous and must resolve before the first
/// frame (no blocking spinner / no welcome flash, UX-DR17 cold open), but
/// [OnboardingRepository.isComplete] is async (Hive). This hand-written
/// `Provider` exists only to be overridden in `bootstrap.dart` with the value
/// read once after `Hive.initFlutter()` — mirroring the `envProvider` seed.
final onboardingCompleteProvider = Provider<bool>(
  (ref) => throw UnimplementedError(
    'onboardingCompleteProvider seeded in bootstrap',
  ),
);
