import 'package:freezed_annotation/freezed_annotation.dart';

import 'wifi_failure.dart';

part 'wifi_connect_result.freezed.dart';

/// Outcome of one request for the pinned network.
@freezed
sealed class WifiConnectResult with _$WifiConnectResult {
  /// Joined and the BSSID matched (and, on Android, the process is bound).
  const factory WifiConnectResult.connected(String actualBssid) = WifiConnected;

  const factory WifiConnectResult.failed(WifiFailure failure) =
      WifiConnectFailed;
}
