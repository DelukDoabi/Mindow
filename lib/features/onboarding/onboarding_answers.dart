import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_answers.freezed.dart';
part 'onboarding_answers.g.dart';

/// Age bracket the user optionally selects during onboarding (FR-3).
enum AgeRange { under25, from25to34, from35to44, from45to54, over55 }

/// Family situation the user optionally selects during onboarding (FR-3).
enum FamilySituation { single, couple, withChildren, singleParent }

/// Self-reported current stress level (FR-3).
enum StressLevel { low, moderate, high, veryHigh }

/// How many subjects currently occupy the user's mind (FR-3 buckets).
enum MindVolumeBucket { upTo10, from10to20, from20to50, over50 }

/// The optional onboarding context the user shares about themselves.
///
/// Every field is nullable: each question is skippable and progression still
/// succeeds (FR-3). Persisted locally as a draft until Story 1.4 attaches it to
/// the account profile.
@freezed
abstract class OnboardingAnswers with _$OnboardingAnswers {
  const factory OnboardingAnswers({
    AgeRange? ageRange,
    FamilySituation? familySituation,
    StressLevel? stressLevel,
    MindVolumeBucket? mindVolumeBucket,
  }) = _OnboardingAnswers;

  factory OnboardingAnswers.fromJson(Map<String, dynamic> json) =>
      _$OnboardingAnswersFromJson(json);
}
