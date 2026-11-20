import 'dart:async';

import 'package:meta/meta.dart';

import '../../domain/entity/wifi_config.dart';
import '../../domain/entity/wifi_connect_result.dart';
import '../../domain/entity/wifi_failure.dart';
import '../../domain/entity/wifi_forget_result.dart';
import '../../domain/entity/wifi_network_event.dart';
import '../../domain/entity/wifi_readiness.dart';
import '../../domain/repository/wifi_config_repository.dart';
import '../../domain/repository/wifi_repository.dart';
import '../../domain/usecase/check_wifi_readiness.dart';
import '../../domain/usecase/clear_wifi_config.dart';
import '../../domain/usecase/connect_wifi.dart';
import '../../domain/usecase/disconnect_wifi.dart';
import '../../domain/usecase/forget_system_wifi.dart';
import '../../domain/usecase/load_wifi_config.dart';
import '../../domain/usecase/save_wifi_config.dart';
import '../../domain/usecase/watch_wifi_events.dart';
import 'wifi_management_state.dart';
import 'wifi_retry_delay.dart';

/// Owner of the pinned Wi-Fi link: loads the stored router on [start], joins
/// exactly its SSID + BSSID, reconnects with backoff when the link drops, and
/// resets on request. Create one per app and keep it for the app's lifetime.
///
/// Scanning, capabilities and settings are separate use cases (`ScanWifi`,
/// `GetWifiCapabilities`, `OpenWifiSettings`) over the same [WifiRepository].
///
/// With a [ForgetSystemWifi] (the default factory wires one) the device's own
/// saved Wi-Fi networks follow along: a replaced router, a new router that
/// never verified, and the router dropped by [reset] are removed from them.
/// On Android this takes effect only when the app is the Device Owner, whose
/// joins also go through the saved networks (see the plugin README).
///
/// One request at a time: every attempt bumps a generation counter, and an
/// answer that comes back for an older generation is dropped, as is a retry
/// timer armed by one.
class WifiManagement {
  /// Wires the use cases over [configRepository] and [wifiRepository]
  /// (`WifiRepositoryImpl()` for the host platform).
  factory WifiManagement({
    required WifiConfigRepository configRepository,
    required WifiRepository wifiRepository,
    Duration Function(int attempt) retryDelay = defaultWifiRetryDelay,
  }) {
    return WifiManagement.withUseCases(
      checkReadiness: CheckWifiReadiness(wifiRepository),
      connectWifi: ConnectWifi(wifiRepository),
      disconnectWifi: DisconnectWifi(wifiRepository),
      forgetSystemWifi: ForgetSystemWifi(wifiRepository),
      watchWifiEvents: WatchWifiEvents(wifiRepository),
      loadWifiConfig: LoadWifiConfig(configRepository),
      saveWifiConfig: SaveWifiConfig(configRepository),
      clearWifiConfig: ClearWifiConfig(configRepository),
      retryDelay: retryDelay,
    );
  }

  /// For apps that build the use cases themselves (e.g. through their DI).
  WifiManagement.withUseCases({
    required CheckWifiReadiness checkReadiness,
    required ConnectWifi connectWifi,
    required DisconnectWifi disconnectWifi,
    required WatchWifiEvents watchWifiEvents,
    required LoadWifiConfig loadWifiConfig,
    required SaveWifiConfig saveWifiConfig,
    required ClearWifiConfig clearWifiConfig,
    // Optional so existing wiring keeps compiling; without it [reset] only
    // releases the app's own request.
    ForgetSystemWifi? forgetSystemWifi,
    Duration Function(int attempt) retryDelay = defaultWifiRetryDelay,
  }) : _checkReadiness = checkReadiness,
       _connectWifi = connectWifi,
       _disconnectWifi = disconnectWifi,
       _watchWifiEvents = watchWifiEvents,
       _loadWifiConfig = loadWifiConfig,
       _saveWifiConfig = saveWifiConfig,
       _clearWifiConfig = clearWifiConfig,
       _forgetSystemWifi = forgetSystemWifi,
       _retryDelay = retryDelay;

