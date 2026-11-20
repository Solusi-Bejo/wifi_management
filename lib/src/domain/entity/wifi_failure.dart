/// Why a scan, a connection, or a stored configuration failed. Each value maps
/// to an action the user can take.
enum WifiFailure {
  /// Not Android 10+ / iOS, or the platform cannot do what was asked.
  unsupported('unsupported'),
  permissionDenied('permission_denied'),
  locationDisabled('location_disabled'),

  /// The platform joined a router, but not the one requested.
  bssidMismatch('bssid_mismatch'),

  /// The router was not found, or the device did not join it in time.
  unavailable('unavailable'),

  /// Android: the user declined this app's Wi-Fi suggestions. Allow them again
  /// under Settings > Apps > Special app access > Wi-Fi control, then retry.
  approvalDenied('approval_denied'),

  /// No answer from the device within the Dart-side deadline.
  timeout('timeout'),
  bindFailed('bind_failed'),
  invalidConfig('invalid_config'),
  scanFailed('scan_failed'),
  storageFailed('storage_failed'),
  unknown('unknown');

  const WifiFailure(this.code);

  /// Wire value used by the host platforms.
  final String code;

  static WifiFailure fromCode(String? code) => values.firstWhere(
    (value) => value.code == code,
    orElse: () => WifiFailure.unknown,
  );
}
