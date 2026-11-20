import 'package:freezed_annotation/freezed_annotation.dart';

import 'wifi_security.dart';

part 'wifi_config.freezed.dart';
part 'wifi_config.g.dart';

/// The router to pin to: an exact SSID + BSSID pair plus what is needed to
/// rejoin it.
///
/// An empty [bssid] means "not locked yet": the first join to [ssid] locks
/// whichever BSSID it lands on (`WifiManagement` stores the config with it).
///
/// JSON: `{"ssid": "...", "bssid": "aa:bb:...", "security": "wpa2",
/// "password": "...", "hidden": false}`. The password is in that JSON; store
/// it accordingly. `hidden` is optional (older entries read as false).
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

    /// The router does not broadcast its SSID, so it must be probed by name.
    @Default(false) bool hidden,
  }) = _WifiConfig;

  /// Throws when a field is missing or has the wrong type.
  factory WifiConfig.fromJson(Map<String, dynamic> json) =>
      _$WifiConfigFromJson(json);

  /// Lower case, `-` separators turned into `:`.
  static String normalizeBssid(String bssid) =>
      bssid.trim().toLowerCase().replaceAll('-', ':');

  static final _bssidPattern = RegExp(r'^([0-9a-f]{2}:){5}[0-9a-f]{2}$');

  /// Whether [bssid] reads as `aa:bb:cc:dd:ee:ff` (after [normalizeBssid]).
  static bool isValidBssid(String bssid) =>
      _bssidPattern.hasMatch(normalizeBssid(bssid));

  /// False until a BSSID is known; see the class doc.
  bool get isBssidLocked => bssid.trim().isNotEmpty;

  /// Whether [actualBssid] (what the platform reports it joined) is this
  /// router. Any readable BSSID matches while none is locked.
  bool matchesBssid(String? actualBssid) =>
      actualBssid != null &&
      (!isBssidLocked || normalizeBssid(actualBssid) == normalizeBssid(bssid));

  @override
  String toString() =>
      'WifiConfig(ssid: $ssid, bssid: $bssid, security: ${security.code}, '
      'hidden: $hidden)';
}
