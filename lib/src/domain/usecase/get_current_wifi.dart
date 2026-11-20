import '../entity/wifi_access_point.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

/// The Wi-Fi the device itself is on now (not necessarily the pinned router),
/// or null when on none.
class GetCurrentWifi extends UseCase<Future<WifiAccessPoint?>, void> {
  const GetCurrentWifi(this._repository);

  final WifiRepository _repository;

  @override
  Future<WifiAccessPoint?> call([void _]) => _repository.currentNetwork();
}
