import '../../domain/entity/wifi_capabilities.dart';
import '../../domain/entity/wifi_config.dart';
import '../../domain/entity/wifi_connect_result.dart';
import '../../domain/entity/wifi_network_event.dart';
import '../../domain/entity/wifi_readiness.dart';
import '../../domain/entity/wifi_scan_result.dart';
import '../../domain/repository/wifi_repository.dart';
import '../datasource/wifi_manager_platform.dart';

/// [WifiRepository] over the host platform.
class WifiRepositoryImpl implements WifiRepository {
  WifiRepositoryImpl({WifiManagerPlatform? platform})
    : _platform = platform ?? WifiManagerPlatform.instance;

  final WifiManagerPlatform _platform;

  @override
  Future<WifiCapabilities> capabilities() => _platform.capabilities();

  @override
  Future<WifiReadiness> checkReadiness() => _platform.checkReadiness();

  @override
  Future<bool> requestPermissions() => _platform.requestPermissions();

  @override
  Future<WifiScanResult> scan() => _platform.scan();

  @override
  Future<WifiConnectResult> connect(WifiConfig config) =>
      _platform.connect(config);

  @override
  Future<void> disconnect() => _platform.disconnect();

  @override
  Stream<WifiNetworkEvent> get events => _platform.events;

  @override
  Future<void> openSettings(WifiSettingsTarget target) => switch (target) {
    WifiSettingsTarget.location => _platform.openLocationSettings(),
    WifiSettingsTarget.app => _platform.openAppSettings(),
  };
}
