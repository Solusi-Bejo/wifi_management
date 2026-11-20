import '../entity/wifi_readiness.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

final class CheckWifiReadinessParams {
  const CheckWifiReadinessParams({required this.requestPermission});

  /// Ask for missing permissions before answering.
  final bool requestPermission;
}

/// What blocks a scan or a join, optionally prompting for permissions first.
class CheckWifiReadiness
    extends UseCase<Future<WifiReadiness>, CheckWifiReadinessParams> {
  const CheckWifiReadiness(this._repository);

  final WifiRepository _repository;

  @override
  Future<WifiReadiness> call(CheckWifiReadinessParams params) async {
    final readiness = await _repository.checkReadiness();
    if (readiness != WifiReadiness.permissionDenied ||
        !params.requestPermission) {
      return readiness;
    }
    if (!await _repository.requestPermissions()) {
      return WifiReadiness.permissionDenied;
    }
    return _repository.checkReadiness();
  }
}
