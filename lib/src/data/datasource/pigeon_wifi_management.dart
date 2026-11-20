import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entity/wifi_access_point.dart';
import '../../domain/entity/wifi_capabilities.dart';
import '../../domain/entity/wifi_config.dart';
import '../../domain/entity/wifi_connect_result.dart';
import '../../domain/entity/wifi_failure.dart';
import '../../domain/entity/wifi_forget_result.dart';
import '../../domain/entity/wifi_network_event.dart';
import '../../domain/entity/wifi_readiness.dart';
import '../../domain/entity/wifi_scan_result.dart';
import '../mapper/platform_mapper.dart';
import 'messages.g.dart';
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

    final event = raw.asEntity;
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      final result = _resultOf(event);
      if (result != null) pending.complete(result);
    }
    _events.add(event);
  }

  /// What [event] settles for the pending [connect]; null while still
  /// connecting.
  WifiConnectResult? _resultOf(WifiNetworkEvent event) => switch (event.type) {
    WifiNetworkEventType.connecting => null,
    WifiNetworkEventType.connected =>
      event.bssid != null &&
              (_expectedBssid == null ||
                  WifiConfig.normalizeBssid(event.bssid!) == _expectedBssid)
          ? WifiConnectResult.connected(event.bssid!)
          : const WifiConnectResult.failed(WifiFailure.bssidMismatch),
    WifiNetworkEventType.lost || WifiNetworkEventType.unavailable =>
      const WifiConnectResult.failed(WifiFailure.unavailable),
    WifiNetworkEventType.error => WifiConnectResult.failed(
      event.failure ?? WifiFailure.unknown,
    ),
  };

  @override
  Future<WifiCapabilities> capabilities() async {
    if (!_isHostSupported) return WifiCapabilities.none;
    return (await _api.capabilities()).asEntity;
  }

  @override
  Future<WifiReadiness> checkReadiness() async {
    if (!_isHostSupported) return WifiReadiness.unsupported;
    return (await _api.checkReadiness()).asEntity;
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
      return (await _api.scan()).asEntity;
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
    final request = config.asRequest(requestId);
    // Empty: no BSSID locked yet, the first one joined is accepted.
    _expectedBssid = request.bssid.isEmpty ? null : request.bssid;
    final completer = _pending = Completer<WifiConnectResult>();
    try {
      await _api.connect(request);
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
  Future<WifiForgetResult> forgetSystemNetwork(String ssid) async {
    if (!_isHostSupported) return WifiForgetResult.unsupported;
    return WifiForgetResult.fromCode(await _api.forgetSystemNetwork(ssid));
  }

  @override
  Future<WifiAccessPoint?> currentNetwork() async {
    if (!_isHostSupported) return null;
    return (await _api.currentNetwork())?.asEntity;
  }

  @override
  Future<void> openWifiSettings() async {
    if (_isHostSupported) await _api.openWifiSettings();
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
