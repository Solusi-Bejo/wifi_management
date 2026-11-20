package com.solusibejo.wifi_management

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

/*
 * Run with `./gradlew testDebugUnitTest` from `example/android/`.
 */
internal class WifiManagementPluginTest {
    @Test
    fun securityOf_mapsScanCapabilities() {
        assertEquals("wpa2", WifiManagementPlugin.securityOf("[WPA2-PSK-CCMP][ESS]"))
        // A WPA2/WPA3 transition network accepts a WPA2 passphrase.
        assertEquals("wpa2", WifiManagementPlugin.securityOf("[WPA2-PSK+SAE-CCMP]"))
        assertEquals("wpa3", WifiManagementPlugin.securityOf("[RSN-SAE-CCMP]"))
        assertEquals("unsupported", WifiManagementPlugin.securityOf("[WPA2-EAP-CCMP]"))
        assertEquals("unsupported", WifiManagementPlugin.securityOf("[WEP]"))
        assertEquals("open", WifiManagementPlugin.securityOf("[ESS]"))
    }

    @Test
    fun knownBssid_ignoresRedactedAndBlank() {
        assertNull(WifiManagementPlugin.knownBssid(null))
        assertNull(WifiManagementPlugin.knownBssid(""))
        assertNull(WifiManagementPlugin.knownBssid("02:00:00:00:00:00"))
        assertEquals("aa:bb:cc:00:00:01", WifiManagementPlugin.knownBssid("AA:BB:CC:00:00:01"))
    }
}
