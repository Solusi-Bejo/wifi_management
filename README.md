# wifi_management

Pin a device to **one exact Wi-Fi router**, identified by SSID **and BSSID**.

Fleets often run many routers with the same SSID (one per vehicle, room or
kiosk). The OS only remembers the network name, so a device can silently join
the wrong router next door. `wifi_management` lets the user pick the router by
its BSSID, joins only that one, verifies the BSSID the OS actually joined,
remembers it, and reconnects with backoff when the link drops.

## Platform support

| | Android 10+ (API 29) | iOS 15+ | Android < 10, other platforms |
|---|---|---|---|
| Scan nearby routers (one entry per BSSID) | ✅ | ❌ (no public API) | ❌ |
| Join only the requested BSSID | ✅ `WifiNetworkSpecifier` | ❌ joins by SSID | ❌ |
| Verify the joined BSSID | ✅ | ✅ after the join; mismatch is reported and the configuration removed | ❌ |
| Bind the app's traffic to that network | ✅ `bindProcessToNetwork` | ❌ | ❌ |
| Detect a lost link | ✅ | ✅ (path monitor + polling) | ❌ |

`GetWifiCapabilities(WifiRepositoryImpl())(const NoParams())` reports this at
runtime. Unsupported platforms answer `WifiFailure.unsupported` /
`WifiManagementPhase.unsupported`.

Works with Flutter **3.41 and newer** (Dart 3.11+), on AGP 8 (Kotlin Gradle
Plugin) and AGP 9 (built-in Kotlin) apps.

## Setup

### Android

Nothing to add: the plugin's manifest merges `ACCESS_WIFI_STATE`,
`CHANGE_WIFI_STATE`, `ACCESS_NETWORK_STATE`, `CHANGE_NETWORK_STATE`,
`ACCESS_FINE_LOCATION` and `NEARBY_WIFI_DEVICES` into your app. Location
Services must be on to scan and to read the joined BSSID.

The first join to a router may show a system approval dialog.

### iOS

1. Add the **Hotspot Configuration** and **Access Wi-Fi Information**
   capabilities to the Runner target (Signing & Capabilities).
2. Add `NSLocationWhenInUseUsageDescription` to `Info.plist`; iOS only
   reveals the current SSID/BSSID to apps with location permission.

## Usage

### Remember a router and stay on it

```dart
import 'package:wifi_management/wifi_management.dart';

final manager = WifiManagement(
  configRepository: MyConfigRepository(), // see below
  wifiRepository: WifiRepositoryImpl(),
);

await manager.start(); // reconnects to the stored router, if any
manager.states.listen((state) {
  print('${state.phase} ${state.actualBssid}');
});

// Setup: pick a router from a scan, then
await manager.connectNew(
  WifiConfig(
    ssid: ap.ssid,
    bssid: ap.bssid,
    security: ap.security,
    password: password,
  ),
);

await manager.reset(); // disconnect and forget
```

The router is saved only after its BSSID is verified. A lost link retries
after 2, 4, 8, 16, then every 30 seconds, one attempt at a time.

### Scan and check readiness

Each action is its own use case over a `WifiRepository`:

```dart
final wifi = WifiRepositoryImpl(); // the host platform

final readiness = await CheckWifiReadiness(wifi)(
  const CheckWifiReadinessParams(requestPermission: true),
);
if (readiness == WifiReadiness.locationDisabled) {
  await OpenWifiSettings(wifi)(WifiSettingsTarget.location);
}

// One entry per BSSID, strongest first.
final scan = await ScanWifi(wifi)(const NoParams());
```

Pass the same repository to `WifiManagement(wifiRepository: wifi, ...)`.

### Storing the router

`WifiManagement` takes a `WifiConfigRepository`. Implement it over your app's
storage with `WifiConfig.toJson()` / `WifiConfig.fromJson()`:

```dart
class MyConfigRepository implements WifiConfigRepository {
  @override
  Future<WifiConfig?> load() async { /* read + WifiConfig.fromJson */ }
  @override
  Future<void> save(WifiConfig config) async { /* write config.toJson() */ }
  @override
  Future<void> clear() async { /* delete */ }
}
```

> The JSON contains the Wi-Fi **password**. Prefer encrypted storage.
> `InMemoryWifiConfigRepository` is for tests and demos.

## Things to know

- **Android process binding.** While connected, the whole app's traffic goes
  through the pinned network. If that router has no internet, cloud calls fail.
- **Android request without internet capability.** The request drops
  `NET_CAPABILITY_INTERNET` so the specifier matches before validation; the
  binding still uses whatever the router provides.
- **One request at a time.** Every `connect` releases the previous request.
- **iOS is best effort.** iOS can still pick another router with the same SSID;
  the plugin detects and reports it (`WifiFailure.bssidMismatch`) and retries,
  but cannot prevent it.

## Testing your app

Replace the platform with a fake:

```dart
class FakeWifi extends WifiManagementPlatform with MockPlatformInterfaceMixin {
  // override capabilities, checkReadiness, scan, connect, events, ...
}

final manager = WifiManagement(
  configRepository: InMemoryWifiConfigRepository(),
  wifiRepository: WifiRepositoryImpl(platform: FakeWifi()),
);
```

Or implement `WifiRepository` directly, or build the use cases yourself
and pass them to `WifiManagement.withUseCases(...)`.

## Code layout

```
lib/wifi_management.dart        public barrel
lib/src/domain/                 entities, repository interfaces, use cases
lib/src/data/                   platform interface, Pigeon datasource,
                                mappers, repository implementations
lib/src/presentation/manager/   WifiManagement + WifiManagementState
```
