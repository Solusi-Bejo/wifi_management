import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_management/wifi_management.dart';
import 'package:wifi_management_example/main.dart';

class _UnsupportedPlatform extends WifiManagementPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<WifiReadiness> checkReadiness() async => WifiReadiness.unsupported;

  @override
  Stream<WifiNetworkEvent> get events => const Stream.empty();
}

void main() {
  testWidgets('shows the unsupported status', (tester) async {
    final wifi = WifiManagement(platform: _UnsupportedPlatform());
    await tester.pumpWidget(ExampleApp(wifi: wifi));
    await tester.pumpAndSettle();

    expect(find.text('Status: unsupported'), findsOneWidget);
  });
}
