import '../entity/wifi_config.dart';
import '../repository/wifi_config_repository.dart';
import 'use_case.dart';

/// The stored router, or null when none.
class LoadWifiConfig extends UseCase<Future<WifiConfig?>, NoParams> {
  const LoadWifiConfig(this._repository);

  final WifiConfigRepository _repository;

  @override
  Future<WifiConfig?> call(NoParams params) => _repository.load();
}
