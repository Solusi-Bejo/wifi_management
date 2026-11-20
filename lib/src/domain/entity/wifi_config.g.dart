// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wifi_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WifiConfig _$WifiConfigFromJson(Map<String, dynamic> json) => _WifiConfig(
  ssid: json['ssid'] as String,
  bssid: json['bssid'] as String,
  security: $enumDecode(
    _$WifiSecurityEnumMap,
    json['security'],
    unknownValue: WifiSecurity.unsupported,
  ),
  password: json['password'] as String? ?? '',
  hidden: json['hidden'] as bool? ?? false,
);

Map<String, dynamic> _$WifiConfigToJson(_WifiConfig instance) =>
    <String, dynamic>{
      'ssid': instance.ssid,
      'bssid': instance.bssid,
      'security': _$WifiSecurityEnumMap[instance.security]!,
      'password': instance.password,
      'hidden': instance.hidden,
    };

const _$WifiSecurityEnumMap = {
  WifiSecurity.open: 'open',
  WifiSecurity.wpa2: 'wpa2',
  WifiSecurity.wpa3: 'wpa3',
  WifiSecurity.unsupported: 'unsupported',
};
