## 0.4.0

* **Breaking (Android, regular app): joins through a network suggestion, not
  `WifiNetworkSpecifier`.** Android makes a specifier network local-only (no
  internet capability, route or DNS), so an app that set up Wi-Fi this way
  could reach neither the internet nor its API, and the device lost its own
  connection meanwhile. The router is now this app's only
  `WifiNetworkSuggestion`, locked to its BSSID: the device itself joins it,
  with internet for every app, after a one-time approval dialog.
  `forgetSystemNetwork` / `reset()` remove the suggestion and the device
  disconnects, without Device Owner. The specifier path is kept in comments.
* First join after the approval dialog no longer stalls until the deadline:
  Android weighs a suggestion only at its next network selection, which on a
  disconnected device can be minutes away. The plugin now re-adds the
  suggestion as soon as the user approves (API 31+, which makes Android join
  at once and restarts the 60 s deadline) and asks for a scan every 15 s while
  waiting (all API levels).
* `WifiManagementState` drops the previous attempt's `failure` when a new
  attempt starts, so "connecting" never shows a stale error.
* When the device is already on exactly the requested SSID + BSSID, `connect`
  uses that connection (verify, bind, watch for loss) and changes nothing.
* **Breaking:** new `WifiFailure.approvalDenied` (`approval_denied`): the user
  declined the app's Wi-Fi suggestions. Exhaustive `switch`es need the case.
* **Breaking:** `WifiManagementDeviceAdminReceiver` and
  `@xml/wifi_management_device_admin` (0.3.1) are removed, so the plugin adds
  no device admin to any app. The Device Owner path is unchanged: an app that
  wants it declares its own `DeviceAdminReceiver` (see the README). Devices
  provisioned with the removed component must be provisioned again.
* Device Owner path unchanged otherwise.

## 0.3.1

* Provide device admin receiver

## 0.3.0

* **Device Owner on Android: the device's own Wi-Fi follows the plugin.**
  `connect` saves the router in the device's Wi-Fi networks with its BSSID
  locked and makes it the only enabled one, so the device itself joins it
  (other apps use it too). Releasing the request disables it; a replaced
  router, a new router that never verified, and `reset()` remove it. Without
  Device Owner nothing changes: the app-scoped `WifiNetworkSpecifier` request
  is used and the saved networks are left alone.
* New `WifiManagementDeviceAdminReceiver` (+ `@xml/wifi_management_device_admin`)
  for provisioning the app as Device Owner; the app registers it in its
  manifest (see the README), the plugin does not.
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
