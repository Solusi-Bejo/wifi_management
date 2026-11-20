// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_capabilities.dart';

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

// dart format on
