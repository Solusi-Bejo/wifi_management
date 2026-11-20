import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_management/wifi_management.dart';

/// Two routers broadcasting the same SSID.
const routerA = WifiAccessPoint(
  ssid: 'SSID001',
  bssid: 'aa:bb:cc:00:00:01',
  rssi: -50,
  security: WifiSecurity.wpa2,
);
const routerB = WifiAccessPoint(
  ssid: 'SSID001',
  bssid: 'aa:bb:cc:00:00:02',
  rssi: -60,
  security: WifiSecurity.wpa2,
);

WifiConfig configFor(WifiAccessPoint ap, {String password = 'secret123'}) =>
    WifiConfig(
      ssid: ap.ssid,
      bssid: ap.bssid,
      security: ap.security,
      password: password,
    );

class FakeWifiPlatform extends WifiManagerPlatform
    with MockPlatformInterfaceMixin {
  WifiReadiness readiness = WifiReadiness.ready;
  bool grantOnRequest = true;
  WifiScanResult scanResult = (accessPoints: const [], failure: null);

  /// Answers for the next [connect] calls; when empty, the requested BSSID
  /// connects.
  final connectResults = <WifiConnectResult>[];
  final connectCalls = <WifiConfig>[];
  final openedSettings = <String>[];
  int disconnectCalls = 0;
  int permissionRequests = 0;
  final _events = StreamController<WifiNetworkEvent>.broadcast();

  void emit(WifiNetworkEvent event) => _events.add(event);

  @override
  Future<WifiCapabilities> capabilities() async => WifiCapabilities(
    supported: readiness != WifiReadiness.unsupported,
    canScan: true,
    canLockBssid: true,
    canBindProcess: true,
  );

  @override
  Future<WifiReadiness> checkReadiness() async => readiness;

  @override
  Future<bool> requestPermissions() async {
    permissionRequests++;
    if (grantOnRequest) readiness = WifiReadiness.ready;
    return grantOnRequest;
  }

  @override
  Future<WifiScanResult> scan() async => scanResult;

  @override
  Future<WifiConnectResult> connect(WifiConfig config) async {
    connectCalls.add(config);
    if (connectResults.isNotEmpty) return connectResults.removeAt(0);
    return WifiConnectResult.connected(config.bssid);
  }

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  Stream<WifiNetworkEvent> get events => _events.stream;

  @override
  Future<void> openLocationSettings() async => openedSettings.add('location');

  @override
  Future<void> openAppSettings() async => openedSettings.add('app');
}

class FakeWifiConfigRepository implements WifiConfigRepository {
  FakeWifiConfigRepository([this.stored]);

  WifiConfig? stored;
  bool failSave = false;
  int saveCalls = 0;

  @override
  Future<WifiConfig?> load() async => stored;

  @override
  Future<void> save(WifiConfig config) async {
    saveCalls++;
    if (failSave) throw StateError('storage unavailable');
    stored = config;
  }

  @override
  Future<void> clear() async => stored = null;
}

WifiManager buildManager(
  FakeWifiPlatform platform,
  FakeWifiConfigRepository store,
) => WifiManager(
  configRepository: store,
  wifiRepository: WifiRepositoryImpl(platform: platform),
);