  final CheckWifiReadiness _checkReadiness;
  final ConnectWifi _connectWifi;
  final DisconnectWifi _disconnectWifi;
  final WatchWifiEvents _watchWifiEvents;
  final LoadWifiConfig _loadWifiConfig;
  final SaveWifiConfig _saveWifiConfig;
  final ClearWifiConfig _clearWifiConfig;
  final ForgetSystemWifi? _forgetSystemWifi;
  final Duration Function(int attempt) _retryDelay;

  final _states = StreamController<WifiManagementState>.broadcast();
  WifiManagementState _state = const WifiManagementState();
  int _generation = 0;
  Timer? _retryTimer;
  StreamSubscription<WifiNetworkEvent>? _eventSubscription;
  bool _disposed = false;

  WifiManagementState get state => _state;

  /// Every change of [state].
  Stream<WifiManagementState> get states => _states.stream;

  bool get isDisposed => _disposed;

  @visibleForTesting
  bool get hasPendingRetry => _retryTimer?.isActive ?? false;

  void _emit(WifiManagementState next) {
    if (_disposed || next == _state) return;
    _state = next;
    _states.add(next);
  }

  /// Startup: stored router, then exact-BSSID join, then verified.
  Future<void> start() async {
    _eventSubscription ??= _watchWifiEvents().listen(
      _onNetworkEvent,
      onError: (Object _) {},
    );

    WifiReadiness readiness;
    try {
      readiness = await _checkReadiness(
        const CheckWifiReadinessParams(requestPermission: false),
      );
    } catch (_) {
      readiness = WifiReadiness.unsupported;
    }
    if (_disposed) return;
    if (readiness == WifiReadiness.unsupported) {
      _emit(const WifiManagementState(phase: WifiManagementPhase.unsupported));
      return;
    }

    WifiConfig? config;
    try {
      config = await _loadWifiConfig();
    } catch (_) {
      config = null;
    }
    if (_disposed) return;
    if (config == null) {
      _emit(
        const WifiManagementState(phase: WifiManagementPhase.notConfigured),
      );
      return;
    }
    _emit(_state.copyWith(config: config));
    await _connect(config, save: false);
  }

  /// Joins [candidate] and stores it only once its BSSID is verified on the
  /// live connection.
  Future<void> connectNew(WifiConfig candidate) =>
      _connect(candidate, save: true);

  /// Skips the remaining backoff and tries the stored router now.
  Future<void> retryNow() async {
    final config = _state.config;
    if (config != null) await _connect(config, save: false);
  }

  /// Drops the link, forgets the stored router, and returns to "not set up".
  ///
  /// Releasing the app's request is not enough when the same router is also
  /// saved in the device's Wi-Fi settings: the device then rejoins it on its
  /// own. So the router is removed from there too, which Android allows only
  /// to the Device Owner; the result says whether that happened.
  Future<WifiForgetResult> reset() async {
    final ssid = (_state.config ?? _state.target)?.ssid;
    _generation++;
    _retryTimer?.cancel();
    _emit(const WifiManagementState(phase: WifiManagementPhase.notConfigured));
    await _release();
    final forgotten = await _forgetSystemNetwork(ssid);
    try {
      await _clearWifiConfig();
    } catch (_) {
      _emit(_state.copyWith(failure: WifiFailure.storageFailed));
    }
    return forgotten;
  }

  Future<WifiForgetResult> _forgetSystemNetwork(String? ssid) async {
    final forget = _forgetSystemWifi;
    if (forget == null) return WifiForgetResult.unsupported;
    if (ssid == null || ssid.isEmpty) return WifiForgetResult.notFound;
    try {
      return await forget(ssid);
    } catch (_) {
      return WifiForgetResult.failed;
    }
  }

