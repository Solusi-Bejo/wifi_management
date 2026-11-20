import '../repository/wifi_repository.dart';
import 'use_case.dart';

/// Releases the network request (and, on Android, the process binding).
class DisconnectWifi extends UseCase<Future<void>, void> {
  const DisconnectWifi(this._repository);

  final WifiRepository _repository;

  @override
  Future<void> call([void _]) => _repository.disconnect();
}
