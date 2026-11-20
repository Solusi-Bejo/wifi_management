import '../entity/wifi_capabilities.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

class GetWifiCapabilities extends UseCase<Future<WifiCapabilities>, void> {
  const GetWifiCapabilities(this._repository);

  final WifiRepository _repository;

  @override
  Future<WifiCapabilities> call([void _]) => _repository.capabilities();
}
