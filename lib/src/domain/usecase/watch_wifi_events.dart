import '../entity/wifi_network_event.dart';
import '../repository/wifi_repository.dart';
import 'use_case.dart';

/// Status changes of the latest connect request, notably
/// [WifiNetworkEventType.lost] after it was connected.
class WatchWifiEvents extends UseCase<Stream<WifiNetworkEvent>, NoParams> {
  const WatchWifiEvents(this._repository);

  final WifiRepository _repository;

  @override
  Stream<WifiNetworkEvent> call(NoParams params) => _repository.events;
}
