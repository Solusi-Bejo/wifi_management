import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_management/wifi_management.dart';

import '../../fakes.dart';

void main() {
  late FakeWifiPlatform platform;
  late FakeWifiConfigRepository store;

  setUp(() {
    platform = FakeWifiPlatform();
    store = FakeWifiConfigRepository();
  });

  const lost = WifiNetworkEvent(type: WifiNetworkEventType.lost);

  test('backoff is 2, 4, 8, 16, then 30 s', () {
    expect([
      for (var attempt = 1; attempt <= 7; attempt++)
        defaultWifiRetryDelay(attempt),
    ], [2, 4, 8, 16, 30, 30, 30].map((s) => Duration(seconds: s)));
  });

  group('startup', () {
    test('no stored router: not configured, nothing requested', () async {
      final manager = buildManager(platform, store);
      await manager.start();

      expect(manager.state.phase, WifiManagementPhase.notConfigured);
      expect(platform.connectCalls, isEmpty);
      await manager.dispose();
    });

    test('unsupported platform: nothing requested', () async {
      platform.readiness = WifiReadiness.unsupported;
      store.stored = configFor(routerA);
      final manager = buildManager(platform, store);
      await manager.start();

      expect(manager.state.phase, WifiManagementPhase.unsupported);
      expect(platform.connectCalls, isEmpty);
      await manager.dispose();
    });

    test('joins exactly the stored SSID + BSSID and verifies it', () async {
      store.stored = configFor(routerB);
      final manager = buildManager(platform, store);
      await manager.start();

      expect(platform.connectCalls.single, configFor(routerB));
      expect(manager.state.phase, WifiManagementPhase.connected);
      expect(manager.state.actualBssid, routerB.bssid);
      expect(manager.state.isVerified, isTrue);
      await manager.dispose();
    });
  });

  group('new router', () {
    test('is stored only after its BSSID is verified', () async {
      final manager = buildManager(platform, store);
      await manager.start();
      await manager.connectNew(configFor(routerB));

      expect(platform.connectCalls.single.bssid, routerB.bssid);
      expect(store.stored, configFor(routerB));
      expect(manager.state.isVerified, isTrue);
      await manager.dispose();
    });

    test('a join on another BSSID is released and never stored', () async {
      platform.connectResults.add(WifiConnectResult.connected(routerA.bssid));
      final manager = buildManager(platform, store);
      await manager.start();
      await manager.connectNew(configFor(routerB));

      expect(store.saveCalls, 0);
      expect(platform.disconnectCalls, greaterThan(0));
      expect(manager.state.phase, WifiManagementPhase.failed);
      expect(manager.state.failure, WifiFailure.bssidMismatch);
      expect(manager.state.isVerified, isFalse);
      await manager.dispose();
    });

    test('a storage failure leaves nothing verified', () async {
      store.failSave = true;
      final manager = buildManager(platform, store);
      await manager.start();
      await manager.connectNew(configFor(routerB));

      expect(store.stored, isNull);
      expect(manager.state.failure, WifiFailure.storageFailed);
      expect(manager.state.isVerified, isFalse);
      await manager.dispose();
    });
  });

  test('every state change is streamed', () async {
    store.stored = configFor(routerA);
    final manager = buildManager(platform, store);
    final phases = <WifiManagementPhase>[];
    manager.states.listen((state) => phases.add(state.phase));

    await manager.start();
    await Future<void>.delayed(Duration.zero);

    expect(phases, [
      WifiManagementPhase.initial, // config loaded, not yet joined
      WifiManagementPhase.connecting,
      WifiManagementPhase.connected,
    ]);
    await manager.dispose();
  });

  test('a lost link retries with backoff, one attempt at a time', () {
    fakeAsync((async) {
      store.stored = configFor(routerA);
      final manager = buildManager(platform, store)..start();
      async.flushMicrotasks();
      expect(manager.state.isVerified, isTrue);

      platform.connectResults.addAll(
        List.filled(6, const WifiConnectResult.failed(WifiFailure.unavailable)),
      );
      platform.emit(lost);
      async.flushMicrotasks();
      expect(manager.state.phase, WifiManagementPhase.retrying);
      expect(manager.state.isVerified, isFalse);
      expect(platform.disconnectCalls, 1);

      var calls = platform.connectCalls.length;
      for (final seconds in [2, 4, 8, 16, 30, 30]) {
        expect(manager.state.retryDelay, Duration(seconds: seconds));
        async.elapse(Duration(seconds: seconds, milliseconds: -1));
        expect(platform.connectCalls, hasLength(calls), reason: '<${seconds}s');
        async.elapse(const Duration(milliseconds: 1));
        expect(
          platform.connectCalls,
          hasLength(++calls),
          reason: '${seconds}s',
        );
      }

      // The next attempt (after another 30 s) succeeds.
      async.elapse(const Duration(seconds: 30));
      expect(manager.state.isVerified, isTrue);
      expect(manager.state.retryAttempt, 0);
      expect(manager.hasPendingRetry, isFalse);

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('reset cancels the retry, releases and forgets the router', () {
    fakeAsync((async) {
      store.stored = configFor(routerA);
      final manager = buildManager(platform, store)..start();
      async.flushMicrotasks();
      platform.connectResults.add(
        const WifiConnectResult.failed(WifiFailure.unavailable),
      );
      platform.emit(lost);
      async.flushMicrotasks();
      expect(manager.hasPendingRetry, isTrue);

      manager.reset();
      async.flushMicrotasks();

      expect(manager.hasPendingRetry, isFalse);
      expect(manager.state.phase, WifiManagementPhase.notConfigured);
      expect(manager.state.config, isNull);
      expect(store.stored, isNull);
      expect(platform.disconnectCalls, 2);

      final calls = platform.connectCalls.length;
      async.elapse(const Duration(minutes: 5));
      expect(platform.connectCalls, hasLength(calls));

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('dispose cancels a pending retry', () {
    fakeAsync((async) {
      store.stored = configFor(routerA);
      final manager = buildManager(platform, store)..start();
      async.flushMicrotasks();
      platform.emit(lost);
      async.flushMicrotasks();
      expect(manager.hasPendingRetry, isTrue);

      manager.dispose();
      async.flushMicrotasks();
      final calls = platform.connectCalls.length;
      async.elapse(const Duration(minutes: 5));

      expect(manager.hasPendingRetry, isFalse);
      expect(platform.connectCalls, hasLength(calls));
    });
  });
}
