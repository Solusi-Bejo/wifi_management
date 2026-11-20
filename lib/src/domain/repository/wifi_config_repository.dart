import '../entity/wifi_config.dart';

/// Where `WifiManager` keeps the pinned router. Implement it over your app's
/// storage; [WifiConfig.toJson]/[WifiConfig.fromJson] give the shape.
///
/// The config contains the Wi-Fi password: prefer encrypted storage.
abstract interface class WifiConfigRepository {
  /// The stored router, or null when none (or the entry is unreadable).
  Future<WifiConfig?> load();

  Future<void> save(WifiConfig config);

  Future<void> clear();
}
