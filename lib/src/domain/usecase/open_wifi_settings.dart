import '../entity/wifi_readiness.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

/// Opens the system screen that fixes a [WifiReadiness] problem.
class OpenWifiSettings extends UseCase<Future<void>, WifiSettingsTarget> {
  const OpenWifiSettings(this._repository);

  final WifiRepository _repository;

  @override
  Future<void> call(WifiSettingsTarget params) =>
      _repository.openSettings(params);
}
