import 'package:pigeon/pigeon.dart';

// Interface between Dart and the host platforms. After editing, run
//   dart run pigeon --input pigeon/messages.dart
// with the oldest supported Flutter (3.41) so the generated Dart stays
// compatible with Dart 3.11.

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'wifi_management',
    dartOut: 'lib/src/data/datasource/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/solusibejo/wifi_management/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.solusibejo.wifi_management'),
    swiftOut: 'ios/wifi_management/Sources/wifi_management/Messages.g.swift',
  ),
)
/// What the host platform can do for pinning.
class PlatformCapabilities {
  PlatformCapabilities({
    required this.supported,
    required this.canScan,
    required this.canLockBssid,
    required this.canBindProcess,
  });

  bool supported;
  bool canScan;
  bool canLockBssid;
  bool canBindProcess;
}

class PlatformReadiness {
  PlatformReadiness({
    required this.supported,
    required this.permissionsGranted,
    required this.locationEnabled,
  });

  bool supported;
  bool permissionsGranted;
  bool locationEnabled;
}

class PlatformAccessPoint {
  PlatformAccessPoint({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.security,
  });

  String ssid;
  String bssid;
  int rssi;

  /// `open`, `wpa2`, `wpa3` or `unsupported`.
  String security;
}

/// Outcome of a scan: access points, or a failure code (`unsupported`,
/// `permission_denied`, `location_disabled`, `scan_failed`).
class PlatformScanResult {
  PlatformScanResult({required this.accessPoints, this.failure});

  List<PlatformAccessPoint> accessPoints;
  String? failure;
}

class PlatformConnectRequest {
  PlatformConnectRequest({
    required this.requestId,
    required this.ssid,
    required this.bssid,
    required this.security,
    required this.password,
    required this.hidden,
  });

  int requestId;
  String ssid;

  /// Empty: not locked yet; join [ssid] and report the BSSID it lands on.
  String bssid;
  String security;
  String password;

  /// The SSID is not broadcast; probe for it by name.
  bool hidden;
}

/// Status change of the request made by the latest `connect`.
/// `type`: `connecting`, `connected`, `lost`, `unavailable`, `error`.
class PlatformNetworkEvent {
  PlatformNetworkEvent({
    required this.requestId,
    required this.type,
    this.ssid,
    this.bssid,
    this.failure,
  });

  int requestId;
  String type;
  String? ssid;
  String? bssid;
  String? failure;
}

@HostApi()
abstract class WifiManagementHostApi {
  PlatformCapabilities capabilities();

  PlatformReadiness checkReadiness();

  /// True when everything needed is granted after the prompt.
  @async
  bool requestPermissions();

  @async
  PlatformScanResult scan();

  /// Starts the request; the outcome arrives on [WifiManagementEventApi].
  void connect(PlatformConnectRequest request);

  void disconnect();

  /// Removes every network saved in the system Wi-Fi settings under [ssid],
  /// which also drops the device's own connection to it. Android only, and
  /// only when the app is the Device Owner. Returns `removed`, `not_found`,
  /// `not_device_owner`, `unsupported` or `failed`.
  String forgetSystemNetwork(String ssid);

  /// The Wi-Fi the device itself is on now; null when it is on none or the
  /// SSID/BSSID cannot be read (permission, Location Services).
  @async
  PlatformAccessPoint? currentNetwork();

  void openLocationSettings();
  void openWifiSettings();

  void openAppSettings();
}

@EventChannelApi()
abstract class WifiManagementEventApi {
  PlatformNetworkEvent networkEvents();
}
