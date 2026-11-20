import '../entity/wifi_forget_result.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

/// Removes a router, by SSID, from the device's saved Wi-Fi networks so the
/// device itself stops joining it. Needs Device Owner on Android.
class ForgetSystemWifi extends UseCase<Future<WifiForgetResult>, String> {
  const ForgetSystemWifi(this._repository);

  final WifiRepository _repository;

  @override
  Future<WifiForgetResult> call(String ssid) =>
      _repository.forgetSystemNetwork(ssid);
}
