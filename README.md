# wifi_management

**Join one exact Wi-Fi router, even when ten share its name.**

A Flutter plugin that pins a device to a router by SSID **and BSSID**. On
Android it joins only that router, checks the BSSID it actually joined, keeps
it, and reconnects when the link drops. The router is saved only after that
check passes, so a wrong join never becomes the remembered one.

![Animated illustration. On the left, the headline "Join one exact router, even when ten share its name". On the right, an app log types "await manager.connectNew(router02)", then shows: scan found 3 routers named SSID001, a request for SSID001 at aa:bb:cc:00:00:02 only, joined aa:bb:cc:00:00:02 and the BSSID matches, saved and app traffic bound to this network. A card lands: pinned to SSID001 at :02, phase connected with isVerified true, stored only after the BSSID check passed, and if the link is lost it retries after 2, 4, 8, 16, then 30 seconds. Footnote: illustration of a typical Android setup, on iOS the join is best effort.](docs/hero.gif)

## Sound familiar?

- Several routers broadcast the same SSID, and the device joins whichever one
  is loudest.
- The device ends up on a nearby router instead of the one it belongs to.
- The OS says "connected". Nothing tells you it's the wrong BSSID.
- The link drops, and someone has to pick the network in Settings again.

## Who it's for

**For you if** your Flutter app must stay on one specific router while other
routers nearby broadcast the same SSID.

**Not for you if:**

- any Wi-Fi with internet will do. The OS already handles that.
- you need a guarantee on iOS. iOS joins by SSID; the plugin detects and
  reports a wrong BSSID there but can't prevent it.
- your app needs the internet while pinned to a router that has none. On
  Android the whole app's traffic goes through the pinned network.
- you target Android 9 or older.

![Animated illustration, before and after. Before: six cards pile up. Several routers broadcast SSID001 and the device joins whichever is loudest. The device ends up on a nearby router, not the one it belongs to. The OS says connected and nothing says it is the wrong BSSID. The link drops and nothing reconnects it. Someone has to pick the network in Settings again. After a reboot the device only remembers the name. A wipe turns the label to After: an app log runs "await manager.start()", loads SSID001 at aa:bb:cc:00:00:02, requests that BSSID only, joins and verifies it, and ends on connected, isVerified true. Five outcomes appear: pick the router by BSSID from a scan, Android joins only that BSSID, every join is checked and a mismatch is released, the router is saved after the check and restored by start, and a lost link retries at 2, 4, 8, 16, then 30 seconds.](docs/before-after.gif)

## How it works

![Animated diagram of four steps, left to right. 1, scan: ScanWifi on Android, one row per BSSID, strongest signal first. 2, join one BSSID: connectNew with the config, Android uses WifiNetworkSpecifier, iOS joins by SSID. 3, highlighted, verify and save: read the BSSID actually joined, on a mismatch release it and report, on a match save the router. 4, stay on it: app traffic bound to the network on Android, a lost link retries from 2 to 30 seconds, start restores it on the next launch. Below, a loop line: link dropped? WifiManagement retries the stored router, one attempt at a time, until it verifies again.](docs/how-it-works.gif)

1. **Scan** (Android). `ScanWifi` returns one row per BSSID, strongest first,
   so routers that share an SSID stay separate.
2. **Join one BSSID.** `connectNew(config)` asks Android for exactly that
   SSID + BSSID with `WifiNetworkSpecifier`. iOS joins by SSID with
   `NEHotspotConfiguration`.
3. **Verify and save.** The plugin reads the BSSID the device actually joined.
   A mismatch is released and reported as `WifiFailure.bssidMismatch`; a match
   is saved through your `WifiConfigRepository`.
4. **Stay on it.** On Android the app's traffic is bound to that network. A
   lost link retries after 2, 4, 8, 16, then every 30 seconds, one attempt at a
   time. On the next launch, `start()` reconnects to the stored router.

## Quick start

Add the dependency:

```
flutter pub add wifi_management
```

Do the [platform setup](#setup), then:

```dart
import 'package:wifi_management/wifi_management.dart';

final manager = WifiManagement(
  configRepository: InMemoryWifiConfigRepository(), // use real storage in production
  wifiRepository: WifiRepositoryImpl(),
);

await manager.start();
manager.states.listen((state) => print('${state.phase} ${state.isVerified}'));
```

The `example/` app scans, lets you pick a router, and shows the live state.

## Platform support

| | Android 10+ (API 29) | iOS 15+ | Android < 10, other platforms |
|---|---|---|---|
| Scan nearby routers (one entry per BSSID) | ✅ | ❌ (no public API) | ❌ |
| Join only the requested BSSID | ✅ `WifiNetworkSpecifier` | ❌ joins by SSID | ❌ |
| Verify the joined BSSID | ✅ | ✅ after the join; mismatch is reported and the configuration removed | ❌ |
| Bind the app's traffic to that network | ✅ `bindProcessToNetwork` | ❌ | ❌ |
| Detect a lost link | ✅ | ✅ (path monitor + polling) | ❌ |
| Device's own Wi-Fi follows connect / disconnect / reset (saved network, BSSID locked) | ✅ Device Owner only | ❌ | ❌ |

`GetWifiCapabilities(WifiRepositoryImpl())()` reports this at
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

**Device Owner (optional).** A regular app joins through an app-scoped
`WifiNetworkSpecifier` request: only the app uses the router, and the
device's saved Wi-Fi networks are never touched, so a router the user saved in
Settings keeps the device on it after `reset()`. Since Android 10 only a
Device Owner (or system) app may edit saved networks. As Device Owner the
plugin instead:

| Action | Device's saved Wi-Fi networks |
|---|---|
| `connect` / retry | router saved with its BSSID locked, enabled alone; the device joins it |
| link lost, retry pending | disabled until the next attempt |
| new router with another SSID verified | old router removed |
| new router never verified | removed again (unless it shares the stored router's SSID) |
| `reset()` | removed; the device leaves it |

To get there:

1. Register the plugin's admin receiver in your app's
   `android/app/src/main/AndroidManifest.xml`, inside `<application>`. The
   plugin does not declare it itself, so apps that skip this never appear as a
   device admin.

   ```xml
   <receiver
       android:name="com.solusibejo.wifi_management.WifiManagementDeviceAdminReceiver"
       android:exported="true"
       android:permission="android.permission.BIND_DEVICE_ADMIN">
       <meta-data
           android:name="android.app.device_admin"
           android:resource="@xml/wifi_management_device_admin"/>
       <intent-filter>
           <action android:name="android.app.action.DEVICE_ADMIN_ENABLED"/>
       </intent-filter>
   </receiver>
   ```

2. On a device without accounts (fresh or factory reset), install the app and
   run

   ```sh
   adb shell dpm set-device-owner <applicationId>/com.solusibejo.wifi_management.WifiManagementDeviceAdminReceiver
   ```

Without it `reset()` returns `WifiForgetResult.notDeviceOwner`; tell the user
to forget the network in Settings. A Device Owner app cannot be uninstalled
normally: it takes a factory reset or `DevicePolicyManager.clearDeviceOwnerApp`.

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

// Disconnect and forget; on Android the Device Owner also removes the
// router from the device's saved networks.
final forgotten = await manager.reset();
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
final scan = await ScanWifi(wifi)();
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
- **Already on the router.** When the device's own Wi-Fi is already on the
  requested SSID + BSSID, the plugin binds to that connection instead of
  making a specifier request. On single-radio devices such a request would
  drop the device's connection (and its internet) to rejoin the same router
  for the app only.
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
