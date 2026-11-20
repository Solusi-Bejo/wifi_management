import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_management/wifi_management.dart';

import '../../fakes.dart';

void main() {
  late FakeWifiPlatform platform;
  late WifiRepository repository;

  setUp(() {
    platform = FakeWifiPlatform();
    repository = WifiRepositoryImpl(platform: platform);
  });

  test('scan keeps one entry per BSSID, strongest first', () async {
    platform.scanResult = (
      accessPoints: [routerB, routerA, routerB],
      failure: null,
    );

    final result = await ScanWifi(repository)(const NoParams());

    expect(result.accessPoints, [routerA, routerB]);
  });

  group('connect', () {
    test('a join on another BSSID is released as a mismatch', () async {
      platform.connectResults.add(WifiConnectResult.connected(routerA.bssid));

      final result = await ConnectWifi(repository)(configFor(routerB));

      expect(result, const WifiConnectResult.failed(WifiFailure.bssidMismatch));
      expect(platform.disconnectCalls, 1);
    });

    test('a matching BSSID in another case is accepted', () async {
      platform.connectResults.add(
        WifiConnectResult.connected(routerB.bssid.toUpperCase()),
      );

      final result = await ConnectWifi(repository)(configFor(routerB));

      expect(result, isA<WifiConnected>());
      expect(platform.disconnectCalls, 0);
    });
  });

  group('readiness', () {
    late CheckWifiReadiness checkReadiness;

    setUp(() => checkReadiness = CheckWifiReadiness(repository));

    test('asks for permissions only when requested', () async {
      platform.readiness = WifiReadiness.permissionDenied;

      expect(
        await checkReadiness(
          const CheckWifiReadinessParams(requestPermission: false),
        ),
        WifiReadiness.permissionDenied,
      );
      expect(platform.permissionRequests, 0);

      expect(
        await checkReadiness(
          const CheckWifiReadinessParams(requestPermission: true),
        ),
        WifiReadiness.ready,
      );
      expect(platform.permissionRequests, 1);
    });

    test('a refused prompt stays permission denied', () async {
      platform
        ..readiness = WifiReadiness.permissionDenied
        ..grantOnRequest = false;

      expect(
        await checkReadiness(
          const CheckWifiReadinessParams(requestPermission: true),
        ),
        WifiReadiness.permissionDenied,
      );
    });
  });

  test('openSettings routes to the right screen', () async {
    final openSettings = OpenWifiSettings(repository);
    await openSettings(WifiSettingsTarget.location);
    await openSettings(WifiSettingsTarget.app);

    expect(platform.openedSettings, ['location', 'app']);
  });
}
