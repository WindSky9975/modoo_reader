// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReadingSession {

 int get id; int get bookId; DateTime get startedAt; DateTime get endedAt; int get characters;
/// Create a copy of ReadingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingSessionCopyWith<ReadingSession> get copyWith => _$ReadingSessionCopyWithImpl<ReadingSession>(this as ReadingSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.characters, characters) || other.characters == characters));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,startedAt,endedAt,characters);

@override
String toString() {
  return 'ReadingSession(id: $id, bookId: $bookId, startedAt: $startedAt, endedAt: $endedAt, characters: $characters)';
}


}

/// @nodoc
abstract mixin class $ReadingSessionCopyWith<$Res>  {
  factory $ReadingSessionCopyWith(ReadingSession value, $Res Function(ReadingSession) _then) = _$ReadingSessionCopyWithImpl;
@useResult
$Res call({
 int id, int bookId, DateTime startedAt, DateTime endedAt, int characters
});




}
/// @nodoc
class _$ReadingSessionCopyWithImpl<$Res>
    implements $ReadingSessionCopyWith<$Res> {
  _$ReadingSessionCopyWithImpl(this._self, this._then);

  final ReadingSession _self;
  final $Res Function(ReadingSession) _then;

/// Create a copy of ReadingSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? startedAt = null,Object? endedAt = null,Object? characters = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingSession].
extension ReadingSessionPatterns on ReadingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingSession value)  $default,){
final _that = this;
switch (_that) {
case _ReadingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingSession value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookId,  DateTime startedAt,  DateTime endedAt,  int characters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingSession() when $default != null:
return $default(_that.id,_that.bookId,_that.startedAt,_that.endedAt,_that.characters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookId,  DateTime startedAt,  DateTime endedAt,  int characters)  $default,) {final _that = this;
switch (_that) {
case _ReadingSession():
return $default(_that.id,_that.bookId,_that.startedAt,_that.endedAt,_that.characters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookId,  DateTime startedAt,  DateTime endedAt,  int characters)?  $default,) {final _that = this;
switch (_that) {
case _ReadingSession() when $default != null:
return $default(_that.id,_that.bookId,_that.startedAt,_that.endedAt,_that.characters);case _:
  return null;

}
}

}

/// @nodoc


class _ReadingSession extends ReadingSession {
  const _ReadingSession({required this.id, required this.bookId, required this.startedAt, required this.endedAt, this.characters = 0}): super._();
  

@override final  int id;
@override final  int bookId;
@override final  DateTime startedAt;
@override final  DateTime endedAt;
@override@JsonKey() final  int characters;

/// Create a copy of ReadingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingSessionCopyWith<_ReadingSession> get copyWith => __$ReadingSessionCopyWithImpl<_ReadingSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.characters, characters) || other.characters == characters));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,startedAt,endedAt,characters);

@override
String toString() {
  return 'ReadingSession(id: $id, bookId: $bookId, startedAt: $startedAt, endedAt: $endedAt, characters: $characters)';
}


}

/// @nodoc
abstract mixin class _$ReadingSessionCopyWith<$Res> implements $ReadingSessionCopyWith<$Res> {
  factory _$ReadingSessionCopyWith(_ReadingSession value, $Res Function(_ReadingSession) _then) = __$ReadingSessionCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookId, DateTime startedAt, DateTime endedAt, int characters
});




}
/// @nodoc
class __$ReadingSessionCopyWithImpl<$Res>
    implements _$ReadingSessionCopyWith<$Res> {
  __$ReadingSessionCopyWithImpl(this._self, this._then);

  final _ReadingSession _self;
  final $Res Function(_ReadingSession) _then;

/// Create a copy of ReadingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? startedAt = null,Object? endedAt = null,Object? characters = null,}) {
  return _then(_ReadingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ReadingDay {

 DateTime get day; Duration get duration; int get characters;
/// Create a copy of ReadingDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingDayCopyWith<ReadingDay> get copyWith => _$ReadingDayCopyWithImpl<ReadingDay>(this as ReadingDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingDay&&(identical(other.day, day) || other.day == day)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.characters, characters) || other.characters == characters));
}


@override
int get hashCode => Object.hash(runtimeType,day,duration,characters);

@override
String toString() {
  return 'ReadingDay(day: $day, duration: $duration, characters: $characters)';
}


}

/// @nodoc
abstract mixin class $ReadingDayCopyWith<$Res>  {
  factory $ReadingDayCopyWith(ReadingDay value, $Res Function(ReadingDay) _then) = _$ReadingDayCopyWithImpl;
@useResult
$Res call({
 DateTime day, Duration duration, int characters
});




}
/// @nodoc
class _$ReadingDayCopyWithImpl<$Res>
    implements $ReadingDayCopyWith<$Res> {
  _$ReadingDayCopyWithImpl(this._self, this._then);

  final ReadingDay _self;
  final $Res Function(ReadingDay) _then;

/// Create a copy of ReadingDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? duration = null,Object? characters = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingDay].
extension ReadingDayPatterns on ReadingDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingDay value)  $default,){
final _that = this;
switch (_that) {
case _ReadingDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingDay value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime day,  Duration duration,  int characters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingDay() when $default != null:
return $default(_that.day,_that.duration,_that.characters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime day,  Duration duration,  int characters)  $default,) {final _that = this;
switch (_that) {
case _ReadingDay():
return $default(_that.day,_that.duration,_that.characters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime day,  Duration duration,  int characters)?  $default,) {final _that = this;
switch (_that) {
case _ReadingDay() when $default != null:
return $default(_that.day,_that.duration,_that.characters);case _:
  return null;

}
}

}

/// @nodoc


class _ReadingDay extends ReadingDay {
  const _ReadingDay({required this.day, this.duration = Duration.zero, this.characters = 0}): super._();
  

@override final  DateTime day;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  int characters;

/// Create a copy of ReadingDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingDayCopyWith<_ReadingDay> get copyWith => __$ReadingDayCopyWithImpl<_ReadingDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingDay&&(identical(other.day, day) || other.day == day)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.characters, characters) || other.characters == characters));
}


@override
int get hashCode => Object.hash(runtimeType,day,duration,characters);

@override
String toString() {
  return 'ReadingDay(day: $day, duration: $duration, characters: $characters)';
}


}

