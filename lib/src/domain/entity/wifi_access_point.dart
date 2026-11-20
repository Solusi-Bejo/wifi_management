import 'package:freezed_annotation/freezed_annotation.dart';

import 'wifi_security.dart';

part 'wifi_access_point.freezed.dart';

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
