// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grade_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GradeModel {

 int? get id;@JsonKey(name: 'student_id') int get studentId;@JsonKey(name: 'task_id') int get taskId; double get score;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of GradeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GradeModelCopyWith<GradeModel> get copyWith => _$GradeModelCopyWithImpl<GradeModel>(this as GradeModel, _$identity);

  /// Serializes this GradeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GradeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.score, score) || other.score == score)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,taskId,score,createdAt);

@override
String toString() {
  return 'GradeModel(id: $id, studentId: $studentId, taskId: $taskId, score: $score, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GradeModelCopyWith<$Res>  {
  factory $GradeModelCopyWith(GradeModel value, $Res Function(GradeModel) _then) = _$GradeModelCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'student_id') int studentId,@JsonKey(name: 'task_id') int taskId, double score,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$GradeModelCopyWithImpl<$Res>
    implements $GradeModelCopyWith<$Res> {
  _$GradeModelCopyWithImpl(this._self, this._then);

  final GradeModel _self;
  final $Res Function(GradeModel) _then;

/// Create a copy of GradeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? studentId = null,Object? taskId = null,Object? score = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GradeModel].
extension GradeModelPatterns on GradeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GradeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GradeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GradeModel value)  $default,){
final _that = this;
switch (_that) {
case _GradeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GradeModel value)?  $default,){
final _that = this;
switch (_that) {
case _GradeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'student_id')  int studentId, @JsonKey(name: 'task_id')  int taskId,  double score, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GradeModel() when $default != null:
return $default(_that.id,_that.studentId,_that.taskId,_that.score,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'student_id')  int studentId, @JsonKey(name: 'task_id')  int taskId,  double score, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _GradeModel():
return $default(_that.id,_that.studentId,_that.taskId,_that.score,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'student_id')  int studentId, @JsonKey(name: 'task_id')  int taskId,  double score, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GradeModel() when $default != null:
return $default(_that.id,_that.studentId,_that.taskId,_that.score,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GradeModel implements GradeModel {
  const _GradeModel({this.id, @JsonKey(name: 'student_id') required this.studentId, @JsonKey(name: 'task_id') required this.taskId, required this.score, @JsonKey(name: 'created_at') required this.createdAt});
  factory _GradeModel.fromJson(Map<String, dynamic> json) => _$GradeModelFromJson(json);

@override final  int? id;
@override@JsonKey(name: 'student_id') final  int studentId;
@override@JsonKey(name: 'task_id') final  int taskId;
@override final  double score;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of GradeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GradeModelCopyWith<_GradeModel> get copyWith => __$GradeModelCopyWithImpl<_GradeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GradeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GradeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.score, score) || other.score == score)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,taskId,score,createdAt);

@override
String toString() {
  return 'GradeModel(id: $id, studentId: $studentId, taskId: $taskId, score: $score, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GradeModelCopyWith<$Res> implements $GradeModelCopyWith<$Res> {
  factory _$GradeModelCopyWith(_GradeModel value, $Res Function(_GradeModel) _then) = __$GradeModelCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'student_id') int studentId,@JsonKey(name: 'task_id') int taskId, double score,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$GradeModelCopyWithImpl<$Res>
    implements _$GradeModelCopyWith<$Res> {
  __$GradeModelCopyWithImpl(this._self, this._then);

  final _GradeModel _self;
  final $Res Function(_GradeModel) _then;

/// Create a copy of GradeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? studentId = null,Object? taskId = null,Object? score = null,Object? createdAt = null,}) {
  return _then(_GradeModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
