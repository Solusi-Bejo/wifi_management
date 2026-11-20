import 'package:freezed_annotation/freezed_annotation.dart';

import 'wifi_failure.dart';

part 'wifi_network_event.freezed.dart';

enum WifiNetworkEventType {
  connecting,
  connected,
  lost,
  unavailable,
  error;

  static WifiNetworkEventType fromName(String? name) => values.firstWhere(
    (value) => value.name == name,
    orElse: () => WifiNetworkEventType.error,
  );
}

/// A status change of the active network request, pushed by the platform.
@freezed
abstract class WifiNetworkEvent with _$WifiNetworkEvent {
  const factory WifiNetworkEvent({
    required WifiNetworkEventType type,
    String? ssid,

    /// For [WifiNetworkEventType.connected], the BSSID actually joined.
    String? bssid,
    WifiFailure? failure,
  }) = _WifiNetworkEvent;
}
