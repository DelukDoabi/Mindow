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
}

/// Provides the shared [OnboardingRepository].
@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) => OnboardingRepository();
