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
    fun isElsewhere_onlyForAnotherNetworkNotSuggestedByUs() {
        val ssid = "Solusi Bejo (4G)"
        val bssid = "28:6e:da:1d:ac:50"
        // On the user's 5G network: elsewhere.
        assertTrue(WifiManagementPlugin.isElsewhere("\"Solusi Bejo (5G)\"", "28:6E:DA:1D:AC:51", ssid, bssid, emptyList()))
        // On the requested router: not elsewhere.
        assertFalse(WifiManagementPlugin.isElsewhere("\"Solusi Bejo (4G)\"", "28:6e:da:1d:ac:50", ssid, bssid, emptyList()))
        // On a network this app suggested (the previous router): replaceable.
        assertFalse(WifiManagementPlugin.isElsewhere("\"Old\"", "aa:bb:cc:00:00:01", ssid, bssid, listOf("Old")))
        // Not connected, or unreadable: nothing to say.
        assertFalse(WifiManagementPlugin.isElsewhere("<unknown ssid>", null, ssid, bssid, emptyList()))
        assertFalse(WifiManagementPlugin.isElsewhere("\"X\"", "02:00:00:00:00:00", ssid, bssid, emptyList()))
    }

    @Test
    fun emptyBssid_matchesTheSsidOnly() {
        // A manually entered router without BSSID: any BSSID of that SSID.
        assertTrue(WifiManagementPlugin.isSameAccessPoint("\"Hidden\"", "aa:bb:cc:00:00:07", "Hidden", ""))
        assertFalse(WifiManagementPlugin.isSameAccessPoint("\"Other\"", "aa:bb:cc:00:00:07", "Hidden", ""))
        assertFalse(WifiManagementPlugin.isSameAccessPoint("\"Hidden\"", "02:00:00:00:00:00", "Hidden", ""))
        assertFalse(WifiManagementPlugin.isElsewhere("\"Hidden\"", "aa:bb:cc:00:00:07", "Hidden", "", emptyList()))
        assertTrue(WifiManagementPlugin.isElsewhere("\"Other\"", "aa:bb:cc:00:00:07", "Hidden", "", emptyList()))
    }

    @Test
    fun readableSsid_stripsQuotesAndUnknown() {
        assertEquals("AndroidWifi", WifiManagementPlugin.readableSsid("\"AndroidWifi\""))
        assertNull(WifiManagementPlugin.readableSsid("<unknown ssid>"))
        assertNull(WifiManagementPlugin.readableSsid(null))
        assertNull(WifiManagementPlugin.readableSsid(""))
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
