// `package:flutter/material.dart` is deprecated from Flutter 3.47 in favour of
// `material_ui`, but it keeps this example running on Flutter 3.41 too.
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:wifi_management/wifi_management.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key, this.wifiRepository, this.configRepository});

  /// Injected by tests; defaults to the real plugin.
  final WifiRepository? wifiRepository;
  final WifiConfigRepository? configRepository;

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late final WifiRepository _wifi =
      widget.wifiRepository ?? WifiRepositoryImpl();
  late final _checkReadiness = CheckWifiReadiness(_wifi);
  late final _scanWifi = ScanWifi(_wifi);

  // A real app stores the router somewhere persistent (and encrypted).
  late final WifiManagement _manager = WifiManagement(
    configRepository: widget.configRepository ?? InMemoryWifiConfigRepository(),
    wifiRepository: _wifi,
  );

  List<WifiAccessPoint> _accessPoints = const [];
  String? _scanMessage;

  @override
  void initState() {
    super.initState();
    _manager.start();
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final readiness = await _checkReadiness(
      const CheckWifiReadinessParams(requestPermission: true),
    );
    if (readiness != WifiReadiness.ready) {
      setState(() => _scanMessage = 'Not ready: ${readiness.name}');
      return;
    }
    final result = await _scanWifi();
    setState(() {
      _accessPoints = result.accessPoints;
      _scanMessage = result.failure == null
          ? null
          : 'Scan failed: ${result.failure!.code}';
    });
  }

  Future<void> _pick(BuildContext context, WifiAccessPoint ap) async {
    var password = '';
    if (ap.security.needsPassword) {
      final entered = await showDialog<String>(
        context: context,
        builder: (context) => _PasswordDialog(ssid: ap.ssid),
      );
      if (entered == null) return;
      password = entered;
    }
    await _manager.connectNew(
      WifiConfig(
        ssid: ap.ssid,
        bssid: ap.bssid,
        security: ap.security,
        password: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('wifi_management'),
          actions: [
            IconButton(
              tooltip: 'Reset',
              onPressed: _manager.reset,
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _scan,
          icon: const Icon(Icons.wifi_find),
          label: const Text('Scan'),
        ),
        body: StreamBuilder<WifiManagementState>(
          stream: _manager.states,
          initialData: _manager.state,
          builder: (context, snapshot) {
            final state = snapshot.data!;
            return ListView(
              children: [
                ListTile(
                  key: const Key('status'),
                  title: Text('Status: ${state.phase.name}'),
                  subtitle: Text(
                    [
                      if (state.config case final config?)
                        'Pinned: ${config.ssid} ${config.bssid}',
                      if (state.actualBssid case final bssid?) 'Joined: $bssid',
                      if (state.failure case final failure?)
                        'Last failure: ${failure.code}',
                    ].join('\n'),
                  ),
                ),
                if (_scanMessage case final message?)
                  ListTile(title: Text(message)),
                const Divider(),
                for (final ap in _accessPoints)
                  ListTile(
                    key: ValueKey('ap-${ap.bssid}'),
                    enabled: ap.security.isSupported,
                    title: Text(ap.ssid.isEmpty ? '(hidden)' : ap.ssid),
                    subtitle: Text(
                      '${ap.bssid} · ${ap.rssi} dBm · ${ap.security.code}',
                    ),
                    onTap: () => _pick(context, ap),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.ssid});

  final String ssid;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ssid),
      content: TextField(
        key: const Key('password'),
        controller: _controller,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
