// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_answers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingAnswers _$OnboardingAnswersFromJson(Map<String, dynamic> json) =>
    _OnboardingAnswers(
      ageRange: $enumDecodeNullable(_$AgeRangeEnumMap, json['age_range']),
      familySituation: $enumDecodeNullable(
        _$FamilySituationEnumMap,
        json['family_situation'],
      ),
      stressLevel: $enumDecodeNullable(
        _$StressLevelEnumMap,
        json['stress_level'],
      ),
      mindVolumeBucket: $enumDecodeNullable(
        _$MindVolumeBucketEnumMap,
        json['mind_volume_bucket'],
      ),
    );

Map<String, dynamic> _$OnboardingAnswersToJson(
  _OnboardingAnswers instance,
) => <String, dynamic>{
  'age_range': _$AgeRangeEnumMap[instance.ageRange],
  'family_situation': _$FamilySituationEnumMap[instance.familySituation],
  'stress_level': _$StressLevelEnumMap[instance.stressLevel],
  'mind_volume_bucket': _$MindVolumeBucketEnumMap[instance.mindVolumeBucket],
};

const _$AgeRangeEnumMap = {
  AgeRange.under25: 'under25',
  AgeRange.from25to34: 'from25to34',
  AgeRange.from35to44: 'from35to44',
  AgeRange.from45to54: 'from45to54',
  AgeRange.over55: 'over55',
};

const _$FamilySituationEnumMap = {
  FamilySituation.single: 'single',
  FamilySituation.couple: 'couple',
  FamilySituation.withChildren: 'withChildren',
  FamilySituation.singleParent: 'singleParent',
};

const _$StressLevelEnumMap = {
  StressLevel.low: 'low',
  StressLevel.moderate: 'moderate',
  StressLevel.high: 'high',
  StressLevel.veryHigh: 'veryHigh',
};

const _$MindVolumeBucketEnumMap = {
  MindVolumeBucket.upTo10: 'upTo10',
  MindVolumeBucket.from10to20: 'from10to20',
  MindVolumeBucket.from20to50: 'from20to50',
  MindVolumeBucket.over50: 'over50',
};
