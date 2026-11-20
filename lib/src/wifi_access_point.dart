import 'package:freezed_annotation/freezed_annotation.dart';

part 'wifi_access_point.freezed.dart';

/// Router security as reported by a scan. Only PSK (WPA2/WPA3) and open
/// networks can be joined without extra credentials, so everything else is
/// [unsupported].
@JsonEnum(valueField: 'code')
enum WifiSecurity {
  open('open'),
  wpa2('wpa2'),
  wpa3('wpa3'),
  unsupported('unsupported');

  const WifiSecurity(this.code);

  /// Wire value shared with the host platforms and the stored config.
  final String code;

  static WifiSecurity fromCode(String? code) => values.firstWhere(
    (value) => value.code == code,
    orElse: () => WifiSecurity.unsupported,
  );

  bool get needsPassword => this == wpa2 || this == wpa3;

  bool get isSupported => this != unsupported;
}

/// One access point seen by a scan. Two routers broadcasting the same SSID are
/// two access points: [bssid] is the identity, [ssid] is only a label.
@freezed
abstract class WifiAccessPoint with _$WifiAccessPoint {
  const factory WifiAccessPoint({
    required String ssid,

    /// Lower-case `aa:bb:cc:dd:ee:ff`.
    required String bssid,

    /// Signal strength in dBm (closer to 0 is stronger).
    required int rssi,
    required WifiSecurity security,
  }) = _WifiAccessPoint;
}
