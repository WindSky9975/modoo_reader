// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Book {

/// 0 before the row is inserted.
 int get id; String get title; String get formatId; String get filePath; int get fileSizeBytes; DateTime get addedAt; String? get author; String? get coverPath; String? get encoding; int get chapterCount; DateTime? get lastOpenedAt; DateTime? get deletedAt;
/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookCopyWith<Book> get copyWith => _$BookCopyWithImpl<Book>(this as Book, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.formatId, formatId) || other.formatId == formatId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverPath, coverPath) || other.coverPath == coverPath)&&(identical(other.encoding, encoding) || other.encoding == encoding)&&(identical(other.chapterCount, chapterCount) || other.chapterCount == chapterCount)&&(identical(other.lastOpenedAt, lastOpenedAt) || other.lastOpenedAt == lastOpenedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,formatId,filePath,fileSizeBytes,addedAt,author,coverPath,encoding,chapterCount,lastOpenedAt,deletedAt);

@override
String toString() {
  return 'Book(id: $id, title: $title, formatId: $formatId, filePath: $filePath, fileSizeBytes: $fileSizeBytes, addedAt: $addedAt, author: $author, coverPath: $coverPath, encoding: $encoding, chapterCount: $chapterCount, lastOpenedAt: $lastOpenedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $BookCopyWith<$Res>  {
  factory $BookCopyWith(Book value, $Res Function(Book) _then) = _$BookCopyWithImpl;
@useResult
$Res call({
 int id, String title, String formatId, String filePath, int fileSizeBytes, DateTime addedAt, String? author, String? coverPath, String? encoding, int chapterCount, DateTime? lastOpenedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$BookCopyWithImpl<$Res>
    implements $BookCopyWith<$Res> {
  _$BookCopyWithImpl(this._self, this._then);

  final Book _self;
  final $Res Function(Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? formatId = null,Object? filePath = null,Object? fileSizeBytes = null,Object? addedAt = null,Object? author = freezed,Object? coverPath = freezed,Object? encoding = freezed,Object? chapterCount = null,Object? lastOpenedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,formatId: null == formatId ? _self.formatId : formatId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,coverPath: freezed == coverPath ? _self.coverPath : coverPath // ignore: cast_nullable_to_non_nullable
as String?,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,chapterCount: null == chapterCount ? _self.chapterCount : chapterCount // ignore: cast_nullable_to_non_nullable
as int,lastOpenedAt: freezed == lastOpenedAt ? _self.lastOpenedAt : lastOpenedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Book].
extension BookPatterns on Book {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Book value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Book value)  $default,){
final _that = this;
switch (_that) {
case _Book():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Book value)?  $default,){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String formatId,  String filePath,  int fileSizeBytes,  DateTime addedAt,  String? author,  String? coverPath,  String? encoding,  int chapterCount,  DateTime? lastOpenedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.formatId,_that.filePath,_that.fileSizeBytes,_that.addedAt,_that.author,_that.coverPath,_that.encoding,_that.chapterCount,_that.lastOpenedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String formatId,  String filePath,  int fileSizeBytes,  DateTime addedAt,  String? author,  String? coverPath,  String? encoding,  int chapterCount,  DateTime? lastOpenedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Book():
return $default(_that.id,_that.title,_that.formatId,_that.filePath,_that.fileSizeBytes,_that.addedAt,_that.author,_that.coverPath,_that.encoding,_that.chapterCount,_that.lastOpenedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String formatId,  String filePath,  int fileSizeBytes,  DateTime addedAt,  String? author,  String? coverPath,  String? encoding,  int chapterCount,  DateTime? lastOpenedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.formatId,_that.filePath,_that.fileSizeBytes,_that.addedAt,_that.author,_that.coverPath,_that.encoding,_that.chapterCount,_that.lastOpenedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Book extends Book {
  const _Book({required this.id, required this.title, required this.formatId, required this.filePath, required this.fileSizeBytes, required this.addedAt, this.author, this.coverPath, this.encoding, this.chapterCount = 0, this.lastOpenedAt, this.deletedAt}): super._();
  

/// 0 before the row is inserted.
@override final  int id;
@override final  String title;
@override final  String formatId;
@override final  String filePath;
@override final  int fileSizeBytes;
@override final  DateTime addedAt;
@override final  String? author;
@override final  String? coverPath;
@override final  String? encoding;
@override@JsonKey() final  int chapterCount;
@override final  DateTime? lastOpenedAt;
@override final  DateTime? deletedAt;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookCopyWith<_Book> get copyWith => __$BookCopyWithImpl<_Book>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.formatId, formatId) || other.formatId == formatId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverPath, coverPath) || other.coverPath == coverPath)&&(identical(other.encoding, encoding) || other.encoding == encoding)&&(identical(other.chapterCount, chapterCount) || other.chapterCount == chapterCount)&&(identical(other.lastOpenedAt, lastOpenedAt) || other.lastOpenedAt == lastOpenedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,formatId,filePath,fileSizeBytes,addedAt,author,coverPath,encoding,chapterCount,lastOpenedAt,deletedAt);

@override
String toString() {
  return 'Book(id: $id, title: $title, formatId: $formatId, filePath: $filePath, fileSizeBytes: $fileSizeBytes, addedAt: $addedAt, author: $author, coverPath: $coverPath, encoding: $encoding, chapterCount: $chapterCount, lastOpenedAt: $lastOpenedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$BookCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$BookCopyWith(_Book value, $Res Function(_Book) _then) = __$BookCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String formatId, String filePath, int fileSizeBytes, DateTime addedAt, String? author, String? coverPath, String? encoding, int chapterCount, DateTime? lastOpenedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$BookCopyWithImpl<$Res>
    implements _$BookCopyWith<$Res> {
  __$BookCopyWithImpl(this._self, this._then);

  final _Book _self;
  final $Res Function(_Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? formatId = null,Object? filePath = null,Object? fileSizeBytes = null,Object? addedAt = null,Object? author = freezed,Object? coverPath = freezed,Object? encoding = freezed,Object? chapterCount = null,Object? lastOpenedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_Book(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,formatId: null == formatId ? _self.formatId : formatId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,coverPath: freezed == coverPath ? _self.coverPath : coverPath // ignore: cast_nullable_to_non_nullable
as String?,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,chapterCount: null == chapterCount ? _self.chapterCount : chapterCount // ignore: cast_nullable_to_non_nullable
as int,lastOpenedAt: freezed == lastOpenedAt ? _self.lastOpenedAt : lastOpenedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
