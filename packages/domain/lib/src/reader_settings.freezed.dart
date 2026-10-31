// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReaderSettings {

 double get fontSize; double get lineHeight; String get themeId; String get pageTurnId; String get fontFamilyId; double get paragraphSpacing; double get firstLineIndent; double get horizontalPadding; String get textAlignId;
/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReaderSettingsCopyWith<ReaderSettings> get copyWith => _$ReaderSettingsCopyWithImpl<ReaderSettings>(this as ReaderSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderSettings&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.pageTurnId, pageTurnId) || other.pageTurnId == pageTurnId)&&(identical(other.fontFamilyId, fontFamilyId) || other.fontFamilyId == fontFamilyId)&&(identical(other.paragraphSpacing, paragraphSpacing) || other.paragraphSpacing == paragraphSpacing)&&(identical(other.firstLineIndent, firstLineIndent) || other.firstLineIndent == firstLineIndent)&&(identical(other.horizontalPadding, horizontalPadding) || other.horizontalPadding == horizontalPadding)&&(identical(other.textAlignId, textAlignId) || other.textAlignId == textAlignId));
}


@override
int get hashCode => Object.hash(runtimeType,fontSize,lineHeight,themeId,pageTurnId,fontFamilyId,paragraphSpacing,firstLineIndent,horizontalPadding,textAlignId);

@override
String toString() {
  return 'ReaderSettings(fontSize: $fontSize, lineHeight: $lineHeight, themeId: $themeId, pageTurnId: $pageTurnId, fontFamilyId: $fontFamilyId, paragraphSpacing: $paragraphSpacing, firstLineIndent: $firstLineIndent, horizontalPadding: $horizontalPadding, textAlignId: $textAlignId)';
}


}

/// @nodoc
abstract mixin class $ReaderSettingsCopyWith<$Res>  {
  factory $ReaderSettingsCopyWith(ReaderSettings value, $Res Function(ReaderSettings) _then) = _$ReaderSettingsCopyWithImpl;
@useResult
$Res call({
 double fontSize, double lineHeight, String themeId, String pageTurnId, String fontFamilyId, double paragraphSpacing, double firstLineIndent, double horizontalPadding, String textAlignId
});




}
/// @nodoc
class _$ReaderSettingsCopyWithImpl<$Res>
    implements $ReaderSettingsCopyWith<$Res> {
  _$ReaderSettingsCopyWithImpl(this._self, this._then);

  final ReaderSettings _self;
  final $Res Function(ReaderSettings) _then;

/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontSize = null,Object? lineHeight = null,Object? themeId = null,Object? pageTurnId = null,Object? fontFamilyId = null,Object? paragraphSpacing = null,Object? firstLineIndent = null,Object? horizontalPadding = null,Object? textAlignId = null,}) {
  return _then(_self.copyWith(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,pageTurnId: null == pageTurnId ? _self.pageTurnId : pageTurnId // ignore: cast_nullable_to_non_nullable
as String,fontFamilyId: null == fontFamilyId ? _self.fontFamilyId : fontFamilyId // ignore: cast_nullable_to_non_nullable
as String,paragraphSpacing: null == paragraphSpacing ? _self.paragraphSpacing : paragraphSpacing // ignore: cast_nullable_to_non_nullable
as double,firstLineIndent: null == firstLineIndent ? _self.firstLineIndent : firstLineIndent // ignore: cast_nullable_to_non_nullable
as double,horizontalPadding: null == horizontalPadding ? _self.horizontalPadding : horizontalPadding // ignore: cast_nullable_to_non_nullable
as double,textAlignId: null == textAlignId ? _self.textAlignId : textAlignId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReaderSettings].
extension ReaderSettingsPatterns on ReaderSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReaderSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReaderSettings value)  $default,){
final _that = this;
switch (_that) {
case _ReaderSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReaderSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double fontSize,  double lineHeight,  String themeId,  String pageTurnId,  String fontFamilyId,  double paragraphSpacing,  double firstLineIndent,  double horizontalPadding,  String textAlignId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
return $default(_that.fontSize,_that.lineHeight,_that.themeId,_that.pageTurnId,_that.fontFamilyId,_that.paragraphSpacing,_that.firstLineIndent,_that.horizontalPadding,_that.textAlignId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double fontSize,  double lineHeight,  String themeId,  String pageTurnId,  String fontFamilyId,  double paragraphSpacing,  double firstLineIndent,  double horizontalPadding,  String textAlignId)  $default,) {final _that = this;
switch (_that) {
case _ReaderSettings():
return $default(_that.fontSize,_that.lineHeight,_that.themeId,_that.pageTurnId,_that.fontFamilyId,_that.paragraphSpacing,_that.firstLineIndent,_that.horizontalPadding,_that.textAlignId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double fontSize,  double lineHeight,  String themeId,  String pageTurnId,  String fontFamilyId,  double paragraphSpacing,  double firstLineIndent,  double horizontalPadding,  String textAlignId)?  $default,) {final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
return $default(_that.fontSize,_that.lineHeight,_that.themeId,_that.pageTurnId,_that.fontFamilyId,_that.paragraphSpacing,_that.firstLineIndent,_that.horizontalPadding,_that.textAlignId);case _:
  return null;

}
}

}

