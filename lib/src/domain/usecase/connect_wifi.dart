import '../entity/wifi_config.dart';
import '../entity/wifi_connect_result.dart';
import '../entity/wifi_failure.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

/// Joins exactly the config's SSID + BSSID. A join that lands on any other
/// BSSID is released and reported as [WifiFailure.bssidMismatch], even when
/// the platform already claimed success.
class ConnectWifi extends UseCase<Future<WifiConnectResult>, WifiConfig> {
  const ConnectWifi(this._repository);

  final WifiRepository _repository;

  @override
  Future<WifiConnectResult> call(WifiConfig params) async {
    final result = await _repository.connect(params);
    if (result case WifiConnected(
      :final actualBssid,
    ) when !params.matchesBssid(actualBssid)) {
      await _repository.disconnect();
      return const WifiConnectResult.failed(WifiFailure.bssidMismatch);
    }
    return result;
  }
}
