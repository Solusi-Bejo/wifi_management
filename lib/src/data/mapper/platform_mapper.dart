import '../../domain/entity/wifi_access_point.dart';
import '../../domain/entity/wifi_capabilities.dart';
import '../../domain/entity/wifi_config.dart';
import '../../domain/entity/wifi_failure.dart';
import '../../domain/entity/wifi_network_event.dart';
import '../../domain/entity/wifi_readiness.dart';
import '../../domain/entity/wifi_scan_result.dart';
import '../../domain/entity/wifi_security.dart';
import '../datasource/messages.g.dart';

extension PlatformCapabilitiesMapper on PlatformCapabilities {
  WifiCapabilities get asEntity => WifiCapabilities(
    supported: supported,
    canScan: canScan,
    canLockBssid: canLockBssid,
    canBindProcess: canBindProcess,
  );
}

extension PlatformReadinessMapper on PlatformReadiness {
  WifiReadiness get asEntity {
    if (!supported) return WifiReadiness.unsupported;
    if (!permissionsGranted) return WifiReadiness.permissionDenied;
    if (!locationEnabled) return WifiReadiness.locationDisabled;
    return WifiReadiness.ready;
  }
}

extension PlatformAccessPointMapper on PlatformAccessPoint {
  WifiAccessPoint get asEntity => WifiAccessPoint(
    ssid: ssid,
    bssid: WifiConfig.normalizeBssid(bssid),
    rssi: rssi,
    security: WifiSecurity.fromCode(security),
  );
}

extension PlatformScanResultMapper on PlatformScanResult {
  WifiScanResult get asEntity => (
    accessPoints: [for (final ap in accessPoints) ap.asEntity],
    failure: failure == null ? null : WifiFailure.fromCode(failure),
  );
}

extension PlatformNetworkEventMapper on PlatformNetworkEvent {
  WifiNetworkEvent get asEntity => WifiNetworkEvent(
    type: WifiNetworkEventType.fromName(type),
    ssid: ssid,
    bssid: bssid,
    failure: failure == null ? null : WifiFailure.fromCode(failure),
  );
}

extension WifiConfigRequestMapper on WifiConfig {
  PlatformConnectRequest asRequest(int requestId) => PlatformConnectRequest(
    requestId: requestId,
    ssid: ssid,
    bssid: WifiConfig.normalizeBssid(bssid),
    security: security.code,
    password: password,
    hidden: hidden,
  );
}
