// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WifiCapabilities {

/// Joining a pinned router works at all (Android 10+, iOS).
 bool get supported;/// Nearby routers can be listed (Android only).
 bool get canScan;/// The OS only joins the requested BSSID (Android). Elsewhere the BSSID is
/// verified after the join and a mismatch is reported, not prevented.
 bool get canLockBssid;/// The app's traffic is bound to the pinned network (Android).
 bool get canBindProcess;
/// Create a copy of WifiCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiCapabilitiesCopyWith<WifiCapabilities> get copyWith => _$WifiCapabilitiesCopyWithImpl<WifiCapabilities>(this as WifiCapabilities, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiCapabilities&&(identical(other.supported, supported) || other.supported == supported)&&(identical(other.canScan, canScan) || other.canScan == canScan)&&(identical(other.canLockBssid, canLockBssid) || other.canLockBssid == canLockBssid)&&(identical(other.canBindProcess, canBindProcess) || other.canBindProcess == canBindProcess));
}


@override
int get hashCode => Object.hash(runtimeType,supported,canScan,canLockBssid,canBindProcess);

@override
String toString() {
  return 'WifiCapabilities(supported: $supported, canScan: $canScan, canLockBssid: $canLockBssid, canBindProcess: $canBindProcess)';
}


}

/// @nodoc
abstract mixin class $WifiCapabilitiesCopyWith<$Res>  {
  factory $WifiCapabilitiesCopyWith(WifiCapabilities value, $Res Function(WifiCapabilities) _then) = _$WifiCapabilitiesCopyWithImpl;
@useResult
$Res call({
 bool supported, bool canScan, bool canLockBssid, bool canBindProcess
});




}
/// @nodoc
class _$WifiCapabilitiesCopyWithImpl<$Res>
    implements $WifiCapabilitiesCopyWith<$Res> {
  _$WifiCapabilitiesCopyWithImpl(this._self, this._then);

  final WifiCapabilities _self;
  final $Res Function(WifiCapabilities) _then;

/// Create a copy of WifiCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supported = null,Object? canScan = null,Object? canLockBssid = null,Object? canBindProcess = null,}) {
  return _then(_self.copyWith(
supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,canScan: null == canScan ? _self.canScan : canScan // ignore: cast_nullable_to_non_nullable
as bool,canLockBssid: null == canLockBssid ? _self.canLockBssid : canLockBssid // ignore: cast_nullable_to_non_nullable
as bool,canBindProcess: null == canBindProcess ? _self.canBindProcess : canBindProcess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WifiCapabilities].
extension WifiCapabilitiesPatterns on WifiCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WifiCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WifiCapabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WifiCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _WifiCapabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WifiCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _WifiCapabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool supported,  bool canScan,  bool canLockBssid,  bool canBindProcess)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WifiCapabilities() when $default != null:
return $default(_that.supported,_that.canScan,_that.canLockBssid,_that.canBindProcess);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool supported,  bool canScan,  bool canLockBssid,  bool canBindProcess)  $default,) {final _that = this;
switch (_that) {
case _WifiCapabilities():
return $default(_that.supported,_that.canScan,_that.canLockBssid,_that.canBindProcess);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool supported,  bool canScan,  bool canLockBssid,  bool canBindProcess)?  $default,) {final _that = this;
switch (_that) {
case _WifiCapabilities() when $default != null:
return $default(_that.supported,_that.canScan,_that.canLockBssid,_that.canBindProcess);case _:
  return null;

}
}

}

/// @nodoc


class _WifiCapabilities implements WifiCapabilities {
  const _WifiCapabilities({required this.supported, required this.canScan, required this.canLockBssid, required this.canBindProcess});
  

/// Joining a pinned router works at all (Android 10+, iOS).
@override final  bool supported;
/// Nearby routers can be listed (Android only).
@override final  bool canScan;
/// The OS only joins the requested BSSID (Android). Elsewhere the BSSID is
/// verified after the join and a mismatch is reported, not prevented.
@override final  bool canLockBssid;
/// The app's traffic is bound to the pinned network (Android).
@override final  bool canBindProcess;

/// Create a copy of WifiCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WifiCapabilitiesCopyWith<_WifiCapabilities> get copyWith => __$WifiCapabilitiesCopyWithImpl<_WifiCapabilities>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WifiCapabilities&&(identical(other.supported, supported) || other.supported == supported)&&(identical(other.canScan, canScan) || other.canScan == canScan)&&(identical(other.canLockBssid, canLockBssid) || other.canLockBssid == canLockBssid)&&(identical(other.canBindProcess, canBindProcess) || other.canBindProcess == canBindProcess));
}


@override
int get hashCode => Object.hash(runtimeType,supported,canScan,canLockBssid,canBindProcess);

@override
String toString() {
  return 'WifiCapabilities(supported: $supported, canScan: $canScan, canLockBssid: $canLockBssid, canBindProcess: $canBindProcess)';
}


}

