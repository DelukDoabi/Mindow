// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_answers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingAnswers {

 AgeRange? get ageRange; FamilySituation? get familySituation; StressLevel? get stressLevel; MindVolumeBucket? get mindVolumeBucket;
/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingAnswersCopyWith<OnboardingAnswers> get copyWith => _$OnboardingAnswersCopyWithImpl<OnboardingAnswers>(this as OnboardingAnswers, _$identity);

  /// Serializes this OnboardingAnswers to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingAnswers&&(identical(other.ageRange, ageRange) || other.ageRange == ageRange)&&(identical(other.familySituation, familySituation) || other.familySituation == familySituation)&&(identical(other.stressLevel, stressLevel) || other.stressLevel == stressLevel)&&(identical(other.mindVolumeBucket, mindVolumeBucket) || other.mindVolumeBucket == mindVolumeBucket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ageRange,familySituation,stressLevel,mindVolumeBucket);

@override
String toString() {
  return 'OnboardingAnswers(ageRange: $ageRange, familySituation: $familySituation, stressLevel: $stressLevel, mindVolumeBucket: $mindVolumeBucket)';
}


}

/// @nodoc
abstract mixin class $OnboardingAnswersCopyWith<$Res>  {
  factory $OnboardingAnswersCopyWith(OnboardingAnswers value, $Res Function(OnboardingAnswers) _then) = _$OnboardingAnswersCopyWithImpl;
@useResult
$Res call({
 AgeRange? ageRange, FamilySituation? familySituation, StressLevel? stressLevel, MindVolumeBucket? mindVolumeBucket
});




}
/// @nodoc
class _$OnboardingAnswersCopyWithImpl<$Res>
    implements $OnboardingAnswersCopyWith<$Res> {
  _$OnboardingAnswersCopyWithImpl(this._self, this._then);

  final OnboardingAnswers _self;
  final $Res Function(OnboardingAnswers) _then;

/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ageRange = freezed,Object? familySituation = freezed,Object? stressLevel = freezed,Object? mindVolumeBucket = freezed,}) {
  return _then(_self.copyWith(
ageRange: freezed == ageRange ? _self.ageRange : ageRange // ignore: cast_nullable_to_non_nullable
as AgeRange?,familySituation: freezed == familySituation ? _self.familySituation : familySituation // ignore: cast_nullable_to_non_nullable
as FamilySituation?,stressLevel: freezed == stressLevel ? _self.stressLevel : stressLevel // ignore: cast_nullable_to_non_nullable
as StressLevel?,mindVolumeBucket: freezed == mindVolumeBucket ? _self.mindVolumeBucket : mindVolumeBucket // ignore: cast_nullable_to_non_nullable
as MindVolumeBucket?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingAnswers].
extension OnboardingAnswersPatterns on OnboardingAnswers {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingAnswers value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingAnswers value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingAnswers():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingAnswers value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AgeRange? ageRange,  FamilySituation? familySituation,  StressLevel? stressLevel,  MindVolumeBucket? mindVolumeBucket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
return $default(_that.ageRange,_that.familySituation,_that.stressLevel,_that.mindVolumeBucket);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AgeRange? ageRange,  FamilySituation? familySituation,  StressLevel? stressLevel,  MindVolumeBucket? mindVolumeBucket)  $default,) {final _that = this;
switch (_that) {
case _OnboardingAnswers():
return $default(_that.ageRange,_that.familySituation,_that.stressLevel,_that.mindVolumeBucket);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AgeRange? ageRange,  FamilySituation? familySituation,  StressLevel? stressLevel,  MindVolumeBucket? mindVolumeBucket)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
return $default(_that.ageRange,_that.familySituation,_that.stressLevel,_that.mindVolumeBucket);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingAnswers implements OnboardingAnswers {
  const _OnboardingAnswers({this.ageRange, this.familySituation, this.stressLevel, this.mindVolumeBucket});
  factory _OnboardingAnswers.fromJson(Map<String, dynamic> json) => _$OnboardingAnswersFromJson(json);

@override final  AgeRange? ageRange;
@override final  FamilySituation? familySituation;
@override final  StressLevel? stressLevel;
@override final  MindVolumeBucket? mindVolumeBucket;

/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingAnswersCopyWith<_OnboardingAnswers> get copyWith => __$OnboardingAnswersCopyWithImpl<_OnboardingAnswers>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingAnswersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingAnswers&&(identical(other.ageRange, ageRange) || other.ageRange == ageRange)&&(identical(other.familySituation, familySituation) || other.familySituation == familySituation)&&(identical(other.stressLevel, stressLevel) || other.stressLevel == stressLevel)&&(identical(other.mindVolumeBucket, mindVolumeBucket) || other.mindVolumeBucket == mindVolumeBucket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ageRange,familySituation,stressLevel,mindVolumeBucket);

@override
String toString() {
  return 'OnboardingAnswers(ageRange: $ageRange, familySituation: $familySituation, stressLevel: $stressLevel, mindVolumeBucket: $mindVolumeBucket)';
}


}

/// @nodoc
abstract mixin class _$OnboardingAnswersCopyWith<$Res> implements $OnboardingAnswersCopyWith<$Res> {
  factory _$OnboardingAnswersCopyWith(_OnboardingAnswers value, $Res Function(_OnboardingAnswers) _then) = __$OnboardingAnswersCopyWithImpl;
@override @useResult
$Res call({
 AgeRange? ageRange, FamilySituation? familySituation, StressLevel? stressLevel, MindVolumeBucket? mindVolumeBucket
});




}
/// @nodoc
class __$OnboardingAnswersCopyWithImpl<$Res>
    implements _$OnboardingAnswersCopyWith<$Res> {
  __$OnboardingAnswersCopyWithImpl(this._self, this._then);

  final _OnboardingAnswers _self;
  final $Res Function(_OnboardingAnswers) _then;

/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ageRange = freezed,Object? familySituation = freezed,Object? stressLevel = freezed,Object? mindVolumeBucket = freezed,}) {
  return _then(_OnboardingAnswers(
ageRange: freezed == ageRange ? _self.ageRange : ageRange // ignore: cast_nullable_to_non_nullable
as AgeRange?,familySituation: freezed == familySituation ? _self.familySituation : familySituation // ignore: cast_nullable_to_non_nullable
as FamilySituation?,stressLevel: freezed == stressLevel ? _self.stressLevel : stressLevel // ignore: cast_nullable_to_non_nullable
as StressLevel?,mindVolumeBucket: freezed == mindVolumeBucket ? _self.mindVolumeBucket : mindVolumeBucket // ignore: cast_nullable_to_non_nullable
as MindVolumeBucket?,
  ));
}


}

// dart format on
