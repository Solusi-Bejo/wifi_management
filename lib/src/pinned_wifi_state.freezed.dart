// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pinned_wifi_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PinnedWifiState {

 PinnedWifiPhase get phase;/// Stored (verified) router, if any.
 WifiConfig? get config;/// Router of the attempt in flight; differs from [config] during setup.
 WifiConfig? get target;/// BSSID the platform reports for the live connection.
 String? get actualBssid;/// Last failure; kept while retrying so the user sees why.
 WifiFailure? get failure;/// Consecutive failed attempts since the last verified connection.
 int get retryAttempt; Duration? get retryDelay;
/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PinnedWifiStateCopyWith<PinnedWifiState> get copyWith => _$PinnedWifiStateCopyWithImpl<PinnedWifiState>(this as PinnedWifiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PinnedWifiState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.config, config) || other.config == config)&&(identical(other.target, target) || other.target == target)&&(identical(other.actualBssid, actualBssid) || other.actualBssid == actualBssid)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAttempt, retryAttempt) || other.retryAttempt == retryAttempt)&&(identical(other.retryDelay, retryDelay) || other.retryDelay == retryDelay));
}


@override
int get hashCode => Object.hash(runtimeType,phase,config,target,actualBssid,failure,retryAttempt,retryDelay);

@override
String toString() {
  return 'PinnedWifiState(phase: $phase, config: $config, target: $target, actualBssid: $actualBssid, failure: $failure, retryAttempt: $retryAttempt, retryDelay: $retryDelay)';
}


}

/// @nodoc
abstract mixin class $PinnedWifiStateCopyWith<$Res>  {
  factory $PinnedWifiStateCopyWith(PinnedWifiState value, $Res Function(PinnedWifiState) _then) = _$PinnedWifiStateCopyWithImpl;
@useResult
$Res call({
 PinnedWifiPhase phase, WifiConfig? config, WifiConfig? target, String? actualBssid, WifiFailure? failure, int retryAttempt, Duration? retryDelay
});


$WifiConfigCopyWith<$Res>? get config;$WifiConfigCopyWith<$Res>? get target;

}
/// @nodoc
class _$PinnedWifiStateCopyWithImpl<$Res>
    implements $PinnedWifiStateCopyWith<$Res> {
  _$PinnedWifiStateCopyWithImpl(this._self, this._then);

  final PinnedWifiState _self;
  final $Res Function(PinnedWifiState) _then;

/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? config = freezed,Object? target = freezed,Object? actualBssid = freezed,Object? failure = freezed,Object? retryAttempt = null,Object? retryDelay = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PinnedWifiPhase,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as WifiConfig?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as WifiConfig?,actualBssid: freezed == actualBssid ? _self.actualBssid : actualBssid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as WifiFailure?,retryAttempt: null == retryAttempt ? _self.retryAttempt : retryAttempt // ignore: cast_nullable_to_non_nullable
as int,retryDelay: freezed == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}
/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WifiConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $WifiConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WifiConfigCopyWith<$Res>? get target {
    if (_self.target == null) {
    return null;
  }

  return $WifiConfigCopyWith<$Res>(_self.target!, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [PinnedWifiState].
extension PinnedWifiStatePatterns on PinnedWifiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PinnedWifiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PinnedWifiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PinnedWifiState value)  $default,){
final _that = this;
switch (_that) {
case _PinnedWifiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PinnedWifiState value)?  $default,){
final _that = this;
switch (_that) {
case _PinnedWifiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PinnedWifiPhase phase,  WifiConfig? config,  WifiConfig? target,  String? actualBssid,  WifiFailure? failure,  int retryAttempt,  Duration? retryDelay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PinnedWifiState() when $default != null:
return $default(_that.phase,_that.config,_that.target,_that.actualBssid,_that.failure,_that.retryAttempt,_that.retryDelay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PinnedWifiPhase phase,  WifiConfig? config,  WifiConfig? target,  String? actualBssid,  WifiFailure? failure,  int retryAttempt,  Duration? retryDelay)  $default,) {final _that = this;
switch (_that) {
case _PinnedWifiState():
return $default(_that.phase,_that.config,_that.target,_that.actualBssid,_that.failure,_that.retryAttempt,_that.retryDelay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PinnedWifiPhase phase,  WifiConfig? config,  WifiConfig? target,  String? actualBssid,  WifiFailure? failure,  int retryAttempt,  Duration? retryDelay)?  $default,) {final _that = this;
switch (_that) {
case _PinnedWifiState() when $default != null:
return $default(_that.phase,_that.config,_that.target,_that.actualBssid,_that.failure,_that.retryAttempt,_that.retryDelay);case _:
  return null;

}
}

}

/// @nodoc


class _PinnedWifiState extends PinnedWifiState {
  const _PinnedWifiState({this.phase = PinnedWifiPhase.initial, this.config, this.target, this.actualBssid, this.failure, this.retryAttempt = 0, this.retryDelay}): super._();
  

@override@JsonKey() final  PinnedWifiPhase phase;
/// Stored (verified) router, if any.
@override final  WifiConfig? config;
/// Router of the attempt in flight; differs from [config] during setup.
@override final  WifiConfig? target;
/// BSSID the platform reports for the live connection.
@override final  String? actualBssid;
/// Last failure; kept while retrying so the user sees why.
@override final  WifiFailure? failure;
/// Consecutive failed attempts since the last verified connection.
@override@JsonKey() final  int retryAttempt;
@override final  Duration? retryDelay;

/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PinnedWifiStateCopyWith<_PinnedWifiState> get copyWith => __$PinnedWifiStateCopyWithImpl<_PinnedWifiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PinnedWifiState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.config, config) || other.config == config)&&(identical(other.target, target) || other.target == target)&&(identical(other.actualBssid, actualBssid) || other.actualBssid == actualBssid)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAttempt, retryAttempt) || other.retryAttempt == retryAttempt)&&(identical(other.retryDelay, retryDelay) || other.retryDelay == retryDelay));
}


