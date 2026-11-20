import '../entity/wifi_scan_result.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

/// One entry per BSSID, strongest signal first. Routers that share an SSID
/// stay separate entries.
class ScanWifi extends UseCase<Future<WifiScanResult>, void> {
  const ScanWifi(this._repository);

  final WifiRepository _repository;

  @override
  Future<WifiScanResult> call([void _]) async {
    final result = await _repository.scan();
    final byBssid = {for (final ap in result.accessPoints) ap.bssid: ap};
    final sorted = byBssid.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    return (accessPoints: sorted, failure: result.failure);
  }
}