/// @nodoc


class _ReaderSettings extends ReaderSettings {
  const _ReaderSettings({this.fontSize = 18, this.lineHeight = 1.6, this.themeId = 'paper', this.pageTurnId = 'slide', this.fontFamilyId = 'system', this.paragraphSpacing = 0.6, this.firstLineIndent = 2, this.horizontalPadding = 20, this.textAlignId = 'start'}): super._();
  

@override@JsonKey() final  double fontSize;
@override@JsonKey() final  double lineHeight;
@override@JsonKey() final  String themeId;
@override@JsonKey() final  String pageTurnId;
@override@JsonKey() final  String fontFamilyId;
@override@JsonKey() final  double paragraphSpacing;
@override@JsonKey() final  double firstLineIndent;
@override@JsonKey() final  double horizontalPadding;
@override@JsonKey() final  String textAlignId;

/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReaderSettingsCopyWith<_ReaderSettings> get copyWith => __$ReaderSettingsCopyWithImpl<_ReaderSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReaderSettings&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.themeId, themeId) || other.themeId == themeId)&&(identical(other.pageTurnId, pageTurnId) || other.pageTurnId == pageTurnId)&&(identical(other.fontFamilyId, fontFamilyId) || other.fontFamilyId == fontFamilyId)&&(identical(other.paragraphSpacing, paragraphSpacing) || other.paragraphSpacing == paragraphSpacing)&&(identical(other.firstLineIndent, firstLineIndent) || other.firstLineIndent == firstLineIndent)&&(identical(other.horizontalPadding, horizontalPadding) || other.horizontalPadding == horizontalPadding)&&(identical(other.textAlignId, textAlignId) || other.textAlignId == textAlignId));
}


@override
int get hashCode => Object.hash(runtimeType,fontSize,lineHeight,themeId,pageTurnId,fontFamilyId,paragraphSpacing,firstLineIndent,horizontalPadding,textAlignId);

@override
String toString() {
  return 'ReaderSettings(fontSize: $fontSize, lineHeight: $lineHeight, themeId: $themeId, pageTurnId: $pageTurnId, fontFamilyId: $fontFamilyId, paragraphSpacing: $paragraphSpacing, firstLineIndent: $firstLineIndent, horizontalPadding: $horizontalPadding, textAlignId: $textAlignId)';
}


}

/// @nodoc
abstract mixin class _$ReaderSettingsCopyWith<$Res> implements $ReaderSettingsCopyWith<$Res> {
  factory _$ReaderSettingsCopyWith(_ReaderSettings value, $Res Function(_ReaderSettings) _then) = __$ReaderSettingsCopyWithImpl;
@override @useResult
$Res call({
 double fontSize, double lineHeight, String themeId, String pageTurnId, String fontFamilyId, double paragraphSpacing, double firstLineIndent, double horizontalPadding, String textAlignId
});




}
/// @nodoc
class __$ReaderSettingsCopyWithImpl<$Res>
    implements _$ReaderSettingsCopyWith<$Res> {
  __$ReaderSettingsCopyWithImpl(this._self, this._then);

  final _ReaderSettings _self;
  final $Res Function(_ReaderSettings) _then;

/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontSize = null,Object? lineHeight = null,Object? themeId = null,Object? pageTurnId = null,Object? fontFamilyId = null,Object? paragraphSpacing = null,Object? firstLineIndent = null,Object? horizontalPadding = null,Object? textAlignId = null,}) {
  return _then(_ReaderSettings(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,themeId: null == themeId ? _self.themeId : themeId // ignore: cast_nullable_to_non_nullable
as String,pageTurnId: null == pageTurnId ? _self.pageTurnId : pageTurnId // ignore: cast_nullable_to_non_nullable
as String,fontFamilyId: null == fontFamilyId ? _self.fontFamilyId : fontFamilyId // ignore: cast_nullable_to_non_nullable
as String,paragraphSpacing: null == paragraphSpacing ? _self.paragraphSpacing : paragraphSpacing // ignore: cast_nullable_to_non_nullable
as double,firstLineIndent: null == firstLineIndent ? _self.firstLineIndent : firstLineIndent // ignore: cast_nullable_to_non_nullable
as double,horizontalPadding: null == horizontalPadding ? _self.horizontalPadding : horizontalPadding // ignore: cast_nullable_to_non_nullable
as double,textAlignId: null == textAlignId ? _self.textAlignId : textAlignId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
