// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annotation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Annotation {

/// 0 before the row is inserted.
 int get id; int get bookId; int get chapterIndex;/// Character offset of the paragraph start, relative to the chapter body.
 int get startOffset;/// Character offset one past the paragraph's last character.
 int get endOffset; String get excerpt; String get body; DateTime get createdAt;
/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnotationCopyWith<Annotation> get copyWith => _$AnnotationCopyWithImpl<Annotation>(this as Annotation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Annotation&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapterIndex,startOffset,endOffset,excerpt,body,createdAt);

@override
String toString() {
  return 'Annotation(id: $id, bookId: $bookId, chapterIndex: $chapterIndex, startOffset: $startOffset, endOffset: $endOffset, excerpt: $excerpt, body: $body, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AnnotationCopyWith<$Res>  {
  factory $AnnotationCopyWith(Annotation value, $Res Function(Annotation) _then) = _$AnnotationCopyWithImpl;
@useResult
$Res call({
 int id, int bookId, int chapterIndex, int startOffset, int endOffset, String excerpt, String body, DateTime createdAt
});




}
/// @nodoc
class _$AnnotationCopyWithImpl<$Res>
    implements $AnnotationCopyWith<$Res> {
  _$AnnotationCopyWithImpl(this._self, this._then);

  final Annotation _self;
  final $Res Function(Annotation) _then;

/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? chapterIndex = null,Object? startOffset = null,Object? endOffset = null,Object? excerpt = null,Object? body = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,startOffset: null == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as int,endOffset: null == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Annotation].
extension AnnotationPatterns on Annotation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Annotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Annotation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Annotation value)  $default,){
final _that = this;
switch (_that) {
case _Annotation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Annotation value)?  $default,){
final _that = this;
switch (_that) {
case _Annotation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapterIndex,  int startOffset,  int endOffset,  String excerpt,  String body,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Annotation() when $default != null:
return $default(_that.id,_that.bookId,_that.chapterIndex,_that.startOffset,_that.endOffset,_that.excerpt,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapterIndex,  int startOffset,  int endOffset,  String excerpt,  String body,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Annotation():
return $default(_that.id,_that.bookId,_that.chapterIndex,_that.startOffset,_that.endOffset,_that.excerpt,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookId,  int chapterIndex,  int startOffset,  int endOffset,  String excerpt,  String body,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Annotation() when $default != null:
return $default(_that.id,_that.bookId,_that.chapterIndex,_that.startOffset,_that.endOffset,_that.excerpt,_that.body,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Annotation extends Annotation {
  const _Annotation({required this.id, required this.bookId, required this.chapterIndex, required this.startOffset, required this.endOffset, required this.excerpt, required this.body, required this.createdAt}): super._();
  

/// 0 before the row is inserted.
@override final  int id;
@override final  int bookId;
@override final  int chapterIndex;
/// Character offset of the paragraph start, relative to the chapter body.
@override final  int startOffset;
/// Character offset one past the paragraph's last character.
@override final  int endOffset;
@override final  String excerpt;
@override final  String body;
@override final  DateTime createdAt;

/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnotationCopyWith<_Annotation> get copyWith => __$AnnotationCopyWithImpl<_Annotation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Annotation&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapterIndex,startOffset,endOffset,excerpt,body,createdAt);

@override
String toString() {
  return 'Annotation(id: $id, bookId: $bookId, chapterIndex: $chapterIndex, startOffset: $startOffset, endOffset: $endOffset, excerpt: $excerpt, body: $body, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AnnotationCopyWith<$Res> implements $AnnotationCopyWith<$Res> {
  factory _$AnnotationCopyWith(_Annotation value, $Res Function(_Annotation) _then) = __$AnnotationCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookId, int chapterIndex, int startOffset, int endOffset, String excerpt, String body, DateTime createdAt
});




}
/// @nodoc
class __$AnnotationCopyWithImpl<$Res>
    implements _$AnnotationCopyWith<$Res> {
  __$AnnotationCopyWithImpl(this._self, this._then);

  final _Annotation _self;
  final $Res Function(_Annotation) _then;

/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? chapterIndex = null,Object? startOffset = null,Object? endOffset = null,Object? excerpt = null,Object? body = null,Object? createdAt = null,}) {
  return _then(_Annotation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,startOffset: null == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as int,endOffset: null == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
