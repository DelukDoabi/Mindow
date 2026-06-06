// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the in-progress onboarding answers and persists every change.
///
/// Starts empty and best-effort hydrates from the local draft so returning to
/// a question shows the previous selection (AC#3). Each setter updates state
/// and persists fire-and-forget — no question is a gate (AC#2).

@ProviderFor(OnboardingDraft)
final onboardingDraftProvider = OnboardingDraftProvider._();

/// Holds the in-progress onboarding answers and persists every change.
///
/// Starts empty and best-effort hydrates from the local draft so returning to
/// a question shows the previous selection (AC#3). Each setter updates state
/// and persists fire-and-forget — no question is a gate (AC#2).
final class OnboardingDraftProvider
    extends $NotifierProvider<OnboardingDraft, OnboardingAnswers> {
  /// Holds the in-progress onboarding answers and persists every change.
  ///
  /// Starts empty and best-effort hydrates from the local draft so returning to
  /// a question shows the previous selection (AC#3). Each setter updates state
  /// and persists fire-and-forget — no question is a gate (AC#2).
  OnboardingDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingDraftHash();

  @$internal
  @override
  OnboardingDraft create() => OnboardingDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingAnswers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingAnswers>(value),
    );
  }
}

String _$onboardingDraftHash() => r'bb12562c5c5647a51063b03782eb55b09dc332b0';

/// Holds the in-progress onboarding answers and persists every change.
///
/// Starts empty and best-effort hydrates from the local draft so returning to
/// a question shows the previous selection (AC#3). Each setter updates state
/// and persists fire-and-forget — no question is a gate (AC#2).

abstract class _$OnboardingDraft extends $Notifier<OnboardingAnswers> {
  OnboardingAnswers build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingAnswers, OnboardingAnswers>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingAnswers, OnboardingAnswers>,
              OnboardingAnswers,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
