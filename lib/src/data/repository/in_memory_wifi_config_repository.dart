import '../../domain/entity/wifi_config.dart';
import '../../domain/repository/wifi_config_repository.dart';

/// Keeps the router in memory only (tests, demos).
class InMemoryWifiConfigRepository implements WifiConfigRepository {
  InMemoryWifiConfigRepository([this._config]);

  WifiConfig? _config;

  @override
  Future<WifiConfig?> load() async => _config;

  @override
  Future<void> save(WifiConfig config) async => _config = config;

  @override
  Future<void> clear() async => _config = null;
}
