import 'dart:async';

import 'package:meta/meta.dart';

import '../../domain/entity/wifi_config.dart';
import '../../domain/entity/wifi_connect_result.dart';
import '../../domain/entity/wifi_failure.dart';
import '../../domain/entity/wifi_network_event.dart';
import '../../domain/entity/wifi_readiness.dart';
import '../../domain/repository/wifi_config_repository.dart';
import '../../domain/repository/wifi_repository.dart';
import '../../domain/usecase/check_wifi_readiness.dart';
import '../../domain/usecase/clear_wifi_config.dart';
import '../../domain/usecase/connect_wifi.dart';
import '../../domain/usecase/disconnect_wifi.dart';
import '../../domain/usecase/load_wifi_config.dart';
import '../../domain/usecase/save_wifi_config.dart';
import '../../domain/usecase/use_case.dart';
import '../../domain/usecase/watch_wifi_events.dart';
import 'wifi_manager_state.dart';
import 'wifi_retry_delay.dart';

/// Owner of the pinned Wi-Fi link: loads the stored router on [start], joins
/// exactly its SSID + BSSID, reconnects with backoff when the link drops, and
/// resets on request. Create one per app and keep it for the app's lifetime.
///
/// Scanning, capabilities and settings are separate use cases (`ScanWifi`,
/// `GetWifiCapabilities`, `OpenWifiSettings`) over the same [WifiRepository].
///
/// One request at a time: every attempt bumps a generation counter, and an
/// answer that comes back for an older generation is dropped, as is a retry
/// timer armed by one.
class WifiManager {
  /// Wires the use cases over [configRepository] and [wifiRepository]
  /// (`WifiRepositoryImpl()` for the host platform).
  factory WifiManager({
    required WifiConfigRepository configRepository,
    required WifiRepository wifiRepository,
    Duration Function(int attempt) retryDelay = defaultWifiRetryDelay,
  }) {
    return WifiManager.withUseCases(
      checkReadiness: CheckWifiReadiness(wifiRepository),
      connectWifi: ConnectWifi(wifiRepository),
      disconnectWifi: DisconnectWifi(wifiRepository),
      watchWifiEvents: WatchWifiEvents(wifiRepository),
      loadWifiConfig: LoadWifiConfig(configRepository),
      saveWifiConfig: SaveWifiConfig(configRepository),
      clearWifiConfig: ClearWifiConfig(configRepository),
      retryDelay: retryDelay,
    );
  }

  /// For apps that build the use cases themselves (e.g. through their DI).
  WifiManager.withUseCases({
    required CheckWifiReadiness checkReadiness,
    required ConnectWifi connectWifi,
    required DisconnectWifi disconnectWifi,
    required WatchWifiEvents watchWifiEvents,
    required LoadWifiConfig loadWifiConfig,
    required SaveWifiConfig saveWifiConfig,
    required ClearWifiConfig clearWifiConfig,
    Duration Function(int attempt) retryDelay = defaultWifiRetryDelay,
  }) : _checkReadiness = checkReadiness,
       _connectWifi = connectWifi,
       _disconnectWifi = disconnectWifi,
       _watchWifiEvents = watchWifiEvents,
       _loadWifiConfig = loadWifiConfig,
       _saveWifiConfig = saveWifiConfig,
       _clearWifiConfig = clearWifiConfig,
       _retryDelay = retryDelay;

  final CheckWifiReadiness _checkReadiness;
  final ConnectWifi _connectWifi;
  final DisconnectWifi _disconnectWifi;
  final WatchWifiEvents _watchWifiEvents;
  final LoadWifiConfig _loadWifiConfig;
  final SaveWifiConfig _saveWifiConfig;
  final ClearWifiConfig _clearWifiConfig;
  final Duration Function(int attempt) _retryDelay;

  final _states = StreamController<WifiManagerState>.broadcast();
  WifiManagerState _state = const WifiManagerState();
  int _generation = 0;
  Timer? _retryTimer;
  StreamSubscription<WifiNetworkEvent>? _eventSubscription;
  bool _disposed = false;

  WifiManagerState get state => _state;

  /// Every change of [state].
  Stream<WifiManagerState> get states => _states.stream;

  bool get isDisposed => _disposed;

  @visibleForTesting
  bool get hasPendingRetry => _retryTimer?.isActive ?? false;

  void _emit(WifiManagerState next) {
    if (_disposed || next == _state) return;
    _state = next;
    _states.add(next);
  }

  /// Startup: stored router, then exact-BSSID join, then verified.
  Future<void> start() async {
    _eventSubscription ??= _watchWifiEvents(
      const NoParams(),
    ).listen(_onNetworkEvent, onError: (Object _) {});

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
      _emit(const WifiManagerState(phase: WifiManagerPhase.unsupported));
      return;
    }

    WifiConfig? config;
    try {
      config = await _loadWifiConfig(const NoParams());
    } catch (_) {
      config = null;
    }
    if (_disposed) return;
    if (config == null) {
      _emit(const WifiManagerState(phase: WifiManagerPhase.notConfigured));
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
  Future<void> reset() async {
    _generation++;
    _retryTimer?.cancel();
    _emit(const WifiManagerState(phase: WifiManagerPhase.notConfigured));
    await _release();
    try {
      await _clearWifiConfig(const NoParams());
    } catch (_) {
      _emit(_state.copyWith(failure: WifiFailure.storageFailed));
    }
  }

  Future<void> _connect(WifiConfig target, {required bool save}) async {
    final generation = ++_generation;
    _retryTimer?.cancel();
    _emit(
      _state.copyWith(
        phase: WifiManagerPhase.connecting,
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
            if (_disposed || generation != _generation) return;
            _fail(WifiFailure.storageFailed);
            return;
          }
          if (_disposed || generation != _generation) return;
        }
        _emit(
          WifiManagerState(
            phase: WifiManagerPhase.connected,
            config: target,
            actualBssid: actualBssid,
          ),
        );
      case WifiConnectFailed(:final failure):
        if (failure == WifiFailure.unsupported) {
          _emit(const WifiManagerState(phase: WifiManagerPhase.unsupported));
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
          phase: WifiManagerPhase.failed,
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
        phase: WifiManagerPhase.retrying,
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
    if (_disposed || _state.phase != WifiManagerPhase.connected) return;
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
      await _disconnectWifi(const NoParams());
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
