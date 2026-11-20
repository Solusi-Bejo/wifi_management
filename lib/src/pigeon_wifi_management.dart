import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'messages.g.dart';
import 'wifi_access_point.dart';
import 'wifi_config.dart';
import 'wifi_connection.dart';
import 'wifi_management_platform.dart';

/// [WifiManagementPlatform] over the Pigeon host API (Android and iOS).
///
/// Every [connect] gets a fresh request id; events of any older request are
/// dropped here, so a late callback of a released request can never be read as
/// the state of the current one.
class PigeonWifiManagement extends WifiManagementPlatform {
  PigeonWifiManagement({
    @visibleForTesting WifiManagementHostApi? api,
    @visibleForTesting Stream<PlatformNetworkEvent> Function()? eventSource,
    @visibleForTesting bool? isHostSupported,
    this.connectTimeout = const Duration(seconds: 75),
  }) : _api = api ?? WifiManagementHostApi(),
       _eventSource = eventSource ?? networkEvents,
       _isHostSupported =
           isHostSupported ??
           (!kIsWeb &&
               (defaultTargetPlatform == TargetPlatform.android ||
                   defaultTargetPlatform == TargetPlatform.iOS));

  final WifiManagementHostApi _api;
  final Stream<PlatformNetworkEvent> Function() _eventSource;
  final bool _isHostSupported;

  /// Dart-side deadline on top of the device's own request timeout.
  final Duration connectTimeout;

  int _requestId = 0;
  String? _expectedBssid;
  Completer<WifiConnectResult>? _pending;
  StreamSubscription<PlatformNetworkEvent>? _subscription;
  final _events = StreamController<WifiNetworkEvent>.broadcast();

  @override
  Stream<WifiNetworkEvent> get events {
    _ensureListening();
    return _events.stream;
  }

  /// One subscription to the event channel for the plugin's lifetime: a
  /// second listener would replace the native sink.
  void _ensureListening() {
    if (_subscription != null || !_isHostSupported) return;
    _subscription = _eventSource().listen(
      _onPlatformEvent,
      onError: (Object _) {},
    );
  }

  void _onPlatformEvent(PlatformNetworkEvent raw) {
    if (raw.requestId != _requestId) return;

    final event = WifiNetworkEvent(
      type: WifiNetworkEventType.fromName(raw.type),
      ssid: raw.ssid,
      bssid: raw.bssid,
      failure: raw.failure == null ? null : WifiFailure.fromCode(raw.failure),
    );

    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      switch (event.type) {
        case WifiNetworkEventType.connecting:
          break;
        case WifiNetworkEventType.connected:
          final actual = event.bssid;
          pending.complete(
            actual != null &&
                    WifiConfig.normalizeBssid(actual) == _expectedBssid
                ? WifiConnectResult.connected(actual)
                : const WifiConnectResult.failed(WifiFailure.bssidMismatch),
          );
        case WifiNetworkEventType.lost:
        case WifiNetworkEventType.unavailable:
          pending.complete(
            const WifiConnectResult.failed(WifiFailure.unavailable),
          );
        case WifiNetworkEventType.error:
          pending.complete(
            WifiConnectResult.failed(event.failure ?? WifiFailure.unknown),
          );
      }
    }
    _events.add(event);
  }

  @override
  Future<WifiCapabilities> capabilities() async {
    if (!_isHostSupported) return WifiCapabilities.none;
    final raw = await _api.capabilities();
    return WifiCapabilities(
      supported: raw.supported,
      canScan: raw.canScan,
      canLockBssid: raw.canLockBssid,
      canBindProcess: raw.canBindProcess,
    );
  }

  @override
  Future<WifiReadiness> checkReadiness() async {
    if (!_isHostSupported) return WifiReadiness.unsupported;
    final raw = await _api.checkReadiness();
    if (!raw.supported) return WifiReadiness.unsupported;
    if (!raw.permissionsGranted) return WifiReadiness.permissionDenied;
    if (!raw.locationEnabled) return WifiReadiness.locationDisabled;
    return WifiReadiness.ready;
  }

  @override
  Future<bool> requestPermissions() async {
    if (!_isHostSupported) return false;
    try {
      return await _api.requestPermissions();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<WifiScanResult> scan() async {
    if (!_isHostSupported) {
      return (
        accessPoints: <WifiAccessPoint>[],
        failure: WifiFailure.unsupported,
      );
    }
    try {
      final raw = await _api.scan();
      final failure = raw.failure;
      return (
        accessPoints: [
          for (final ap in raw.accessPoints)
            WifiAccessPoint(
              ssid: ap.ssid,
              bssid: WifiConfig.normalizeBssid(ap.bssid),
              rssi: ap.rssi,
              security: WifiSecurity.fromCode(ap.security),
            ),
        ],
        failure: failure == null ? null : WifiFailure.fromCode(failure),
      );
    } on PlatformException {
      return (
        accessPoints: <WifiAccessPoint>[],
        failure: WifiFailure.scanFailed,
      );
    }
  }

  @override
  Future<WifiConnectResult> connect(WifiConfig config) async {
    if (!_isHostSupported || !(await capabilities()).supported) {
      return const WifiConnectResult.failed(WifiFailure.unsupported);
    }
    _ensureListening();
    _supersedePending();

    final requestId = ++_requestId;
    _expectedBssid = WifiConfig.normalizeBssid(config.bssid);
    final completer = _pending = Completer<WifiConnectResult>();
    try {
      await _api.connect(
        PlatformConnectRequest(
          requestId: requestId,
          ssid: config.ssid,
          bssid: _expectedBssid!,
          security: config.security.code,
          password: config.password,
        ),
      );
    } on PlatformException {
      if (!completer.isCompleted) {
        completer.complete(const WifiConnectResult.failed(WifiFailure.unknown));
      }
    }

    final result = await completer.future.timeout(
      connectTimeout,
      onTimeout: () async {
        if (requestId == _requestId) await disconnect();
        return const WifiConnectResult.failed(WifiFailure.timeout);
      },
    );
    if (identical(_pending, completer)) _pending = null;
    return result;
  }

  /// Settles a still-waiting [connect]: its request is about to be released.
  void _supersedePending() {
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) {
      pending.complete(const WifiConnectResult.failed(WifiFailure.unavailable));
    }
  }

  @override
  Future<void> disconnect() async {
    // Bumping the id drops every later event of the released request.
    _requestId++;
    _expectedBssid = null;
    _supersedePending();
    if (!_isHostSupported) return;
    await _api.disconnect();
  }

  @override
  Future<void> openLocationSettings() async {
    if (_isHostSupported) await _api.openLocationSettings();
  }

  @override
  Future<void> openAppSettings() async {
    if (_isHostSupported) await _api.openAppSettings();
  }
}
