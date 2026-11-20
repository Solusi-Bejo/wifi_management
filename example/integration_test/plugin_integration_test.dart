import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wifi_management/wifi_management.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the host answers capabilities and readiness', (tester) async {
    final wifi = WifiManagement();
    final capabilities = await wifi.capabilities();
    final readiness = await wifi.checkReadiness();

    // Values depend on the device; the call itself must round-trip.
    expect(capabilities, isA<WifiCapabilities>());
    expect(readiness, isA<WifiReadiness>());
  });
}
