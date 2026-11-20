import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_management/src/data/datasource/messages.g.dart';
import 'package:wifi_management/wifi_management.dart';

import '../../fakes.dart';

class _FakeHostApi extends WifiManagementHostApi {
  _FakeHostApi(this.events);

  final StreamController<PlatformNetworkEvent> events;
  final requests = <PlatformConnectRequest>[];
  int disconnects = 0;

  /// Event types pushed for the next [connect], with the joined BSSID.
  List<(String, String?)> answer = [('connected', null)];

  @override
  Future<PlatformCapabilities> capabilities() async => PlatformCapabilities(
    supported: true,
    canScan: true,
    canLockBssid: true,
    canBindProcess: true,
  );

  @override
  Future<PlatformScanResult> scan() async => PlatformScanResult(
    accessPoints: [
      PlatformAccessPoint(
        ssid: 'SSID001',
        bssid: 'AA:BB:CC:00:00:01',
        rssi: -50,
        security: 'wpa2',
      ),
    ],
  );

  @override
  Future<void> connect(PlatformConnectRequest request) async {
    requests.add(request);
    for (final (type, bssid) in answer) {
      scheduleMicrotask(
        () => events.add(
          PlatformNetworkEvent(
            requestId: request.requestId,
            type: type,
            bssid: bssid ?? request.bssid,
            failure: type == 'error' ? 'bind_failed' : null,
          ),
        ),
      );
    }
  }

  @override
  Future<void> disconnect() async => disconnects++;

  String forgetAnswer = 'not_device_owner';

  @override
  Future<String> forgetSystemNetwork(String ssid) async => forgetAnswer;
}

void main() {
  late StreamController<PlatformNetworkEvent> events;
  late _FakeHostApi api;
  late PigeonWifiManagement platform;

  setUp(() {
    events = StreamController<PlatformNetworkEvent>.broadcast();
    api = _FakeHostApi(events);
    platform = PigeonWifiManagement(
      api: api,
      eventSource: () => events.stream,
      isHostSupported: true,
    );
  });

  test('connect completes on the connected event of its request', () async {
    final result = await platform.connect(configFor(routerA));

    expect(result, WifiConnectResult.connected(routerA.bssid));
    expect(api.requests.single.bssid, routerA.bssid);
    expect(api.requests.single.password, 'secret123');
  });

  test('a connected event for another BSSID is a mismatch', () async {
    api.answer = [('connected', routerB.bssid)];

    final result = await platform.connect(configFor(routerA));

    expect(result, const WifiConnectResult.failed(WifiFailure.bssidMismatch));
  });

  test('an error event carries its failure code', () async {
    api.answer = [('error', null)];

    final result = await platform.connect(configFor(routerA));

    expect(result, const WifiConnectResult.failed(WifiFailure.bindFailed));
  });

  test('events of an older request are dropped', () async {
    api.answer = [];
    final first = platform.connect(configFor(routerA));
    await Future<void>.delayed(Duration.zero);
    final staleId = api.requests.single.requestId;

    await platform.disconnect();
    expect(
      await first,
      const WifiConnectResult.failed(WifiFailure.unavailable),
    );

    final seen = <WifiNetworkEvent>[];
    platform.events.listen(seen.add);
    events.add(PlatformNetworkEvent(requestId: staleId, type: 'lost'));
    await Future<void>.delayed(Duration.zero);

    expect(seen, isEmpty);
    expect(api.disconnects, 1);
  });

  test('no answer within the deadline times out and releases', () {
    fakeAsync((async) {
      api.answer = [];
      WifiConnectResult? result;
      platform.connect(configFor(routerA)).then((r) => result = r);

      async.elapse(const Duration(seconds: 75));

      expect(result, const WifiConnectResult.failed(WifiFailure.timeout));
      expect(api.disconnects, 1);
    });
  });

  test('scan lower-cases BSSIDs and maps security', () async {
    final result = await platform.scan();

    expect(result.failure, isNull);
    expect(result.accessPoints.single, routerA);
  });

  test('forgetSystemNetwork maps the host code; unknown codes fail', () async {
    expect(
      await platform.forgetSystemNetwork('SSID001'),
      WifiForgetResult.notDeviceOwner,
    );
    api.forgetAnswer = 'something_new';
    expect(
      await platform.forgetSystemNetwork('SSID001'),
      WifiForgetResult.failed,
    );
  });

  test('an unsupported host never calls the platform', () async {
    final offHost = PigeonWifiManagement(api: api, isHostSupported: false);

    expect(await offHost.capabilities(), WifiCapabilities.none);
    expect(await offHost.checkReadiness(), WifiReadiness.unsupported);
    expect(
      await offHost.connect(configFor(routerA)),
      const WifiConnectResult.failed(WifiFailure.unsupported),
    );
    expect(
      await offHost.forgetSystemNetwork('SSID001'),
      WifiForgetResult.unsupported,
    );
    expect(api.requests, isEmpty);
  });
}
