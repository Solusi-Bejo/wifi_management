import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../domain/entity/wifi_access_point.dart';
import '../../domain/entity/wifi_capabilities.dart';
import '../../domain/entity/wifi_config.dart';
import '../../domain/entity/wifi_connect_result.dart';
import '../../domain/entity/wifi_forget_result.dart';
import '../../domain/entity/wifi_network_event.dart';
import '../../domain/entity/wifi_readiness.dart';
import '../../domain/entity/wifi_scan_result.dart';
import 'pigeon_wifi_management.dart';

/// Host side of `wifi_management`. Apps go through `WifiRepositoryImpl`;
/// tests replace [instance] with a fake.
abstract class WifiManagementPlatform extends PlatformInterface {
  WifiManagementPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiManagementPlatform _instance = PigeonWifiManagement();

  /// Defaults to [PigeonWifiManagement].
  static WifiManagementPlatform get instance => _instance;

  static set instance(WifiManagementPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<WifiCapabilities> capabilities() =>
      throw UnimplementedError('capabilities() has not been implemented.');

  Future<WifiReadiness> checkReadiness() =>
      throw UnimplementedError('checkReadiness() has not been implemented.');

  /// Shows the runtime permission prompt. True when everything is granted.
  Future<bool> requestPermissions() => throw UnimplementedError(
    'requestPermissions() has not been implemented.',
  );

  /// Raw scan as the platform reports it (may contain duplicates).
  Future<WifiScanResult> scan() =>
      throw UnimplementedError('scan() has not been implemented.');

  /// Requests exactly [config]'s SSID + BSSID and completes once that is
  /// settled. Only one request is alive at a time: this releases the previous
  /// one.
  Future<WifiConnectResult> connect(WifiConfig config) =>
      throw UnimplementedError('connect() has not been implemented.');

  /// Releases the network request (and, on Android, the process binding).
  Future<void> disconnect() =>
      throw UnimplementedError('disconnect() has not been implemented.');

  /// Removes [ssid] from the device's saved Wi-Fi networks, which also drops
  /// the device's own connection to it. Android needs the app to be the
  /// Device Owner.
  Future<WifiForgetResult> forgetSystemNetwork(String ssid) =>
      throw UnimplementedError(
        'forgetSystemNetwork() has not been implemented.',
      );

  /// The Wi-Fi the device itself is on now, or null.
  Future<WifiAccessPoint?> currentNetwork() =>
      throw UnimplementedError('currentNetwork() has not been implemented.');

  /// Opens the system Wi-Fi picker.
  Future<void> openWifiSettings() =>
      throw UnimplementedError('openWifiSettings() has not been implemented.');

  /// Changes of the request made by the latest [connect], notably
  /// [WifiNetworkEventType.lost] after it was connected.
  Stream<WifiNetworkEvent> get events =>
      throw UnimplementedError('events has not been implemented.');

  Future<void> openLocationSettings() => throw UnimplementedError(
    'openLocationSettings() has not been implemented.',
  );

  Future<void> openAppSettings() =>
      throw UnimplementedError('openAppSettings() has not been implemented.');
}
