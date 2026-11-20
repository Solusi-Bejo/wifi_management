import 'package:freezed_annotation/freezed_annotation.dart';

import 'wifi_config.dart';
import 'wifi_connection.dart';

part 'pinned_wifi_state.freezed.dart';

enum PinnedWifiPhase {
  /// `start()` has not finished reading the stored router yet.
  initial,

  /// The platform cannot pin (not Android 10+ / iOS).
  unsupported,
  notConfigured,
  connecting,

  /// Joined and BSSID verified (and, on Android, the process is bound).
  connected,

  /// Waiting [PinnedWifiState.retryDelay] before the next attempt.
  retrying,

  /// A new-router attempt failed and there is no stored router to fall back
  /// to.
  failed,
}

@freezed
abstract class PinnedWifiState with _$PinnedWifiState {
  const PinnedWifiState._();

  const factory PinnedWifiState({
    @Default(PinnedWifiPhase.initial) PinnedWifiPhase phase,

    /// Stored (verified) router, if any.
    WifiConfig? config,

    /// Router of the attempt in flight; differs from [config] during setup.
    WifiConfig? target,

    /// BSSID the platform reports for the live connection.
    String? actualBssid,

    /// Last failure; kept while retrying so the user sees why.
    WifiFailure? failure,

    /// Consecutive failed attempts since the last verified connection.
    @Default(0) int retryAttempt,
    Duration? retryDelay,
  }) = _PinnedWifiState;

  /// Connected to exactly the stored SSID + BSSID.
  bool get isVerified =>
      phase == PinnedWifiPhase.connected &&
      (config?.matchesBssid(actualBssid) ?? false);
}
