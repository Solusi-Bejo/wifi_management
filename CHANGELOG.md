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
