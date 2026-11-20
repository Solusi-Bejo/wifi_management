package com.solusibejo.wifi_management

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

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

    @Test
    fun suggestionFailure_mapsAddStatus() {
        // Values of WifiManager.STATUS_NETWORK_SUGGESTIONS_* (inlined at compile time).
        assertNull(WifiManagementPlugin.suggestionFailure(0)) // SUCCESS
        assertNull(WifiManagementPlugin.suggestionFailure(3)) // ERROR_ADD_DUPLICATE
        assertEquals("approval_denied", WifiManagementPlugin.suggestionFailure(2)) // APP_DISALLOWED
        assertEquals("unsupported", WifiManagementPlugin.suggestionFailure(8)) // RESTRICTED_BY_ADMIN
        assertEquals("invalid_config", WifiManagementPlugin.suggestionFailure(7)) // ADD_INVALID
        assertEquals("invalid_config", WifiManagementPlugin.suggestionFailure(1)) // INTERNAL
    }

    @Test
    fun approvalAction_retriesOnlyOnApproval() {
        // Values of WifiManager.STATUS_SUGGESTION_APPROVAL_* (API 31, inlined).
        assertNull(WifiManagementPlugin.approvalAction(0)) // UNKNOWN
        assertNull(WifiManagementPlugin.approvalAction(1)) // PENDING
        assertEquals("retry", WifiManagementPlugin.approvalAction(2)) // APPROVED_BY_USER
        assertEquals("denied", WifiManagementPlugin.approvalAction(3)) // REJECTED_BY_USER
        assertEquals("retry", WifiManagementPlugin.approvalAction(4)) // APPROVED_BY_CARRIER_PRIVILEGE
    }

    @Test
    fun isSameAccessPoint_needsTheExactRouter() {
        val ssid = "AndroidWifi"
        val bssid = "02:15:b2:00:00:01"
        // Android quotes the SSID and may report the BSSID in upper case.
        assertTrue(WifiManagementPlugin.isSameAccessPoint("\"AndroidWifi\"", "02:15:B2:00:00:01", ssid, bssid))
        // Same SSID, another router: a specifier request is still needed.
        assertFalse(WifiManagementPlugin.isSameAccessPoint("\"AndroidWifi\"", "02:15:b2:00:00:02", ssid, bssid))
        // Redacted (no location permission) or not connected: unknown, so no.
        assertFalse(WifiManagementPlugin.isSameAccessPoint("\"AndroidWifi\"", "02:00:00:00:00:00", ssid, bssid))
        assertFalse(WifiManagementPlugin.isSameAccessPoint("<unknown ssid>", null, ssid, bssid))
        assertFalse(WifiManagementPlugin.isSameAccessPoint("\"Other\"", bssid, ssid, bssid))
    }
}
