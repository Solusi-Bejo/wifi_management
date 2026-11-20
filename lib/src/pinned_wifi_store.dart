import 'wifi_config.dart';

/// Where `PinnedWifiManager` keeps the pinned router. Implement it over your
/// app's storage; [WifiConfig.toJson]/[WifiConfig.fromJson] give the shape.
///
/// The config contains the Wi-Fi password: prefer encrypted storage.
abstract interface class PinnedWifiStore {
  /// The stored router, or null when none (or the entry is unreadable).
  Future<WifiConfig?> load();

  Future<void> save(WifiConfig config);

  Future<void> clear();
}

/// Keeps the router in memory only (tests, demos).
class InMemoryPinnedWifiStore implements PinnedWifiStore {
  InMemoryPinnedWifiStore([this._config]);

  WifiConfig? _config;

  @override
  Future<WifiConfig?> load() async => _config;

  @override
  Future<void> save(WifiConfig config) async => _config = config;

  @override
  Future<void> clear() async => _config = null;
}
