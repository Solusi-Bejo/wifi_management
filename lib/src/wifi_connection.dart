import 'package:freezed_annotation/freezed_annotation.dart';

import 'wifi_access_point.dart';

part 'wifi_connection.freezed.dart';

/// Why a scan, a connection, or a stored configuration failed. Each value maps
/// to an action the user can take.
enum WifiFailure {
  /// Not Android 10+ / iOS, or the platform cannot do what was asked.
  unsupported('unsupported'),
  permissionDenied('permission_denied'),
  locationDisabled('location_disabled'),

  /// The platform joined a router, but not the one requested.
  bssidMismatch('bssid_mismatch'),

  /// The router was not found, the request timed out on the device, or the
  /// user rejected the system approval dialog.
  unavailable('unavailable'),

  /// No answer from the device within the Dart-side deadline.
  timeout('timeout'),
  bindFailed('bind_failed'),
  invalidConfig('invalid_config'),
  scanFailed('scan_failed'),
  storageFailed('storage_failed'),
  unknown('unknown');

  const WifiFailure(this.code);

  /// Wire value used by the host platforms.
  final String code;

  static WifiFailure fromCode(String? code) => values.firstWhere(
    (value) => value.code == code,
    orElse: () => WifiFailure.unknown,
  );
}

/// What stands between the device and a scan or a join.
enum WifiReadiness { ready, unsupported, permissionDenied, locationDisabled }

/// System screens that fix a [WifiReadiness] problem.
enum WifiSettingsTarget { location, app }

/// What the current platform can do.
@freezed
abstract class WifiCapabilities with _$WifiCapabilities {
  const factory WifiCapabilities({
    /// Joining a pinned router works at all (Android 10+, iOS).
    required bool supported,

    /// Nearby routers can be listed (Android only).
    required bool canScan,

    /// The OS only joins the requested BSSID (Android). Elsewhere the BSSID is
    /// verified after the join and a mismatch is reported, not prevented.
    required bool canLockBssid,

    /// The app's traffic is bound to the pinned network (Android).
    required bool canBindProcess,
  }) = _WifiCapabilities;

  static const none = WifiCapabilities(
    supported: false,
    canScan: false,
    canLockBssid: false,
    canBindProcess: false,
  );
}

enum WifiNetworkEventType {
  connecting,
  connected,
  lost,
  unavailable,
  error;

  static WifiNetworkEventType fromName(String? name) => values.firstWhere(
    (value) => value.name == name,
    orElse: () => WifiNetworkEventType.error,
  );
}

/// A status change of the active network request, pushed by the platform.
@freezed
abstract class WifiNetworkEvent with _$WifiNetworkEvent {
  const factory WifiNetworkEvent({
    required WifiNetworkEventType type,
    String? ssid,

    /// For [WifiNetworkEventType.connected], the BSSID actually joined.
    String? bssid,
    WifiFailure? failure,
  }) = _WifiNetworkEvent;
}

/// Outcome of one request for the pinned network.
@freezed
sealed class WifiConnectResult with _$WifiConnectResult {
  /// Joined and the BSSID matched (and, on Android, the process is bound).
  const factory WifiConnectResult.connected(String actualBssid) = WifiConnected;

  const factory WifiConnectResult.failed(WifiFailure failure) =
      WifiConnectFailed;
}

/// Outcome of a scan: the access points, or why there are none.
typedef WifiScanResult = ({
  List<WifiAccessPoint> accessPoints,
  WifiFailure? failure,
});
