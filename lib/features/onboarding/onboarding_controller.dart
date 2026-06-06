import 'dart:async';

import 'package:mindow/features/onboarding/onboarding_answers.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Holds the in-progress onboarding answers and persists every change.
///
/// Starts empty and best-effort hydrates from the local draft so returning to
/// a question shows the previous selection (AC#3). Each setter updates state
/// and persists fire-and-forget — no question is a gate (AC#2).
@riverpod
class OnboardingDraft extends _$OnboardingDraft {
  @override
  OnboardingAnswers build() {
    unawaited(_hydrate());
    return const OnboardingAnswers();
  }

  Future<void> _hydrate() async {
    final saved = await ref.read(onboardingRepositoryProvider).load();
    if (saved != const OnboardingAnswers()) state = saved;
  }

  /// Sets the selected age range and persists.
  void setAgeRange(AgeRange value) => _persist(state.copyWith(ageRange: value));

  /// Sets the selected family situation and persists.
  void setFamilySituation(FamilySituation value) =>
      _persist(state.copyWith(familySituation: value));

  /// Sets the selected stress level and persists.
  void setStressLevel(StressLevel value) =>
      _persist(state.copyWith(stressLevel: value));

  /// Sets the selected mind-volume bucket and persists.
  void setMindVolumeBucket(MindVolumeBucket value) =>
      _persist(state.copyWith(mindVolumeBucket: value));

  void _persist(OnboardingAnswers next) {
    state = next;
    unawaited(ref.read(onboardingRepositoryProvider).save(next));
  }
}
