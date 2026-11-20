import '../entity/wifi_config.dart';
import '../repository/wifi_config_repository.dart';
import 'use_case.dart';

class SaveWifiConfig extends UseCase<Future<void>, WifiConfig> {
  const SaveWifiConfig(this._repository);

  final WifiConfigRepository _repository;

  @override
  Future<void> call(WifiConfig params) => _repository.save(params);
}