  Future<void> _connect(WifiConfig target, {required bool save}) async {
    final previous = _state.config;
    final generation = ++_generation;
    _retryTimer?.cancel();
    _emit(
      _state.copyWith(
        phase: WifiManagementPhase.connecting,
        target: target,
        actualBssid: null,
      ),
    );

    WifiConnectResult result;
    try {
      result = await _connectWifi(target);
    } catch (_) {
      result = const WifiConnectResult.failed(WifiFailure.unknown);
    }
    if (_disposed || generation != _generation) return;

    switch (result) {
      case WifiConnected(:final actualBssid):
        if (save) {
          try {
            await _saveWifiConfig(target);
          } catch (_) {
            if (_disposed || generation != _generation) return;
            await _release();
            if (previous?.ssid != target.ssid) {
              await _forgetSystemNetwork(target.ssid);
            }
            if (_disposed || generation != _generation) return;
            _fail(WifiFailure.storageFailed);
            return;
          }
          if (_disposed || generation != _generation) return;
          // The device's saved copy of a replaced router would otherwise let
          // it wander back there (same SSID: already overwritten in place).
          if (previous != null && previous.ssid != target.ssid) {
            await _forgetSystemNetwork(previous.ssid);
            if (_disposed || generation != _generation) return;
          }
        }
        _emit(
          WifiManagementState(
            phase: WifiManagementPhase.connected,
            config: target,
            actualBssid: actualBssid,
          ),
        );
      case WifiConnectFailed(:final failure):
        // A new router that never verified must not stay in the device's
        // saved networks, unless it shares the stored router's SSID (that
        // entry is the stored router's, rewritten on the next retry).
        if (save && previous?.ssid != target.ssid) {
          await _forgetSystemNetwork(target.ssid);
          if (_disposed || generation != _generation) return;
        }
        if (failure == WifiFailure.unsupported) {
          _emit(
            const WifiManagementState(phase: WifiManagementPhase.unsupported),
          );
          return;
        }
        _fail(failure);
    }
  }

  /// A stored router is retried with backoff; without one there is nothing to
  /// fall back to, so the failure stays.
  void _fail(WifiFailure failure) {
    if (_state.config == null) {
      _emit(
        _state.copyWith(
          phase: WifiManagementPhase.failed,
          failure: failure,
          target: null,
        ),
      );
      return;
    }
    _scheduleRetry(failure);
  }

  void _scheduleRetry(WifiFailure failure) {
    final attempt = _state.retryAttempt + 1;
    final delay = _retryDelay(attempt);
    final generation = _generation;
    _emit(
      _state.copyWith(
        phase: WifiManagementPhase.retrying,
        failure: failure,
        retryAttempt: attempt,
        retryDelay: delay,
        target: null,
        actualBssid: null,
      ),
    );
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (_disposed || generation != _generation) return;
      final config = _state.config;
      if (config != null) _connect(config, save: false);
    });
  }

  void _onNetworkEvent(WifiNetworkEvent event) {
    if (_disposed || _state.phase != WifiManagementPhase.connected) return;
    switch (event.type) {
      case WifiNetworkEventType.lost:
      case WifiNetworkEventType.unavailable:
      case WifiNetworkEventType.error:
        _onLinkDropped(event.failure ?? WifiFailure.unavailable);
      case WifiNetworkEventType.connecting:
      case WifiNetworkEventType.connected:
        break;
    }
  }

  /// Report the drop first, then release the network, then retry.
  Future<void> _onLinkDropped(WifiFailure failure) async {
    _generation++;
    _scheduleRetry(failure);
    await _release();
  }

  Future<void> _release() async {
    try {
      await _disconnectWifi();
    } catch (_) {
      // Nothing left to release.
    }
  }

  /// Stops retrying and listening. The pinned network itself stays as is;
  /// call [reset] first to drop it.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    _retryTimer?.cancel();
    await _eventSubscription?.cancel();
    await _states.close();
  }
}
