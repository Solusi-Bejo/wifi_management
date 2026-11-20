import '../repository/wifi_config_repository.dart';
import 'use_case.dart';

class ClearWifiConfig extends UseCase<Future<void>, NoParams> {
  const ClearWifiConfig(this._repository);

  final WifiConfigRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.clear();
}
