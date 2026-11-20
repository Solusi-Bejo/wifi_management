import '../repository/wifi_config_repository.dart';
import 'use_case.dart';

class ClearWifiConfig extends UseCase<Future<void>, void> {
  const ClearWifiConfig(this._repository);

  final WifiConfigRepository _repository;

  @override
  Future<void> call([void _]) => _repository.clear();
}
