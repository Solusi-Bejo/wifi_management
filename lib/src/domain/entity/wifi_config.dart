import 'package:freezed_annotation/freezed_annotation.dart';

import 'wifi_security.dart';

part 'wifi_config.freezed.dart';
part 'wifi_config.g.dart';

/// The router to pin to: an exact SSID + BSSID pair plus what is needed to
/// rejoin it.
///
/// JSON: `{"ssid": "...", "bssid": "aa:bb:...", "security": "wpa2",
/// "password": "..."}`. The password is in that JSON; store it accordingly.
@freezed
abstract class WifiConfig with _$WifiConfig {
  const WifiConfig._();

  const factory WifiConfig({
    required String ssid,

    /// Lower-case `aa:bb:cc:dd:ee:ff`; see [normalizeBssid].
    required String bssid,
    @JsonKey(unknownEnumValue: WifiSecurity.unsupported)
    required WifiSecurity security,

    /// Never logged; [toString] leaves it out.
    @Default('') String password,
  }) = _WifiConfig;

  /// Throws when a field is missing or has the wrong type.
  factory WifiConfig.fromJson(Map<String, dynamic> json) =>
      _$WifiConfigFromJson(json);

  static String normalizeBssid(String bssid) => bssid.trim().toLowerCase();

  /// Whether [actualBssid] (what the platform reports it joined) is this
  /// router.
  bool matchesBssid(String? actualBssid) =>
      actualBssid != null &&
      normalizeBssid(actualBssid) == normalizeBssid(bssid);

  @override
  String toString() =>
      'WifiConfig(ssid: $ssid, bssid: $bssid, security: ${security.code})';
}
