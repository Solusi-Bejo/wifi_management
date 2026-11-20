import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/wifi_config.dart';
import '../../domain/entity/wifi_failure.dart';

part 'wifi_manager_state.freezed.dart';

enum WifiManagerPhase {
  /// `start()` has not finished reading the stored router yet.
  initial,

  /// The platform cannot pin (not Android 10+ / iOS).
  unsupported,
  notConfigured,
  connecting,

  /// Joined and BSSID verified (and, on Android, the process is bound).
  connected,

  /// Waiting [WifiManagerState.retryDelay] before the next attempt.
  retrying,

  /// A new-router attempt failed and there is no stored router to fall back
  /// to.
  failed,
}

@freezed
abstract class WifiManagerState with _$WifiManagerState {
  const WifiManagerState._();

  const factory WifiManagerState({
    @Default(WifiManagerPhase.initial) WifiManagerPhase phase,

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
  }) = _WifiManagerState;

  /// Connected to exactly the stored SSID + BSSID.
  bool get isVerified =>
      phase == WifiManagerPhase.connected &&
      (config?.matchesBssid(actualBssid) ?? false);
}