@override
int get hashCode => Object.hash(runtimeType,phase,config,target,actualBssid,failure,retryAttempt,retryDelay);

@override
String toString() {
  return 'PinnedWifiState(phase: $phase, config: $config, target: $target, actualBssid: $actualBssid, failure: $failure, retryAttempt: $retryAttempt, retryDelay: $retryDelay)';
}


}

/// @nodoc
abstract mixin class _$PinnedWifiStateCopyWith<$Res> implements $PinnedWifiStateCopyWith<$Res> {
  factory _$PinnedWifiStateCopyWith(_PinnedWifiState value, $Res Function(_PinnedWifiState) _then) = __$PinnedWifiStateCopyWithImpl;
@override @useResult
$Res call({
 PinnedWifiPhase phase, WifiConfig? config, WifiConfig? target, String? actualBssid, WifiFailure? failure, int retryAttempt, Duration? retryDelay
});


@override $WifiConfigCopyWith<$Res>? get config;@override $WifiConfigCopyWith<$Res>? get target;

}
/// @nodoc
class __$PinnedWifiStateCopyWithImpl<$Res>
    implements _$PinnedWifiStateCopyWith<$Res> {
  __$PinnedWifiStateCopyWithImpl(this._self, this._then);

  final _PinnedWifiState _self;
  final $Res Function(_PinnedWifiState) _then;

/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? config = freezed,Object? target = freezed,Object? actualBssid = freezed,Object? failure = freezed,Object? retryAttempt = null,Object? retryDelay = freezed,}) {
  return _then(_PinnedWifiState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PinnedWifiPhase,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as WifiConfig?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as WifiConfig?,actualBssid: freezed == actualBssid ? _self.actualBssid : actualBssid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as WifiFailure?,retryAttempt: null == retryAttempt ? _self.retryAttempt : retryAttempt // ignore: cast_nullable_to_non_nullable
as int,retryDelay: freezed == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WifiConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $WifiConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}/// Create a copy of PinnedWifiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WifiConfigCopyWith<$Res>? get target {
    if (_self.target == null) {
    return null;
  }

  return $WifiConfigCopyWith<$Res>(_self.target!, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

// dart format on
