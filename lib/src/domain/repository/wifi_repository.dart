import '../entity/wifi_access_point.dart';
import '../entity/wifi_capabilities.dart';
import '../entity/wifi_config.dart';
import '../entity/wifi_connect_result.dart';
import '../entity/wifi_forget_result.dart';
import '../entity/wifi_network_event.dart';
import '../entity/wifi_readiness.dart';
import '../entity/wifi_scan_result.dart';

/// The device's Wi-Fi radio as the domain sees it. Answers are raw: rules such
/// as BSSID verification and scan de-duplication live in the use cases.
abstract interface class WifiRepository {
  Future<WifiCapabilities> capabilities();

  Future<WifiReadiness> checkReadiness();

  /// Shows the runtime permission prompt. True when everything is granted.
  Future<bool> requestPermissions();

  /// May contain the same BSSID more than once.
  Future<WifiScanResult> scan();

  /// Requests exactly [config]'s SSID + BSSID. Releases the previous request.
  Future<WifiConnectResult> connect(WifiConfig config);

  Future<void> disconnect();

  /// The Wi-Fi the device itself is on now, or null when on none (or it
  /// cannot be read).
  Future<WifiAccessPoint?> currentNetwork();

  /// Removes [ssid] from the device's saved Wi-Fi networks, so the device
  /// itself stops joining it (Android: Device Owner only).
  Future<WifiForgetResult> forgetSystemNetwork(String ssid);

  /// Changes of the request made by the latest [connect].
  Stream<WifiNetworkEvent> get events;

  Future<void> openSettings(WifiSettingsTarget target);
}
