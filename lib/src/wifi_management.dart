import 'wifi_config.dart';
import 'wifi_connection.dart';
import 'wifi_management_platform.dart';

/// Stateless entry point: capabilities, readiness, scan, and an exact-BSSID
/// join. For "remember this router and stay on it", use `PinnedWifiManager`.
class WifiManagement {
  WifiManagement({WifiManagementPlatform? platform})
    : _platform = platform ?? WifiManagementPlatform.instance;

  final WifiManagementPlatform _platform;

  Future<WifiCapabilities> capabilities() => _platform.capabilities();

  /// What blocks a scan or a join. With [requestPermission], missing
  /// permissions are asked for first.
  Future<WifiReadiness> checkReadiness({bool requestPermission = false}) async {
    final readiness = await _platform.checkReadiness();
    if (readiness != WifiReadiness.permissionDenied || !requestPermission) {
      return readiness;
    }
    if (!await _platform.requestPermissions()) {
      return WifiReadiness.permissionDenied;
    }
    return _platform.checkReadiness();
  }

  /// One entry per BSSID, strongest signal first. Routers that share an SSID
  /// stay separate entries.
  Future<WifiScanResult> scan() async {
    final result = await _platform.scan();
    final byBssid = {for (final ap in result.accessPoints) ap.bssid: ap};
    final sorted = byBssid.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    return (accessPoints: sorted, failure: result.failure);
  }

  /// Joins exactly [config]'s SSID + BSSID. A join that lands on any other
  /// BSSID is released and reported as [WifiFailure.bssidMismatch], even when
  /// the platform already claimed success.
  Future<WifiConnectResult> connect(WifiConfig config) async {
    final result = await _platform.connect(config);
    if (result case WifiConnected(
      :final actualBssid,
    ) when !config.matchesBssid(actualBssid)) {
      await _platform.disconnect();
      return const WifiConnectResult.failed(WifiFailure.bssidMismatch);
    }
    return result;
  }

  Future<void> disconnect() => _platform.disconnect();

  Stream<WifiNetworkEvent> get events => _platform.events;

  Future<void> openSettings(WifiSettingsTarget target) => switch (target) {
    WifiSettingsTarget.location => _platform.openLocationSettings(),
    WifiSettingsTarget.app => _platform.openAppSettings(),
  };
}
