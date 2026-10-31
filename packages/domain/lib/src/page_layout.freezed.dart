// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_layout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PageExtent {

 int get startOffset; int get endOffset;
/// Create a copy of PageExtent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageExtentCopyWith<PageExtent> get copyWith => _$PageExtentCopyWithImpl<PageExtent>(this as PageExtent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageExtent&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset));
}


@override
int get hashCode => Object.hash(runtimeType,startOffset,endOffset);

@override
String toString() {
  return 'PageExtent(startOffset: $startOffset, endOffset: $endOffset)';
}


}

/// @nodoc
abstract mixin class $PageExtentCopyWith<$Res>  {
  factory $PageExtentCopyWith(PageExtent value, $Res Function(PageExtent) _then) = _$PageExtentCopyWithImpl;
@useResult
$Res call({
 int startOffset, int endOffset
});




}
/// @nodoc
class _$PageExtentCopyWithImpl<$Res>
    implements $PageExtentCopyWith<$Res> {
  _$PageExtentCopyWithImpl(this._self, this._then);

  final PageExtent _self;
  final $Res Function(PageExtent) _then;

/// Create a copy of PageExtent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startOffset = null,Object? endOffset = null,}) {
  return _then(_self.copyWith(
startOffset: null == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as int,endOffset: null == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PageExtent].
extension PageExtentPatterns on PageExtent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageExtent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageExtent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageExtent value)  $default,){
final _that = this;
switch (_that) {
case _PageExtent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageExtent value)?  $default,){
final _that = this;
switch (_that) {
case _PageExtent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int startOffset,  int endOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageExtent() when $default != null:
return $default(_that.startOffset,_that.endOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int startOffset,  int endOffset)  $default,) {final _that = this;
switch (_that) {
case _PageExtent():
return $default(_that.startOffset,_that.endOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int startOffset,  int endOffset)?  $default,) {final _that = this;
switch (_that) {
case _PageExtent() when $default != null:
return $default(_that.startOffset,_that.endOffset);case _:
  return null;

}
}

}

/// @nodoc


class _PageExtent extends PageExtent {
  const _PageExtent({required this.startOffset, required this.endOffset}): super._();
  

@override final  int startOffset;
@override final  int endOffset;

/// Create a copy of PageExtent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageExtentCopyWith<_PageExtent> get copyWith => __$PageExtentCopyWithImpl<_PageExtent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageExtent&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset));
}


@override
int get hashCode => Object.hash(runtimeType,startOffset,endOffset);

@override
String toString() {
  return 'PageExtent(startOffset: $startOffset, endOffset: $endOffset)';
}


}

