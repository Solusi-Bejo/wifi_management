// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_management_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WifiManagementState {

 WifiManagementPhase get phase;/// Stored (verified) router, if any.
 WifiConfig? get config;/// Router of the attempt in flight; differs from [config] during setup.
 WifiConfig? get target;/// BSSID the platform reports for the live connection.
 String? get actualBssid;/// Last failure; kept while retrying so the user sees why.
 WifiFailure? get failure;/// Consecutive failed attempts since the last verified connection.
 int get retryAttempt; Duration? get retryDelay;
/// Create a copy of WifiManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiManagementStateCopyWith<WifiManagementState> get copyWith => _$WifiManagementStateCopyWithImpl<WifiManagementState>(this as WifiManagementState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiManagementState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.config, config) || other.config == config)&&(identical(other.target, target) || other.target == target)&&(identical(other.actualBssid, actualBssid) || other.actualBssid == actualBssid)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAttempt, retryAttempt) || other.retryAttempt == retryAttempt)&&(identical(other.retryDelay, retryDelay) || other.retryDelay == retryDelay));
}


@override
int get hashCode => Object.hash(runtimeType,phase,config,target,actualBssid,failure,retryAttempt,retryDelay);

@override
String toString() {
  return 'WifiManagementState(phase: $phase, config: $config, target: $target, actualBssid: $actualBssid, failure: $failure, retryAttempt: $retryAttempt, retryDelay: $retryDelay)';
}


}

/// @nodoc
abstract mixin class $WifiManagementStateCopyWith<$Res>  {
  factory $WifiManagementStateCopyWith(WifiManagementState value, $Res Function(WifiManagementState) _then) = _$WifiManagementStateCopyWithImpl;
@useResult
$Res call({
 WifiManagementPhase phase, WifiConfig? config, WifiConfig? target, String? actualBssid, WifiFailure? failure, int retryAttempt, Duration? retryDelay
});


$WifiConfigCopyWith<$Res>? get config;$WifiConfigCopyWith<$Res>? get target;

}
/// @nodoc
class _$WifiManagementStateCopyWithImpl<$Res>
    implements $WifiManagementStateCopyWith<$Res> {
  _$WifiManagementStateCopyWithImpl(this._self, this._then);

  final WifiManagementState _self;
  final $Res Function(WifiManagementState) _then;

/// Create a copy of WifiManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? config = freezed,Object? target = freezed,Object? actualBssid = freezed,Object? failure = freezed,Object? retryAttempt = null,Object? retryDelay = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WifiManagementPhase,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as WifiConfig?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as WifiConfig?,actualBssid: freezed == actualBssid ? _self.actualBssid : actualBssid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as WifiFailure?,retryAttempt: null == retryAttempt ? _self.retryAttempt : retryAttempt // ignore: cast_nullable_to_non_nullable
as int,retryDelay: freezed == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}
/// Create a copy of WifiManagementState
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
}/// Create a copy of WifiManagementState
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


/// Adds pattern-matching-related methods to [WifiManagementState].
extension WifiManagementStatePatterns on WifiManagementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WifiManagementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WifiManagementState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WifiManagementState value)  $default,){
final _that = this;
switch (_that) {
case _WifiManagementState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WifiManagementState value)?  $default,){
final _that = this;
switch (_that) {
case _WifiManagementState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WifiManagementPhase phase,  WifiConfig? config,  WifiConfig? target,  String? actualBssid,  WifiFailure? failure,  int retryAttempt,  Duration? retryDelay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WifiManagementState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WifiManagementPhase phase,  WifiConfig? config,  WifiConfig? target,  String? actualBssid,  WifiFailure? failure,  int retryAttempt,  Duration? retryDelay)  $default,) {final _that = this;
switch (_that) {
case _WifiManagementState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WifiManagementPhase phase,  WifiConfig? config,  WifiConfig? target,  String? actualBssid,  WifiFailure? failure,  int retryAttempt,  Duration? retryDelay)?  $default,) {final _that = this;
switch (_that) {
case _WifiManagementState() when $default != null:
return $default(_that.phase,_that.config,_that.target,_that.actualBssid,_that.failure,_that.retryAttempt,_that.retryDelay);case _:
  return null;

}
}

}

/// @nodoc


class _WifiManagementState extends WifiManagementState {
  const _WifiManagementState({this.phase = WifiManagementPhase.initial, this.config, this.target, this.actualBssid, this.failure, this.retryAttempt = 0, this.retryDelay}): super._();
  

@override@JsonKey() final  WifiManagementPhase phase;
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

/// Create a copy of WifiManagementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WifiManagementStateCopyWith<_WifiManagementState> get copyWith => __$WifiManagementStateCopyWithImpl<_WifiManagementState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WifiManagementState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.config, config) || other.config == config)&&(identical(other.target, target) || other.target == target)&&(identical(other.actualBssid, actualBssid) || other.actualBssid == actualBssid)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAttempt, retryAttempt) || other.retryAttempt == retryAttempt)&&(identical(other.retryDelay, retryDelay) || other.retryDelay == retryDelay));
}


@override
int get hashCode => Object.hash(runtimeType,phase,config,target,actualBssid,failure,retryAttempt,retryDelay);

@override
String toString() {
  return 'WifiManagementState(phase: $phase, config: $config, target: $target, actualBssid: $actualBssid, failure: $failure, retryAttempt: $retryAttempt, retryDelay: $retryDelay)';
}


}

/// @nodoc
abstract mixin class _$WifiManagementStateCopyWith<$Res> implements $WifiManagementStateCopyWith<$Res> {
  factory _$WifiManagementStateCopyWith(_WifiManagementState value, $Res Function(_WifiManagementState) _then) = __$WifiManagementStateCopyWithImpl;
@override @useResult
$Res call({
 WifiManagementPhase phase, WifiConfig? config, WifiConfig? target, String? actualBssid, WifiFailure? failure, int retryAttempt, Duration? retryDelay
});


@override $WifiConfigCopyWith<$Res>? get config;@override $WifiConfigCopyWith<$Res>? get target;

}
/// @nodoc
class __$WifiManagementStateCopyWithImpl<$Res>
    implements _$WifiManagementStateCopyWith<$Res> {
  __$WifiManagementStateCopyWithImpl(this._self, this._then);

  final _WifiManagementState _self;
  final $Res Function(_WifiManagementState) _then;

/// Create a copy of WifiManagementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? config = freezed,Object? target = freezed,Object? actualBssid = freezed,Object? failure = freezed,Object? retryAttempt = null,Object? retryDelay = freezed,}) {
  return _then(_WifiManagementState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as WifiManagementPhase,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as WifiConfig?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as WifiConfig?,actualBssid: freezed == actualBssid ? _self.actualBssid : actualBssid // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as WifiFailure?,retryAttempt: null == retryAttempt ? _self.retryAttempt : retryAttempt // ignore: cast_nullable_to_non_nullable
as int,retryDelay: freezed == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

/// Create a copy of WifiManagementState
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
}/// Create a copy of WifiManagementState
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
