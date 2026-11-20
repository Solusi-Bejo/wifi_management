/// Outcome of removing a router from the device's saved Wi-Fi networks.
enum WifiForgetResult {
  /// Removed; the device dropped its own connection to it.
  removed('removed'),

  /// Nothing was saved under that SSID.
  notFound('not_found'),

  /// Android allows this only to the Device Owner app.
  notDeviceOwner('not_device_owner'),

  /// The platform cannot do it at all (iOS, web, desktop).
  unsupported('unsupported'),

  failed('failed');

  const WifiForgetResult(this.code);

  final String code;

  static WifiForgetResult fromCode(String code) => values.firstWhere(
    (result) => result.code == code,
    orElse: () => WifiForgetResult.failed,
  );
}