/// @nodoc
abstract mixin class _$PageExtentCopyWith<$Res> implements $PageExtentCopyWith<$Res> {
  factory _$PageExtentCopyWith(_PageExtent value, $Res Function(_PageExtent) _then) = __$PageExtentCopyWithImpl;
@override @useResult
$Res call({
 int startOffset, int endOffset
});




}
/// @nodoc
class __$PageExtentCopyWithImpl<$Res>
    implements _$PageExtentCopyWith<$Res> {
  __$PageExtentCopyWithImpl(this._self, this._then);

  final _PageExtent _self;
  final $Res Function(_PageExtent) _then;

/// Create a copy of PageExtent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startOffset = null,Object? endOffset = null,}) {
  return _then(_PageExtent(
startOffset: null == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as int,endOffset: null == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CachedPageLayout {

 int get bookId; int get chapterIndex; int get layoutHash; List<PageExtent> get pages; DateTime get computedAt;
/// Create a copy of CachedPageLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CachedPageLayoutCopyWith<CachedPageLayout> get copyWith => _$CachedPageLayoutCopyWithImpl<CachedPageLayout>(this as CachedPageLayout, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CachedPageLayout&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.layoutHash, layoutHash) || other.layoutHash == layoutHash)&&const DeepCollectionEquality().equals(other.pages, pages)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapterIndex,layoutHash,const DeepCollectionEquality().hash(pages),computedAt);

@override
String toString() {
  return 'CachedPageLayout(bookId: $bookId, chapterIndex: $chapterIndex, layoutHash: $layoutHash, pages: $pages, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class $CachedPageLayoutCopyWith<$Res>  {
  factory $CachedPageLayoutCopyWith(CachedPageLayout value, $Res Function(CachedPageLayout) _then) = _$CachedPageLayoutCopyWithImpl;
@useResult
$Res call({
 int bookId, int chapterIndex, int layoutHash, List<PageExtent> pages, DateTime computedAt
});




}
/// @nodoc
class _$CachedPageLayoutCopyWithImpl<$Res>
    implements $CachedPageLayoutCopyWith<$Res> {
  _$CachedPageLayoutCopyWithImpl(this._self, this._then);

  final CachedPageLayout _self;
  final $Res Function(CachedPageLayout) _then;

/// Create a copy of CachedPageLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? chapterIndex = null,Object? layoutHash = null,Object? pages = null,Object? computedAt = null,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,layoutHash: null == layoutHash ? _self.layoutHash : layoutHash // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<PageExtent>,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CachedPageLayout].
extension CachedPageLayoutPatterns on CachedPageLayout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CachedPageLayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CachedPageLayout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CachedPageLayout value)  $default,){
final _that = this;
switch (_that) {
case _CachedPageLayout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CachedPageLayout value)?  $default,){
final _that = this;
switch (_that) {
case _CachedPageLayout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  int chapterIndex,  int layoutHash,  List<PageExtent> pages,  DateTime computedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CachedPageLayout() when $default != null:
return $default(_that.bookId,_that.chapterIndex,_that.layoutHash,_that.pages,_that.computedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  int chapterIndex,  int layoutHash,  List<PageExtent> pages,  DateTime computedAt)  $default,) {final _that = this;
switch (_that) {
case _CachedPageLayout():
return $default(_that.bookId,_that.chapterIndex,_that.layoutHash,_that.pages,_that.computedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  int chapterIndex,  int layoutHash,  List<PageExtent> pages,  DateTime computedAt)?  $default,) {final _that = this;
switch (_that) {
case _CachedPageLayout() when $default != null:
return $default(_that.bookId,_that.chapterIndex,_that.layoutHash,_that.pages,_that.computedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CachedPageLayout extends CachedPageLayout {
  const _CachedPageLayout({required this.bookId, required this.chapterIndex, required this.layoutHash, required final  List<PageExtent> pages, required this.computedAt}): _pages = pages,super._();
  

@override final  int bookId;
@override final  int chapterIndex;
@override final  int layoutHash;
 final  List<PageExtent> _pages;
@override List<PageExtent> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}

@override final  DateTime computedAt;

/// Create a copy of CachedPageLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CachedPageLayoutCopyWith<_CachedPageLayout> get copyWith => __$CachedPageLayoutCopyWithImpl<_CachedPageLayout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CachedPageLayout&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.layoutHash, layoutHash) || other.layoutHash == layoutHash)&&const DeepCollectionEquality().equals(other._pages, _pages)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapterIndex,layoutHash,const DeepCollectionEquality().hash(_pages),computedAt);

@override
String toString() {
  return 'CachedPageLayout(bookId: $bookId, chapterIndex: $chapterIndex, layoutHash: $layoutHash, pages: $pages, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class _$CachedPageLayoutCopyWith<$Res> implements $CachedPageLayoutCopyWith<$Res> {
  factory _$CachedPageLayoutCopyWith(_CachedPageLayout value, $Res Function(_CachedPageLayout) _then) = __$CachedPageLayoutCopyWithImpl;
@override @useResult
$Res call({
 int bookId, int chapterIndex, int layoutHash, List<PageExtent> pages, DateTime computedAt
});




}
/// @nodoc
class __$CachedPageLayoutCopyWithImpl<$Res>
    implements _$CachedPageLayoutCopyWith<$Res> {
  __$CachedPageLayoutCopyWithImpl(this._self, this._then);

  final _CachedPageLayout _self;
  final $Res Function(_CachedPageLayout) _then;

/// Create a copy of CachedPageLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? chapterIndex = null,Object? layoutHash = null,Object? pages = null,Object? computedAt = null,}) {
  return _then(_CachedPageLayout(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,layoutHash: null == layoutHash ? _self.layoutHash : layoutHash // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<PageExtent>,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
