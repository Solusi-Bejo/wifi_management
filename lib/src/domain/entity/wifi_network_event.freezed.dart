// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_network_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WifiNetworkEvent {

 WifiNetworkEventType get type; String? get ssid;/// For [WifiNetworkEventType.connected], the BSSID actually joined.
 String? get bssid; WifiFailure? get failure;
/// Create a copy of WifiNetworkEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiNetworkEventCopyWith<WifiNetworkEvent> get copyWith => _$WifiNetworkEventCopyWithImpl<WifiNetworkEvent>(this as WifiNetworkEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiNetworkEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.ssid, ssid) || other.ssid == ssid)&&(identical(other.bssid, bssid) || other.bssid == bssid)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,type,ssid,bssid,failure);

@override
String toString() {
  return 'WifiNetworkEvent(type: $type, ssid: $ssid, bssid: $bssid, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $WifiNetworkEventCopyWith<$Res>  {
  factory $WifiNetworkEventCopyWith(WifiNetworkEvent value, $Res Function(WifiNetworkEvent) _then) = _$WifiNetworkEventCopyWithImpl;
@useResult
$Res call({
 WifiNetworkEventType type, String? ssid, String? bssid, WifiFailure? failure
});




}
/// @nodoc
class _$WifiNetworkEventCopyWithImpl<$Res>
    implements $WifiNetworkEventCopyWith<$Res> {
  _$WifiNetworkEventCopyWithImpl(this._self, this._then);

  final WifiNetworkEvent _self;
  final $Res Function(WifiNetworkEvent) _then;

/// Create a copy of WifiNetworkEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? ssid = freezed,Object? bssid = freezed,Object? failure = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WifiNetworkEventType,ssid: freezed == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String?,bssid: freezed == bssid ? _self.bssid : bssid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as WifiFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [WifiNetworkEvent].
extension WifiNetworkEventPatterns on WifiNetworkEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WifiNetworkEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WifiNetworkEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WifiNetworkEvent value)  $default,){
final _that = this;
switch (_that) {
case _WifiNetworkEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WifiNetworkEvent value)?  $default,){
final _that = this;
switch (_that) {
case _WifiNetworkEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WifiNetworkEventType type,  String? ssid,  String? bssid,  WifiFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WifiNetworkEvent() when $default != null:
return $default(_that.type,_that.ssid,_that.bssid,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WifiNetworkEventType type,  String? ssid,  String? bssid,  WifiFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _WifiNetworkEvent():
return $default(_that.type,_that.ssid,_that.bssid,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WifiNetworkEventType type,  String? ssid,  String? bssid,  WifiFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _WifiNetworkEvent() when $default != null:
return $default(_that.type,_that.ssid,_that.bssid,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _WifiNetworkEvent implements WifiNetworkEvent {
  const _WifiNetworkEvent({required this.type, this.ssid, this.bssid, this.failure});
  

@override final  WifiNetworkEventType type;
@override final  String? ssid;
/// For [WifiNetworkEventType.connected], the BSSID actually joined.
@override final  String? bssid;
@override final  WifiFailure? failure;

/// Create a copy of WifiNetworkEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WifiNetworkEventCopyWith<_WifiNetworkEvent> get copyWith => __$WifiNetworkEventCopyWithImpl<_WifiNetworkEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WifiNetworkEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.ssid, ssid) || other.ssid == ssid)&&(identical(other.bssid, bssid) || other.bssid == bssid)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,type,ssid,bssid,failure);

@override
String toString() {
  return 'WifiNetworkEvent(type: $type, ssid: $ssid, bssid: $bssid, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$WifiNetworkEventCopyWith<$Res> implements $WifiNetworkEventCopyWith<$Res> {
  factory _$WifiNetworkEventCopyWith(_WifiNetworkEvent value, $Res Function(_WifiNetworkEvent) _then) = __$WifiNetworkEventCopyWithImpl;
@override @useResult
$Res call({
 WifiNetworkEventType type, String? ssid, String? bssid, WifiFailure? failure
});




}
/// @nodoc
class __$WifiNetworkEventCopyWithImpl<$Res>
    implements _$WifiNetworkEventCopyWith<$Res> {
  __$WifiNetworkEventCopyWithImpl(this._self, this._then);

  final _WifiNetworkEvent _self;
  final $Res Function(_WifiNetworkEvent) _then;

/// Create a copy of WifiNetworkEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? ssid = freezed,Object? bssid = freezed,Object? failure = freezed,}) {
  return _then(_WifiNetworkEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WifiNetworkEventType,ssid: freezed == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String?,bssid: freezed == bssid ? _self.bssid : bssid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as WifiFailure?,
  ));
}


}

// dart format on
