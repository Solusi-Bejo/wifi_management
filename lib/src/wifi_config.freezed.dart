// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WifiConfig {

 String get ssid;/// Lower-case `aa:bb:cc:dd:ee:ff`; see [normalizeBssid].
 String get bssid;@JsonKey(unknownEnumValue: WifiSecurity.unsupported) WifiSecurity get security;/// Never logged; [toString] leaves it out.
 String get password;
/// Create a copy of WifiConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiConfigCopyWith<WifiConfig> get copyWith => _$WifiConfigCopyWithImpl<WifiConfig>(this as WifiConfig, _$identity);

  /// Serializes this WifiConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiConfig&&(identical(other.ssid, ssid) || other.ssid == ssid)&&(identical(other.bssid, bssid) || other.bssid == bssid)&&(identical(other.security, security) || other.security == security)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ssid,bssid,security,password);



}

/// @nodoc
abstract mixin class $WifiConfigCopyWith<$Res>  {
  factory $WifiConfigCopyWith(WifiConfig value, $Res Function(WifiConfig) _then) = _$WifiConfigCopyWithImpl;
@useResult
$Res call({
 String ssid, String bssid,@JsonKey(unknownEnumValue: WifiSecurity.unsupported) WifiSecurity security, String password
});




}
/// @nodoc
class _$WifiConfigCopyWithImpl<$Res>
    implements $WifiConfigCopyWith<$Res> {
  _$WifiConfigCopyWithImpl(this._self, this._then);

  final WifiConfig _self;
  final $Res Function(WifiConfig) _then;

/// Create a copy of WifiConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ssid = null,Object? bssid = null,Object? security = null,Object? password = null,}) {
  return _then(_self.copyWith(
ssid: null == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String,bssid: null == bssid ? _self.bssid : bssid // ignore: cast_nullable_to_non_nullable
as String,security: null == security ? _self.security : security // ignore: cast_nullable_to_non_nullable
as WifiSecurity,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WifiConfig].
extension WifiConfigPatterns on WifiConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WifiConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WifiConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WifiConfig value)  $default,){
final _that = this;
switch (_that) {
case _WifiConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WifiConfig value)?  $default,){
final _that = this;
switch (_that) {
case _WifiConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ssid,  String bssid, @JsonKey(unknownEnumValue: WifiSecurity.unsupported)  WifiSecurity security,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WifiConfig() when $default != null:
return $default(_that.ssid,_that.bssid,_that.security,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ssid,  String bssid, @JsonKey(unknownEnumValue: WifiSecurity.unsupported)  WifiSecurity security,  String password)  $default,) {final _that = this;
switch (_that) {
case _WifiConfig():
return $default(_that.ssid,_that.bssid,_that.security,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ssid,  String bssid, @JsonKey(unknownEnumValue: WifiSecurity.unsupported)  WifiSecurity security,  String password)?  $default,) {final _that = this;
switch (_that) {
case _WifiConfig() when $default != null:
return $default(_that.ssid,_that.bssid,_that.security,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WifiConfig extends WifiConfig {
  const _WifiConfig({required this.ssid, required this.bssid, @JsonKey(unknownEnumValue: WifiSecurity.unsupported) required this.security, this.password = ''}): super._();
  factory _WifiConfig.fromJson(Map<String, dynamic> json) => _$WifiConfigFromJson(json);

@override final  String ssid;
/// Lower-case `aa:bb:cc:dd:ee:ff`; see [normalizeBssid].
@override final  String bssid;
@override@JsonKey(unknownEnumValue: WifiSecurity.unsupported) final  WifiSecurity security;
/// Never logged; [toString] leaves it out.
@override@JsonKey() final  String password;

/// Create a copy of WifiConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WifiConfigCopyWith<_WifiConfig> get copyWith => __$WifiConfigCopyWithImpl<_WifiConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WifiConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WifiConfig&&(identical(other.ssid, ssid) || other.ssid == ssid)&&(identical(other.bssid, bssid) || other.bssid == bssid)&&(identical(other.security, security) || other.security == security)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ssid,bssid,security,password);



}

/// @nodoc
abstract mixin class _$WifiConfigCopyWith<$Res> implements $WifiConfigCopyWith<$Res> {
  factory _$WifiConfigCopyWith(_WifiConfig value, $Res Function(_WifiConfig) _then) = __$WifiConfigCopyWithImpl;
@override @useResult
$Res call({
 String ssid, String bssid,@JsonKey(unknownEnumValue: WifiSecurity.unsupported) WifiSecurity security, String password
});




}
/// @nodoc
class __$WifiConfigCopyWithImpl<$Res>
    implements _$WifiConfigCopyWith<$Res> {
  __$WifiConfigCopyWithImpl(this._self, this._then);

  final _WifiConfig _self;
  final $Res Function(_WifiConfig) _then;

/// Create a copy of WifiConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ssid = null,Object? bssid = null,Object? security = null,Object? password = null,}) {
  return _then(_WifiConfig(
ssid: null == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String,bssid: null == bssid ? _self.bssid : bssid // ignore: cast_nullable_to_non_nullable
as String,security: null == security ? _self.security : security // ignore: cast_nullable_to_non_nullable
as WifiSecurity,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