/// @nodoc
abstract mixin class _$WifiCapabilitiesCopyWith<$Res> implements $WifiCapabilitiesCopyWith<$Res> {
  factory _$WifiCapabilitiesCopyWith(_WifiCapabilities value, $Res Function(_WifiCapabilities) _then) = __$WifiCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 bool supported, bool canScan, bool canLockBssid, bool canBindProcess
});




}
/// @nodoc
class __$WifiCapabilitiesCopyWithImpl<$Res>
    implements _$WifiCapabilitiesCopyWith<$Res> {
  __$WifiCapabilitiesCopyWithImpl(this._self, this._then);

  final _WifiCapabilities _self;
  final $Res Function(_WifiCapabilities) _then;

/// Create a copy of WifiCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supported = null,Object? canScan = null,Object? canLockBssid = null,Object? canBindProcess = null,}) {
  return _then(_WifiCapabilities(
supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,canScan: null == canScan ? _self.canScan : canScan // ignore: cast_nullable_to_non_nullable
as bool,canLockBssid: null == canLockBssid ? _self.canLockBssid : canLockBssid // ignore: cast_nullable_to_non_nullable
as bool,canBindProcess: null == canBindProcess ? _self.canBindProcess : canBindProcess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

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

/// @nodoc
mixin _$WifiConnectResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiConnectResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WifiConnectResult()';
}


}

/// @nodoc
class $WifiConnectResultCopyWith<$Res>  {
$WifiConnectResultCopyWith(WifiConnectResult _, $Res Function(WifiConnectResult) __);
}


/// Adds pattern-matching-related methods to [WifiConnectResult].
extension WifiConnectResultPatterns on WifiConnectResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WifiConnected value)?  connected,TResult Function( WifiConnectFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WifiConnected() when connected != null:
return connected(_that);case WifiConnectFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WifiConnected value)  connected,required TResult Function( WifiConnectFailed value)  failed,}){
final _that = this;
switch (_that) {
case WifiConnected():
return connected(_that);case WifiConnectFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WifiConnected value)?  connected,TResult? Function( WifiConnectFailed value)?  failed,}){
final _that = this;
switch (_that) {
case WifiConnected() when connected != null:
return connected(_that);case WifiConnectFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String actualBssid)?  connected,TResult Function( WifiFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WifiConnected() when connected != null:
return connected(_that.actualBssid);case WifiConnectFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String actualBssid)  connected,required TResult Function( WifiFailure failure)  failed,}) {final _that = this;
switch (_that) {
case WifiConnected():
return connected(_that.actualBssid);case WifiConnectFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String actualBssid)?  connected,TResult? Function( WifiFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case WifiConnected() when connected != null:
return connected(_that.actualBssid);case WifiConnectFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class WifiConnected implements WifiConnectResult {
  const WifiConnected(this.actualBssid);
  

 final  String actualBssid;

/// Create a copy of WifiConnectResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiConnectedCopyWith<WifiConnected> get copyWith => _$WifiConnectedCopyWithImpl<WifiConnected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiConnected&&(identical(other.actualBssid, actualBssid) || other.actualBssid == actualBssid));
}


@override
int get hashCode => Object.hash(runtimeType,actualBssid);

@override
String toString() {
  return 'WifiConnectResult.connected(actualBssid: $actualBssid)';
}


}

/// @nodoc
abstract mixin class $WifiConnectedCopyWith<$Res> implements $WifiConnectResultCopyWith<$Res> {
  factory $WifiConnectedCopyWith(WifiConnected value, $Res Function(WifiConnected) _then) = _$WifiConnectedCopyWithImpl;
@useResult
$Res call({
 String actualBssid
});




}
/// @nodoc
class _$WifiConnectedCopyWithImpl<$Res>
    implements $WifiConnectedCopyWith<$Res> {
  _$WifiConnectedCopyWithImpl(this._self, this._then);

  final WifiConnected _self;
  final $Res Function(WifiConnected) _then;

/// Create a copy of WifiConnectResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? actualBssid = null,}) {
  return _then(WifiConnected(
null == actualBssid ? _self.actualBssid : actualBssid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class WifiConnectFailed implements WifiConnectResult {
  const WifiConnectFailed(this.failure);
  

 final  WifiFailure failure;

/// Create a copy of WifiConnectResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiConnectFailedCopyWith<WifiConnectFailed> get copyWith => _$WifiConnectFailedCopyWithImpl<WifiConnectFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiConnectFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'WifiConnectResult.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $WifiConnectFailedCopyWith<$Res> implements $WifiConnectResultCopyWith<$Res> {
  factory $WifiConnectFailedCopyWith(WifiConnectFailed value, $Res Function(WifiConnectFailed) _then) = _$WifiConnectFailedCopyWithImpl;
@useResult
$Res call({
 WifiFailure failure
});




}
/// @nodoc
class _$WifiConnectFailedCopyWithImpl<$Res>
    implements $WifiConnectFailedCopyWith<$Res> {
  _$WifiConnectFailedCopyWithImpl(this._self, this._then);

  final WifiConnectFailed _self;
  final $Res Function(WifiConnectFailed) _then;

/// Create a copy of WifiConnectResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(WifiConnectFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as WifiFailure,
  ));
}


}

// dart format on
