import 'package:freezed_annotation/freezed_annotation.dart';

part 'wifi_capabilities.freezed.dart';

/// What the current platform can do.
@freezed
abstract class WifiCapabilities with _$WifiCapabilities {
  const factory WifiCapabilities({
    /// Joining a pinned router works at all (Android 10+, iOS).
    required bool supported,

    /// Nearby routers can be listed (Android only).
    required bool canScan,

    /// The OS only joins the requested BSSID (Android). Elsewhere the BSSID is
    /// verified after the join and a mismatch is reported, not prevented.
    required bool canLockBssid,

    /// The app's traffic is bound to the pinned network (Android).
    required bool canBindProcess,
  }) = _WifiCapabilities;

  static const none = WifiCapabilities(
    supported: false,
    canScan: false,
    canLockBssid: false,
    canBindProcess: false,
  );
}