/// @nodoc
abstract mixin class _$ReadingDayCopyWith<$Res> implements $ReadingDayCopyWith<$Res> {
  factory _$ReadingDayCopyWith(_ReadingDay value, $Res Function(_ReadingDay) _then) = __$ReadingDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime day, Duration duration, int characters
});




}
/// @nodoc
class __$ReadingDayCopyWithImpl<$Res>
    implements _$ReadingDayCopyWith<$Res> {
  __$ReadingDayCopyWithImpl(this._self, this._then);

  final _ReadingDay _self;
  final $Res Function(_ReadingDay) _then;

/// Create a copy of ReadingDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? duration = null,Object? characters = null,}) {
  return _then(_ReadingDay(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ReadingStats {

 Duration get total; int get characters; int get sessionCount; int get streakDays; List<ReadingDay> get days;
/// Create a copy of ReadingStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingStatsCopyWith<ReadingStats> get copyWith => _$ReadingStatsCopyWithImpl<ReadingStats>(this as ReadingStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingStats&&(identical(other.total, total) || other.total == total)&&(identical(other.characters, characters) || other.characters == characters)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&const DeepCollectionEquality().equals(other.days, days));
}


@override
int get hashCode => Object.hash(runtimeType,total,characters,sessionCount,streakDays,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'ReadingStats(total: $total, characters: $characters, sessionCount: $sessionCount, streakDays: $streakDays, days: $days)';
}


}

/// @nodoc
abstract mixin class $ReadingStatsCopyWith<$Res>  {
  factory $ReadingStatsCopyWith(ReadingStats value, $Res Function(ReadingStats) _then) = _$ReadingStatsCopyWithImpl;
@useResult
$Res call({
 Duration total, int characters, int sessionCount, int streakDays, List<ReadingDay> days
});




}
/// @nodoc
class _$ReadingStatsCopyWithImpl<$Res>
    implements $ReadingStatsCopyWith<$Res> {
  _$ReadingStatsCopyWithImpl(this._self, this._then);

  final ReadingStats _self;
  final $Res Function(ReadingStats) _then;

/// Create a copy of ReadingStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? characters = null,Object? sessionCount = null,Object? streakDays = null,Object? days = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Duration,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<ReadingDay>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingStats].
extension ReadingStatsPatterns on ReadingStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingStats value)  $default,){
final _that = this;
switch (_that) {
case _ReadingStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingStats value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration total,  int characters,  int sessionCount,  int streakDays,  List<ReadingDay> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingStats() when $default != null:
return $default(_that.total,_that.characters,_that.sessionCount,_that.streakDays,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration total,  int characters,  int sessionCount,  int streakDays,  List<ReadingDay> days)  $default,) {final _that = this;
switch (_that) {
case _ReadingStats():
return $default(_that.total,_that.characters,_that.sessionCount,_that.streakDays,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration total,  int characters,  int sessionCount,  int streakDays,  List<ReadingDay> days)?  $default,) {final _that = this;
switch (_that) {
case _ReadingStats() when $default != null:
return $default(_that.total,_that.characters,_that.sessionCount,_that.streakDays,_that.days);case _:
  return null;

}
}

}

/// @nodoc


class _ReadingStats extends ReadingStats {
  const _ReadingStats({this.total = Duration.zero, this.characters = 0, this.sessionCount = 0, this.streakDays = 0, final  List<ReadingDay> days = const <ReadingDay>[]}): _days = days,super._();
  

@override@JsonKey() final  Duration total;
@override@JsonKey() final  int characters;
@override@JsonKey() final  int sessionCount;
@override@JsonKey() final  int streakDays;
 final  List<ReadingDay> _days;
@override@JsonKey() List<ReadingDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of ReadingStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingStatsCopyWith<_ReadingStats> get copyWith => __$ReadingStatsCopyWithImpl<_ReadingStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingStats&&(identical(other.total, total) || other.total == total)&&(identical(other.characters, characters) || other.characters == characters)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&const DeepCollectionEquality().equals(other._days, _days));
}


@override
int get hashCode => Object.hash(runtimeType,total,characters,sessionCount,streakDays,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'ReadingStats(total: $total, characters: $characters, sessionCount: $sessionCount, streakDays: $streakDays, days: $days)';
}


}

/// @nodoc
abstract mixin class _$ReadingStatsCopyWith<$Res> implements $ReadingStatsCopyWith<$Res> {
  factory _$ReadingStatsCopyWith(_ReadingStats value, $Res Function(_ReadingStats) _then) = __$ReadingStatsCopyWithImpl;
@override @useResult
$Res call({
 Duration total, int characters, int sessionCount, int streakDays, List<ReadingDay> days
});




}
/// @nodoc
class __$ReadingStatsCopyWithImpl<$Res>
    implements _$ReadingStatsCopyWith<$Res> {
  __$ReadingStatsCopyWithImpl(this._self, this._then);

  final _ReadingStats _self;
  final $Res Function(_ReadingStats) _then;

/// Create a copy of ReadingStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? characters = null,Object? sessionCount = null,Object? streakDays = null,Object? days = null,}) {
  return _then(_ReadingStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Duration,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<ReadingDay>,
  ));
}


}

// dart format on
