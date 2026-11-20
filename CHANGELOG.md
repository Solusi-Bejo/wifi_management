## 0.3.0

* **Device Owner on Android: the device's own Wi-Fi follows the plugin.**
  `connect` saves the router in the device's Wi-Fi networks with its BSSID
  locked and makes it the only enabled one, so the device itself joins it
  (other apps use it too). Releasing the request disables it; a replaced
  router, a new router that never verified, and `reset()` remove it. Without
  Device Owner nothing changes: the app-scoped `WifiNetworkSpecifier` request
  is used and the saved networks are left alone.
* `WifiManagement.reset()` now also removes the router from the device's saved
  Wi-Fi networks and returns a `WifiForgetResult`. Releasing the app's request
  alone left the device connected whenever the same router was saved in
  Settings, because the device rejoined it by itself.
  * Android allows this only when the app is the **Device Owner**; otherwise
    the result is `WifiForgetResult.notDeviceOwner` and the saved network
    stays. iOS answers `unsupported`.
* New: `ForgetSystemWifi` use case, `WifiRepository.forgetSystemNetwork` and
  `WifiManagementPlatform.forgetSystemNetwork`.
* **Breaking for custom `WifiRepository` implementations** (such as test
  fakes): add `forgetSystemNetwork`.

## 0.2.1

* README: install from pub.dev with `flutter pub add wifi_management`.

## 0.2.0

* **Breaking:** Dart API renamed and split into domain / data / presentation
  layers.
  * `PinnedWifiManager` → `WifiManagement`; `PinnedWifiState` /
    `PinnedWifiPhase` → `WifiManagementState` / `WifiManagementPhase`;
    `defaultPinnedWifiRetryDelay` → `defaultWifiRetryDelay`.
  * `PinnedWifiStore` / `InMemoryPinnedWifiStore` → `WifiConfigRepository` /
    `InMemoryWifiConfigRepository`; the constructor takes `configRepository:`.
  * The old `WifiManagement` facade is replaced by the `WifiRepository` interface
    (`WifiRepositoryImpl` over the host) and one use case per action:
    `GetWifiCapabilities`, `CheckWifiReadiness`, `ScanWifi`, `ConnectWifi`,
    `DisconnectWifi`, `WatchWifiEvents`, `OpenWifiSettings`.
  * `WifiManagementPlatform` / `PigeonWifiManagement` keep their names.
* Package name stays `wifi_management` (`wifi_manager` is taken on pub.dev);
  native plugin classes and channel names are unchanged.

## 0.1.0

* First release.
* Android 10+: scan (one entry per BSSID), join an exact SSID + BSSID with
  `WifiNetworkSpecifier`, verify the joined BSSID, bind the process, report
  link loss.
* iOS 15+: best-effort join by SSID with `NEHotspotConfiguration`, BSSID
  verification after the join, link-loss detection.
* `PinnedWifiManager`: remember a router (pluggable `PinnedWifiStore`),
  reconnect with 2/4/8/16/30 s backoff, reset.
* Supports Flutter 3.41+ on AGP 8 (Kotlin Gradle Plugin) and AGP 9 (built-in
  Kotlin).
