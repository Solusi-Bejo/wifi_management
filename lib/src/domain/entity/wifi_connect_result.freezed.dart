// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_connect_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
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
