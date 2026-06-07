// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preoccupation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Preoccupation {

 String get id; String get content; DateTime get createdAt; int? get mentalWeightKg; String? get category; int? get effortScore; int? get estimatedDurationMinutes; String? get weightModelVersion;
/// Create a copy of Preoccupation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreoccupationCopyWith<Preoccupation> get copyWith => _$PreoccupationCopyWithImpl<Preoccupation>(this as Preoccupation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preoccupation&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.mentalWeightKg, mentalWeightKg) || other.mentalWeightKg == mentalWeightKg)&&(identical(other.category, category) || other.category == category)&&(identical(other.effortScore, effortScore) || other.effortScore == effortScore)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.weightModelVersion, weightModelVersion) || other.weightModelVersion == weightModelVersion));
}


@override
int get hashCode => Object.hash(runtimeType,id,content,createdAt,mentalWeightKg,category,effortScore,estimatedDurationMinutes,weightModelVersion);

@override
String toString() {
  return 'Preoccupation(id: $id, content: $content, createdAt: $createdAt, mentalWeightKg: $mentalWeightKg, category: $category, effortScore: $effortScore, estimatedDurationMinutes: $estimatedDurationMinutes, weightModelVersion: $weightModelVersion)';
}


}

/// @nodoc
abstract mixin class $PreoccupationCopyWith<$Res>  {
  factory $PreoccupationCopyWith(Preoccupation value, $Res Function(Preoccupation) _then) = _$PreoccupationCopyWithImpl;
@useResult
$Res call({
 String id, String content, DateTime createdAt, int? mentalWeightKg, String? category, int? effortScore, int? estimatedDurationMinutes, String? weightModelVersion
});




}
/// @nodoc
class _$PreoccupationCopyWithImpl<$Res>
    implements $PreoccupationCopyWith<$Res> {
  _$PreoccupationCopyWithImpl(this._self, this._then);

  final Preoccupation _self;
  final $Res Function(Preoccupation) _then;

/// Create a copy of Preoccupation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? createdAt = null,Object? mentalWeightKg = freezed,Object? category = freezed,Object? effortScore = freezed,Object? estimatedDurationMinutes = freezed,Object? weightModelVersion = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,mentalWeightKg: freezed == mentalWeightKg ? _self.mentalWeightKg : mentalWeightKg // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,effortScore: freezed == effortScore ? _self.effortScore : effortScore // ignore: cast_nullable_to_non_nullable
as int?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,weightModelVersion: freezed == weightModelVersion ? _self.weightModelVersion : weightModelVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Preoccupation].
extension PreoccupationPatterns on Preoccupation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Preoccupation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Preoccupation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Preoccupation value)  $default,){
final _that = this;
switch (_that) {
case _Preoccupation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Preoccupation value)?  $default,){
final _that = this;
switch (_that) {
case _Preoccupation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  DateTime createdAt,  int? mentalWeightKg,  String? category,  int? effortScore,  int? estimatedDurationMinutes,  String? weightModelVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Preoccupation() when $default != null:
return $default(_that.id,_that.content,_that.createdAt,_that.mentalWeightKg,_that.category,_that.effortScore,_that.estimatedDurationMinutes,_that.weightModelVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  DateTime createdAt,  int? mentalWeightKg,  String? category,  int? effortScore,  int? estimatedDurationMinutes,  String? weightModelVersion)  $default,) {final _that = this;
switch (_that) {
case _Preoccupation():
return $default(_that.id,_that.content,_that.createdAt,_that.mentalWeightKg,_that.category,_that.effortScore,_that.estimatedDurationMinutes,_that.weightModelVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  DateTime createdAt,  int? mentalWeightKg,  String? category,  int? effortScore,  int? estimatedDurationMinutes,  String? weightModelVersion)?  $default,) {final _that = this;
switch (_that) {
case _Preoccupation() when $default != null:
return $default(_that.id,_that.content,_that.createdAt,_that.mentalWeightKg,_that.category,_that.effortScore,_that.estimatedDurationMinutes,_that.weightModelVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Preoccupation extends Preoccupation {
  const _Preoccupation({required this.id, required this.content, required this.createdAt, this.mentalWeightKg, this.category, this.effortScore, this.estimatedDurationMinutes, this.weightModelVersion}): super._();
  

@override final  String id;
@override final  String content;
@override final  DateTime createdAt;
@override final  int? mentalWeightKg;
@override final  String? category;
@override final  int? effortScore;
@override final  int? estimatedDurationMinutes;
@override final  String? weightModelVersion;

/// Create a copy of Preoccupation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreoccupationCopyWith<_Preoccupation> get copyWith => __$PreoccupationCopyWithImpl<_Preoccupation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Preoccupation&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.mentalWeightKg, mentalWeightKg) || other.mentalWeightKg == mentalWeightKg)&&(identical(other.category, category) || other.category == category)&&(identical(other.effortScore, effortScore) || other.effortScore == effortScore)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.weightModelVersion, weightModelVersion) || other.weightModelVersion == weightModelVersion));
}


@override
int get hashCode => Object.hash(runtimeType,id,content,createdAt,mentalWeightKg,category,effortScore,estimatedDurationMinutes,weightModelVersion);

@override
String toString() {
  return 'Preoccupation(id: $id, content: $content, createdAt: $createdAt, mentalWeightKg: $mentalWeightKg, category: $category, effortScore: $effortScore, estimatedDurationMinutes: $estimatedDurationMinutes, weightModelVersion: $weightModelVersion)';
}


}

/// @nodoc
abstract mixin class _$PreoccupationCopyWith<$Res> implements $PreoccupationCopyWith<$Res> {
  factory _$PreoccupationCopyWith(_Preoccupation value, $Res Function(_Preoccupation) _then) = __$PreoccupationCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, DateTime createdAt, int? mentalWeightKg, String? category, int? effortScore, int? estimatedDurationMinutes, String? weightModelVersion
});




}
/// @nodoc
class __$PreoccupationCopyWithImpl<$Res>
    implements _$PreoccupationCopyWith<$Res> {
  __$PreoccupationCopyWithImpl(this._self, this._then);

  final _Preoccupation _self;
  final $Res Function(_Preoccupation) _then;

/// Create a copy of Preoccupation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? createdAt = null,Object? mentalWeightKg = freezed,Object? category = freezed,Object? effortScore = freezed,Object? estimatedDurationMinutes = freezed,Object? weightModelVersion = freezed,}) {
  return _then(_Preoccupation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,mentalWeightKg: freezed == mentalWeightKg ? _self.mentalWeightKg : mentalWeightKg // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,effortScore: freezed == effortScore ? _self.effortScore : effortScore // ignore: cast_nullable_to_non_nullable
as int?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,weightModelVersion: freezed == weightModelVersion ? _self.weightModelVersion : weightModelVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
