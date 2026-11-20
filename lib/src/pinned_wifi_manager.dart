import 'dart:async';

import 'package:meta/meta.dart';

import 'pinned_wifi_state.dart';
import 'pinned_wifi_store.dart';
import 'wifi_config.dart';
import 'wifi_connection.dart';
import 'wifi_management.dart';

/// Delay before the [attempt]-th consecutive reconnect: 2, 4, 8, 16 s, then
/// 30 s for every attempt after that.
Duration defaultPinnedWifiRetryDelay(int attempt) => attempt >= 5
    ? const Duration(seconds: 30)
    : Duration(seconds: 1 << (attempt < 1 ? 1 : attempt));

/// Owner of the pinned Wi-Fi link: loads the stored router on [start], joins
/// exactly its SSID + BSSID, reconnects with backoff when the link drops, and
/// resets on request. Create one per app and keep it for the app's lifetime.
///
/// One request at a time: every attempt bumps a generation counter, and an
/// answer that comes back for an older generation is dropped, as is a retry
/// timer armed by one.
class PinnedWifiManager {
  PinnedWifiManager({
    required PinnedWifiStore store,
    WifiManagement? wifi,
    Duration Function(int attempt) retryDelay = defaultPinnedWifiRetryDelay,
  }) : _store = store,
       _wifi = wifi ?? WifiManagement(),
       _retryDelay = retryDelay;

  final PinnedWifiStore _store;
  final WifiManagement _wifi;
  final Duration Function(int attempt) _retryDelay;

  final _states = StreamController<PinnedWifiState>.broadcast();
  PinnedWifiState _state = const PinnedWifiState();
  int _generation = 0;
  Timer? _retryTimer;
  StreamSubscription<WifiNetworkEvent>? _eventSubscription;
  bool _disposed = false;

  PinnedWifiState get state => _state;

  /// Every change of [state].
  Stream<PinnedWifiState> get states => _states.stream;

  bool get isDisposed => _disposed;

  @visibleForTesting
  bool get hasPendingRetry => _retryTimer?.isActive ?? false;

  void _emit(PinnedWifiState next) {
    if (_disposed || next == _state) return;
    _state = next;
    _states.add(next);
  }

  /// Startup: stored router, then exact-BSSID join, then verified.
  Future<void> start() async {
    _eventSubscription ??= _wifi.events.listen(
      _onNetworkEvent,
      onError: (Object _) {},
    );

    WifiReadiness readiness;
    try {
      readiness = await _wifi.checkReadiness();
    } catch (_) {
      readiness = WifiReadiness.unsupported;
    }
    if (_disposed) return;
    if (readiness == WifiReadiness.unsupported) {
      _emit(const PinnedWifiState(phase: PinnedWifiPhase.unsupported));
      return;
    }

    WifiConfig? config;
    try {
      config = await _store.load();
    } catch (_) {
      config = null;
    }
    if (_disposed) return;
    if (config == null) {
      _emit(const PinnedWifiState(phase: PinnedWifiPhase.notConfigured));
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
    _emit(const PinnedWifiState(phase: PinnedWifiPhase.notConfigured));
    await _release();
    try {
      await _store.clear();
    } catch (_) {
      _emit(_state.copyWith(failure: WifiFailure.storageFailed));
    }
  }

  Future<void> _connect(WifiConfig target, {required bool save}) async {
    final generation = ++_generation;
    _retryTimer?.cancel();
    _emit(
      _state.copyWith(
        phase: PinnedWifiPhase.connecting,
        target: target,
        actualBssid: null,
      ),
    );

    WifiConnectResult result;
    try {
      result = await _wifi.connect(target);
    } catch (_) {
      result = const WifiConnectResult.failed(WifiFailure.unknown);
    }
    if (_disposed || generation != _generation) return;

    switch (result) {
      case WifiConnected(:final actualBssid):
        if (save) {
          try {
            await _store.save(target);
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
          PinnedWifiState(
            phase: PinnedWifiPhase.connected,
            config: target,
            actualBssid: actualBssid,
          ),
        );
      case WifiConnectFailed(:final failure):
        if (failure == WifiFailure.unsupported) {
          _emit(const PinnedWifiState(phase: PinnedWifiPhase.unsupported));
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
          phase: PinnedWifiPhase.failed,
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
        phase: PinnedWifiPhase.retrying,
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
    if (_disposed || _state.phase != PinnedWifiPhase.connected) return;
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
      await _wifi.disconnect();
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
