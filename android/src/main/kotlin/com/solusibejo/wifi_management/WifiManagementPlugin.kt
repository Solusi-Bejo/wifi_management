package com.solusibejo.wifi_management

import android.Manifest
import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.ConnectivityManager
import android.net.MacAddress
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.Uri
import android.net.wifi.ScanResult
// import android.net.wifi.WifiConfiguration // parked Android 7–9 path
import android.net.wifi.WifiConfiguration // Device Owner system-network path
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
// import android.net.wifi.WifiNetworkSpecifier // parked app-only specifier path
import android.net.wifi.WifiNetworkSuggestion
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

/**
 * Wi-Fi pinning: scan, join an exact SSID + BSSID, verify the BSSID Android
 * actually joined, and bind the whole process to that network.
 *
 * Android 10+ (API 29) only. Below API 29 the plugin reports `unsupported`.
 * - Regular app: the router becomes this app's network suggestion, locked to
 *   its BSSID, so the device itself joins it with internet (after a one-time
 *   approval dialog). If the device is already on exactly that SSID + BSSID,
 *   that connection is used as is. The app-only `WifiNetworkSpecifier` path
 *   is parked in comments: Android gives it no internet.
 * - Device Owner: the router is written to the device's saved Wi-Fi networks
 *   with its BSSID locked and made the only enabled one, so the device itself
 *   joins it; [release] disables it and [forgetSystemNetwork] removes it.
 *
 * The Android 7–9 path (a `WifiConfiguration` with its `BSSID` locked, added to
 * the system Wi-Fi list) is parked in comments below, not deleted, and can be
 * re-enabled by uncommenting the blocks marked "parked Android 7–9 path".
 *
 * Only one network request is alive at a time: every [connect] releases the
 * previous callback and process binding first. Events carry the `requestId` the
 * Dart side passed in, so a late callback of a released request is ignored
 * there.
 *
 * Passwords never reach a log line from here.
 */
class WifiManagementPlugin :
    FlutterPlugin,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener,
    WifiManagementHostApi {

    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var context: Context
    private lateinit var wifiManager: WifiManager
    private lateinit var connectivityManager: ConnectivityManager
    private val events = NetworkEvents()

    private var activityBinding: ActivityPluginBinding? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var pendingPermission: ((Result<Boolean>) -> Unit)? = null

    // Device Owner path: the saved system network in use, and its deadline.
    private var systemNetworkId: Int? = null
    private var systemTimeout: Runnable? = null

    // Suggestion path: the suggestion waiting for Android to join it, the
    // approval listener (a SuggestionUserApprovalStatusListener, API 31+;
    // typed Any so older devices never load the class) and the scan nudge.
    private var pendingSuggestion: WifiNetworkSuggestion? = null
    private var approvalListener: Any? = null
    private var approvalRetried = false
    private var scanNudge: Runnable? = null

    // Parked Android 7–9 path: the system network this plugin added, and its deadline.
    // private var legacyNetworkId: Int? = null
    // private var legacyTimeout: Runnable? = null

    // ---------------------------------------------------------------------
    // Plugin lifecycle
    // ---------------------------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        WifiManagementHostApi.setUp(binding.binaryMessenger, this)
        NetworkEventsStreamHandler.register(binding.binaryMessenger, events)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        release()
        WifiManagementHostApi.setUp(binding.binaryMessenger, null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        // The prompt can no longer answer; report what is granted now.
        pendingPermission?.invoke(Result.success(hasPermissions()))
        pendingPermission = null
    }

    // ---------------------------------------------------------------------
    // Capabilities, readiness, permissions
    // ---------------------------------------------------------------------

    // Parked Android 7–9 path: both paths together covered API 24+.
    // private fun isSupported() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N
    // private fun usesSpecifier() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q

    /** [WifiNetworkSpecifier] needs Android 10 (API 29). */
    private fun isSupported() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q

    override fun capabilities(): PlatformCapabilities {
        val supported = isSupported()
        return PlatformCapabilities(
            supported = supported,
            canScan = supported,
            canLockBssid = supported,
            canBindProcess = supported,
        )
    }

    private fun requiredPermissions(): Array<String> {
        val permissions = mutableListOf(Manifest.permission.ACCESS_FINE_LOCATION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions += Manifest.permission.NEARBY_WIFI_DEVICES
        }
        return permissions.toTypedArray()
    }

    private fun hasPermissions() = requiredPermissions().all {
        context.checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED
    }

    private fun isLocationEnabled(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val manager =
                context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            return manager.isLocationEnabled
        }
        @Suppress("DEPRECATION")
        return Settings.Secure.getInt(
            context.contentResolver,
            Settings.Secure.LOCATION_MODE,
            Settings.Secure.LOCATION_MODE_OFF,
        ) != Settings.Secure.LOCATION_MODE_OFF
    }

    override fun checkReadiness(): PlatformReadiness {
        val supported = isSupported()
        return PlatformReadiness(
            supported = supported,
            permissionsGranted = supported && hasPermissions(),
            locationEnabled = supported && isLocationEnabled(),
        )
    }

    override fun requestPermissions(callback: (Result<Boolean>) -> Unit) {
        val activity = activityBinding?.activity
        if (!isSupported() || hasPermissions() || activity == null) {
            callback(Result.success(isSupported() && hasPermissions()))
            return
        }
        if (pendingPermission != null) {
            callback(Result.failure(FlutterError("busy", "A permission request is already showing")))
            return
        }
        pendingPermission = callback
        activity.requestPermissions(requiredPermissions(), PERMISSION_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE) return false
        pendingPermission?.invoke(Result.success(hasPermissions()))
        pendingPermission = null
        return true
    }

    override fun openLocationSettings() =
        openSettings(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))

    /** The system Wi-Fi picker: a panel over the app on API 29+. */
    override fun openWifiSettings() = openSettings(
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Intent(Settings.Panel.ACTION_WIFI)
        } else {
            Intent(Settings.ACTION_WIFI_SETTINGS)
        },
    )

    /**
     * The device's own Wi-Fi, or null when it is on none or the SSID/BSSID
     * is unreadable (no location permission, Location Services off).
     */
    override fun currentNetwork(callback: (Result<PlatformAccessPoint?>) -> Unit) =
        callback(Result.success(readCurrentNetwork()))

    @Suppress("DEPRECATION")
    private fun readCurrentNetwork(): PlatformAccessPoint? {
        if (!isSupported() || precondition() != null) return null
        val info = wifiManager.connectionInfo ?: return null
        val bssid = knownBssid(info.bssid) ?: return null
        val ssid = readableSsid(info.ssid) ?: return null
        val security = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            securityOfType(info.currentSecurityType)
        } else {
            "unsupported"
        }
        return PlatformAccessPoint(ssid = ssid, bssid = bssid, rssi = info.rssi.toLong(), security = security)
    }

    override fun openAppSettings() = openSettings(
        Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.fromParts("package", context.packageName, null),
        ),
    )

    private fun openSettings(intent: Intent) {
        val activity: Activity? = activityBinding?.activity
        if (activity != null) {
            activity.startActivity(intent)
        } else {
            context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
    }

    // ---------------------------------------------------------------------
    // Scan
    // ---------------------------------------------------------------------

    @Suppress("DEPRECATION")
    override fun scan(callback: (Result<PlatformScanResult>) -> Unit) {
        val failure = precondition()
        if (failure != null) {
            callback(Result.success(PlatformScanResult(emptyList(), failure)))
            return
        }

        var answered = false
        lateinit var receiver: BroadcastReceiver
        val finish = Runnable {
            if (answered) return@Runnable
            answered = true
            runCatching { context.unregisterReceiver(receiver) }
            val result = runCatching { PlatformScanResult(scanResults()) }
                .getOrElse { PlatformScanResult(emptyList(), "scan_failed") }
            callback(Result.success(result))
        }
        receiver = object : BroadcastReceiver() {
            override fun onReceive(c: Context?, intent: Intent?) {
                mainHandler.post(finish)
            }
        }
        val filter = IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // System broadcasts still arrive with NOT_EXPORTED.
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(receiver, filter)
        }
        // startScan is throttled (4 calls / 2 min in the foreground). A throttled
        // call returns false and no broadcast follows, so answer with the cached
        // results right away instead of waiting for the timeout.
        if (!wifiManager.startScan()) {
            mainHandler.post(finish)
        } else {
            mainHandler.postDelayed(finish, SCAN_TIMEOUT_MS)
        }
    }

    @Suppress("DEPRECATION")
    private fun scanResults(): List<PlatformAccessPoint> =
        wifiManager.scanResults
            .filter { !it.BSSID.isNullOrBlank() }
            .map { scan ->
                PlatformAccessPoint(
                    ssid = ssidOf(scan),
                    bssid = scan.BSSID.lowercase(),
                    rssi = scan.level.toLong(),
                    security = securityOf(scan.capabilities ?: ""),
                )
            }

    @Suppress("DEPRECATION")
    private fun ssidOf(scan: ScanResult): String =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            scan.wifiSsid?.toString()?.removeSurrounding("\"") ?: ""
        } else {
            scan.SSID ?: ""
        }

    // ---------------------------------------------------------------------
    // Connect + verify + bind
    // ---------------------------------------------------------------------

    private fun precondition(): String? = when {
        !isSupported() -> "unsupported"
        !hasPermissions() -> "permission_denied"
        !isLocationEnabled() -> "location_disabled"
        else -> null
    }

    override fun connect(request: PlatformConnectRequest) {
        val requestId = request.requestId
        val ssid = request.ssid
        val bssid = request.bssid.lowercase()

        release()

        val failure = precondition()
        if (failure != null) {
            emit(requestId, "error", failure = failure)
            return
        }

        if (isDeviceOwner()) {
            connectSystem(requestId, ssid, bssid, request.security, request.password, request.hidden)
            return
        }

        // Already on exactly this router: a specifier request would take the
        // only Wi-Fi radio away from the device's own connection (and its
        // internet) to rejoin the same access point app-only.
        if (isJoined(ssid, bssid)) {
            watchSystemNetwork(requestId, ssid, bssid, join = null)
            return
        }

        // On another Wi-Fi the user saved: Android does not move the device
        // from it to an app's suggestion, so waiting would only end in a
        // mismatch. Say so at once; the user switches in the Wi-Fi settings.
        if (isOnOtherNetwork(ssid, bssid)) {
            emit(requestId, "error", ssid = ssid, failure = "connected_elsewhere")
            return
        }

        // Parked Android 7–9 path:
        // if (!usesSpecifier()) {
        //     connectLegacy(requestId, ssid, bssid, request.security, request.password)
        //     return
        // }

        connectSuggestion(requestId, ssid, bssid, request.security, request.password, request.hidden)

        // Parked app-only WifiNetworkSpecifier path (local-only, no internet).
        // Android makes the specifier network local-only: no INTERNET
        // capability, no route, no DNS, and it takes the only radio away from
        // the device's own connection. The PID needs the cloud API through the
        // router, so the suggestion above replaced it. To bring it back for an
        // app that only talks to the router's LAN, uncomment this block, its
        // import, and PinnedNetworkCallback, and call it instead.
        /*

        val specifier = try {
            WifiNetworkSpecifier.Builder()
                .setSsid(ssid)
                .setBssid(MacAddress.fromString(bssid))
                .apply {
                    when (request.security) {
                        "wpa2" -> setWpa2Passphrase(request.password)
                        "wpa3" -> setWpa3Passphrase(request.password)
                    }
                }
                .build()
        } catch (e: IllegalArgumentException) {
            emit(requestId, "error", failure = "invalid_config")
            return
        }

        // Request-and-bind: the process is bound to this network once it is
        // verified. INTERNET is removed from the request only so the specifier
        // can match before Android validates the network; it does not change
        // where the bound traffic goes.
        val networkRequest = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .setNetworkSpecifier(specifier)
            .build()

        val callback = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PinnedNetworkCallback(
                requestId,
                ssid,
                bssid,
                ConnectivityManager.NetworkCallback.FLAG_INCLUDE_LOCATION_INFO,
            )
        } else {
            PinnedNetworkCallback(requestId, ssid, bssid)
        }
        networkCallback = callback
        emit(requestId, "connecting", ssid = ssid, bssid = bssid)
        connectivityManager.requestNetwork(networkRequest, callback, REQUEST_TIMEOUT_MS)
        */
    }

    override fun disconnect() = release()

    /**
     * Makes the device itself stop joining [ssid].
     *
     * - Regular app: removes this app's network suggestions for it; Android
     *   disconnects at once if one of them carried the connection. A network
     *   the user saved in Settings stays (only `not_device_owner` says so).
     * - Device Owner: removes every saved system network named [ssid].
     *   `getConfiguredNetworks` and `removeNetwork` always fail for apps that
     *   target API 29+, except for Device Owner, Profile Owner and system apps.
     */
    @Suppress("DEPRECATION")
    override fun forgetSystemNetwork(ssid: String): String {
        if (!::wifiManager.isInitialized) return "unsupported"
        if (!isDeviceOwner()) return forgetSuggestion(ssid)
        return try {
            val saved = savedNetworks(ssid)
            if (saved.any { it.networkId == systemNetworkId }) release()
            when {
                saved.isEmpty() -> "not_found"
                // Removing the current network also disconnects from it.
                saved.all { wifiManager.removeNetwork(it.networkId) } -> "removed"
                else -> "failed"
            }
        } catch (e: SecurityException) {
            // Location permission missing: the saved list is not readable.
            "failed"
        }
    }

    // Parked app-only WifiNetworkSpecifier path: its callback (see connect).
    /*
    /**
     * The BSSID Android reports must equal the one requested before the process
     * is bound. On API 31+ the BSSID only arrives through
     * `onCapabilitiesChanged` with FLAG_INCLUDE_LOCATION_INFO; on 29/30 it is
     * read from the connection info once the network is available.
     */
    private inner class PinnedNetworkCallback : ConnectivityManager.NetworkCallback {
        private val requestId: Long
        private val ssid: String
        private val bssid: String

        // NetworkCallback(int flags) only exists from API 31; calling it on
        // 29/30 throws NoSuchMethodError, so the no-arg super is used there.
        constructor(requestId: Long, ssid: String, bssid: String) : super() {
            this.requestId = requestId
            this.ssid = ssid
            this.bssid = bssid
        }

        @RequiresApi(Build.VERSION_CODES.S)
        constructor(
            requestId: Long,
            ssid: String,
            bssid: String,
            flags: Int,
        ) : super(flags) {
            this.requestId = requestId
            this.ssid = ssid
            this.bssid = bssid
        }

        private var verifiedNetwork: Network? = null
        private var legacyChecks = 0

        override fun onAvailable(network: Network) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                mainHandler.post { verifyLegacy(network) }
            }
        }

        override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // The first updates can arrive before WifiInfo is filled in;
                // only a real BSSID is evidence either way.
                val actual = knownBssid((caps.transportInfo as? WifiInfo)?.bssid)
                    ?: return
                mainHandler.post { verify(network, actual) }
            }
        }

        /**
         * API 29/30: the connection info can lag `onAvailable` (empty, the
         * redacted placeholder, or the previous router), so re-read it for a
         * few seconds before calling it a mismatch.
         */
        private fun verifyLegacy(network: Network) {
            if (networkCallback !== this || verifiedNetwork == network) return
            @Suppress("DEPRECATION")
            val actual = knownBssid(wifiManager.connectionInfo?.bssid)
            if (actual != bssid && ++legacyChecks < LEGACY_CHECKS) {
                mainHandler.postDelayed({ verifyLegacy(network) }, LEGACY_CHECK_MS)
                return
            }
            verify(network, actual)
        }

        /** Runs on the main thread. */
        private fun verify(network: Network, actualBssid: String?) {
            if (networkCallback !== this || verifiedNetwork == network) return
            if (actualBssid != bssid) {
                release()
                emit(
                    requestId,
                    "error",
                    ssid = ssid,
                    bssid = actualBssid,
                    failure = "bssid_mismatch",
                )
                return
            }
            if (connectivityManager.bindProcessToNetwork(network)) {
                verifiedNetwork = network
                emit(requestId, "connected", ssid = ssid, bssid = actualBssid)
            } else {
                release()
                emit(requestId, "error", ssid = ssid, failure = "bind_failed")
            }
        }

        override fun onLost(network: Network) {
            mainHandler.post {
                if (networkCallback !== this) return@post
                verifiedNetwork = null
                legacyChecks = 0
                connectivityManager.bindProcessToNetwork(null)
                emit(requestId, "lost", ssid = ssid, bssid = bssid)
            }
        }

        override fun onUnavailable() {
            mainHandler.post {
                if (networkCallback !== this) return@post
                // The framework already dropped a timed-out or rejected request.
                networkCallback = null
                connectivityManager.bindProcessToNetwork(null)
                emit(requestId, "unavailable", ssid = ssid, bssid = bssid)
            }
        }
    }
    */

    /**
     * Drops the active request and the process binding. Idempotent. On the
     * Device Owner path the saved network is disabled too, so the device
     * leaves it; it stays saved until [forgetSystemNetwork].
     */
    private fun release() {
        if (!::connectivityManager.isInitialized) return
        connectivityManager.bindProcessToNetwork(null)
        systemTimeout?.let(mainHandler::removeCallbacks)
        systemTimeout = null
        stopSuggestionWait()
        systemNetworkId?.let {
            @Suppress("DEPRECATION")
            wifiManager.disableNetwork(it)
        }
        systemNetworkId = null
        // Parked Android 7–9 path:
        // legacyTimeout?.let(mainHandler::removeCallbacks)
        // legacyTimeout = null
        // legacyNetworkId?.let(::removeLegacyNetwork)
        // legacyNetworkId = null
        val callback = networkCallback ?: return
        networkCallback = null
        runCatching { connectivityManager.unregisterNetworkCallback(callback) }
    }

    // ---------------------------------------------------------------------
    // Regular app: the router as a network suggestion (API 29+)
    // ---------------------------------------------------------------------

    /**
     * Hands the router to Android as this app's only network suggestion,
     * locked to [bssid]. Android joins it as the device's own Wi-Fi (with
     * internet, for every app) once the user approved this app's suggestions
     * (a one-time system dialog) and no network the user saved is preferred.
     * [watchSystemNetwork] then waits for that BSSID and binds.
     */
    private fun connectSuggestion(
        requestId: Long,
        ssid: String,
        bssid: String,
        security: String,
        password: String,
        hidden: Boolean,
    ) {
        val suggestion = try {
            WifiNetworkSuggestion.Builder()
                .setSsid(ssid)
                .setIsHiddenSsid(hidden)
                .apply {
                    // Empty: not locked yet; the first BSSID joined is kept.
                    if (bssid.isNotEmpty()) setBssid(MacAddress.fromString(bssid))
                    when (security) {
                        "wpa2" -> setWpa2Passphrase(password)
                        "wpa3" -> setWpa3Passphrase(password)
                    }
                }
                .build()
        } catch (e: IllegalArgumentException) {
            emit(requestId, "error", failure = "invalid_config")
            return
        }
        val failure = try {
            replaceSuggestions(suggestion)
        } catch (e: SecurityException) {
            // CHANGE_WIFI_STATE revoked: the user declined the suggestions.
            "approval_denied"
        }
        if (failure != null) {
            emit(requestId, "error", ssid = ssid, failure = failure)
            return
        }
        watchSystemNetwork(requestId, ssid, bssid, join = null)
        val callback = networkCallback ?: return
        pendingSuggestion = suggestion
        // Android weighs a suggestion only at its next network selection, and
        // a disconnected device may scan minutes apart: a just-approved
        // suggestion then sits unused until the deadline. Both nudges below
        // make it join within seconds.
        startScanNudges(callback)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            watchApproval(requestId, ssid, bssid, callback)
        }
    }

    /**
     * Asks for a scan every [SCAN_NUDGE_INTERVAL_MS] while the suggestion is
     * not joined; each scan result triggers Android's network selection.
     * Throttled scans simply fail, which is harmless.
     */
    private fun startScanNudges(callback: ConnectivityManager.NetworkCallback) {
        val nudge = object : Runnable {
            override fun run() {
                if (networkCallback !== callback || pendingSuggestion == null) return
                @Suppress("DEPRECATION")
                wifiManager.startScan()
                mainHandler.postDelayed(this, SCAN_NUDGE_INTERVAL_MS)
            }
        }
        scanNudge = nudge
        mainHandler.postDelayed(nudge, SCAN_NUDGE_FIRST_MS)
    }

    /**
     * API 31+: once the user approves this app's suggestions, re-adding the
     * suggestion makes Android connect at once (instead of at its next
     * periodic scan), and the deadline restarts so the time spent in the
     * dialog does not count. A rejection fails with `approval_denied`.
     */
    @RequiresApi(Build.VERSION_CODES.S)
    private fun watchApproval(
        requestId: Long,
        ssid: String,
        bssid: String,
        callback: ConnectivityManager.NetworkCallback,
    ) {
        val listener = WifiManager.SuggestionUserApprovalStatusListener { status ->
            if (networkCallback !== callback) return@SuggestionUserApprovalStatusListener
            when (approvalAction(status)) {
                "retry" -> retryApprovedSuggestion(requestId, ssid, bssid, callback)
                "denied" -> {
                    release()
                    emit(requestId, "error", ssid = ssid, failure = "approval_denied")
                }
            }
        }
        approvalListener = listener
        runCatching {
            wifiManager.addSuggestionUserApprovalStatusListener(context.mainExecutor, listener)
        }
    }

    /** Re-adds the approved suggestion once, scans, and restarts the deadline. */
    private fun retryApprovedSuggestion(
        requestId: Long,
        ssid: String,
        bssid: String,
        callback: ConnectivityManager.NetworkCallback,
    ) {
        val suggestion = pendingSuggestion ?: return
        // Already joined (the listener may fire on registration): re-adding
        // would drop that connection.
        if (approvalRetried || isJoined(ssid, bssid)) return
        approvalRetried = true
        val failure = try {
            replaceSuggestions(suggestion)
        } catch (e: SecurityException) {
            "approval_denied"
        }
        if (failure != null) {
            release()
            emit(requestId, "error", ssid = ssid, failure = failure)
            return
        }
        @Suppress("DEPRECATION")
        wifiManager.startScan()
        armSystemTimeout(callback, requestId, ssid, bssid)
    }

    /** Ends the suggestion wait: joined, released, or timed out. Idempotent. */
    private fun stopSuggestionWait() {
        scanNudge?.let(mainHandler::removeCallbacks)
        scanNudge = null
        pendingSuggestion = null
        approvalRetried = false
        val listener = approvalListener ?: return
        approvalListener = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            runCatching {
                wifiManager.removeSuggestionUserApprovalStatusListener(
                    listener as WifiManager.SuggestionUserApprovalStatusListener,
                )
            }
        }
    }

    /**
     * Makes [suggestion] the app's only one. Remove-then-add is safe: [connect]
     * only gets here when the device is not on this router, and it is how a
     * new password lands (suggestion equality ignores the passphrase).
     * Returns a failure code, or null.
     */
    private fun replaceSuggestions(suggestion: WifiNetworkSuggestion): String? {
        wifiManager.removeNetworkSuggestions(emptyList()) // empty: all of this app's
        return suggestionFailure(wifiManager.addNetworkSuggestions(listOf(suggestion)))
    }

    /** Removes this app's suggestions for [ssid]; see [forgetSystemNetwork]. */
    private fun forgetSuggestion(ssid: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val mine = wifiManager.networkSuggestions.filter { it.ssid == ssid }
            if (mine.isEmpty()) return "not_device_owner"
            release()
            return if (
                wifiManager.removeNetworkSuggestions(mine) ==
                WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS
            ) "removed" else "failed"
        }
        // API 29 cannot list suggestions; this app keeps at most one.
        release()
        return when (wifiManager.removeNetworkSuggestions(emptyList())) {
            WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS -> "removed"
            else -> "not_device_owner"
        }
    }

    // ---------------------------------------------------------------------
    // Device Owner path: the router as a saved system network (API 29+)
    // ---------------------------------------------------------------------

    /**
     * `addNetwork`, `updateNetwork`, `enableNetwork`, `disableNetwork` and
     * `getConfiguredNetworks` always fail for apps that target API 29+, except
     * for Device Owner, Profile Owner and system apps.
     */
    private fun isDeviceOwner(): Boolean =
        context.getSystemService(DevicePolicyManager::class.java)
            ?.isDeviceOwnerApp(context.packageName) == true

    @Suppress("DEPRECATION")
    private fun savedNetworks(ssid: String): List<WifiConfiguration> =
        wifiManager.configuredNetworks.orEmpty().filter { it.SSID == "\"$ssid\"" }

    /** Null for a security this path cannot express. */
    @Suppress("DEPRECATION")
    private fun systemConfig(
        ssid: String,
        bssid: String,
        security: String,
        password: String,
        hidden: Boolean,
    ): WifiConfiguration? = WifiConfiguration().apply {
        SSID = "\"$ssid\""
        // Restricts association to this one access point; empty: any, until
        // the first join locks one.
        if (bssid.isNotEmpty()) BSSID = bssid
        hiddenSSID = hidden
        val modern = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R
        when (security) {
            "wpa2" -> {
                preSharedKey = "\"$password\""
                if (modern) setSecurityParams(WifiConfiguration.SECURITY_TYPE_PSK)
                else allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK)
            }
            "wpa3" -> {
                preSharedKey = "\"$password\""
                if (modern) {
                    setSecurityParams(WifiConfiguration.SECURITY_TYPE_SAE)
                } else {
                    // API 29: the framework turns on PMF for SAE by itself.
                    allowedKeyManagement.set(WifiConfiguration.KeyMgmt.SAE)
                }
            }
            "open" ->
                if (modern) setSecurityParams(WifiConfiguration.SECURITY_TYPE_OPEN)
                else allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
            else -> return null
        }
    }

    /**
     * Saves the router (one entry per SSID, so the BSSID lock of an earlier
     * router with the same SSID is overwritten), enables it alone, and waits
     * until the device reports the requested BSSID before binding.
     */
    @Suppress("DEPRECATION")
    private fun connectSystem(
        requestId: Long,
        ssid: String,
        bssid: String,
        security: String,
        password: String,
        hidden: Boolean,
    ) {
        val config = systemConfig(ssid, bssid, security, password, hidden)
        if (config == null) {
            emit(requestId, "error", failure = "invalid_config")
            return
        }
        val netId = try {
            val saved = savedNetworks(ssid)
            // Duplicates would let the device pick one without our lock.
            saved.drop(1).forEach { wifiManager.removeNetwork(it.networkId) }
            val existing = saved.firstOrNull()
            if (existing != null) {
                config.networkId = existing.networkId
                wifiManager.updateNetwork(config)
            } else {
                wifiManager.addNetwork(config)
            }
        } catch (e: SecurityException) {
            -1
        }
        if (netId == -1) {
            emit(requestId, "error", failure = "invalid_config")
            return
        }
        systemNetworkId = netId
        watchSystemNetwork(requestId, ssid, bssid) {
            wifiManager.enableNetwork(netId, true) // true: disable the others
            wifiManager.reconnect()
        }
    }

    /**
     * True when the device's own Wi-Fi connection is on [ssid] at [bssid].
     * Needs the location permission and Location Services, which [connect]
     * has already checked.
     */
    /**
     * True when the device is on a Wi-Fi other than [ssid]/[bssid] that this
     * app did not suggest. A network of this app's own suggestion is fine:
     * replacing the suggestion moves the device off it.
     */
    @Suppress("DEPRECATION")
    private fun isOnOtherNetwork(ssid: String, bssid: String): Boolean {
        val info = wifiManager.connectionInfo ?: return false
        val mine = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            runCatching { wifiManager.networkSuggestions.mapNotNull { it.ssid } }
                .getOrDefault(emptyList())
        } else {
            emptyList() // API 29 cannot list them
        }
        return isElsewhere(info.ssid, info.bssid, ssid, bssid, mine)
    }

    @Suppress("DEPRECATION")
    private fun isJoined(ssid: String, bssid: String): Boolean {
        val info = wifiManager.connectionInfo ?: return false
        return isSameAccessPoint(info.ssid, info.bssid, ssid, bssid)
    }

    /**
     * Follows the device's own Wi-Fi connection: binds once it shows
     * [bssid], reports a later move to another BSSID and the loss of the
     * link. [join] makes the device go there (Device Owner path); null means
     * it is already there, and nothing about the device's networks changes.
     */
    private fun watchSystemNetwork(
        requestId: Long,
        ssid: String,
        bssid: String,
        join: (() -> Unit)?,
    ) {
        val callback = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            SystemNetworkCallback(
                requestId,
                ssid,
                bssid,
                ConnectivityManager.NetworkCallback.FLAG_INCLUDE_LOCATION_INFO,
            )
        } else {
            SystemNetworkCallback(requestId, ssid, bssid)
        }
        networkCallback = callback
        emit(requestId, "connecting", ssid = ssid, bssid = bssid)
        connectivityManager.registerNetworkCallback(
            NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .build(),
            callback,
        )
        join?.invoke()
        armSystemTimeout(callback, requestId, ssid, bssid)
    }

    /**
     * (Re)starts the deadline for [callback] to see [bssid]: past it the wait
     * ends as `bssid_mismatch` (on another router) or `unavailable`.
     */
    private fun armSystemTimeout(
        callback: ConnectivityManager.NetworkCallback,
        requestId: Long,
        ssid: String,
        bssid: String,
    ) {
        systemTimeout?.let(mainHandler::removeCallbacks)
        val timeout = Runnable {
            if (networkCallback !== callback) return@Runnable
            val actual = currentBssid(null)
            release()
            if (bssid.isNotEmpty() && actual != null && actual != bssid) {
                emit(requestId, "error", ssid = ssid, bssid = actual, failure = "bssid_mismatch")
            } else {
                emit(requestId, "unavailable", ssid = ssid, bssid = bssid)
            }
        }
        systemTimeout = timeout
        mainHandler.postDelayed(timeout, REQUEST_TIMEOUT_MS.toLong())
    }

    /** The joined SSID: from [caps] on API 31+, else the connection info. */
    private fun currentSsid(caps: NetworkCapabilities?): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && caps != null) {
            return readableSsid((caps.transportInfo as? WifiInfo)?.ssid)
        }
        @Suppress("DEPRECATION")
        return readableSsid(wifiManager.connectionInfo?.ssid)
    }

    /** The joined BSSID: from [caps] on API 31+, else the connection info. */
    private fun currentBssid(caps: NetworkCapabilities?): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && caps != null) {
            return knownBssid((caps.transportInfo as? WifiInfo)?.bssid)
        }
        @Suppress("DEPRECATION")
        return knownBssid(wifiManager.connectionInfo?.bssid)
    }

    /**
     * Android itself (re)joins the saved network, or is already on it; this
     * waits until the requested BSSID shows up, binds, and afterwards treats a
     * different BSSID on that network as a mismatch. Until then, another
     * router (the device leaving the previous one) is not a failure: the
     * timeout decides.
     */
    private inner class SystemNetworkCallback : ConnectivityManager.NetworkCallback {
        private val requestId: Long
        private val ssid: String

        /** Empty until the first join locks one (see [check]). */
        private var bssid: String

        // NetworkCallback(int flags) only exists from API 31.
        constructor(requestId: Long, ssid: String, bssid: String) : super() {
            this.requestId = requestId
            this.ssid = ssid
            this.bssid = bssid
        }

        @RequiresApi(Build.VERSION_CODES.S)
        constructor(
            requestId: Long,
            ssid: String,
            bssid: String,
            flags: Int,
        ) : super(flags) {
            this.requestId = requestId
            this.ssid = ssid
            this.bssid = bssid
        }

        private var verifiedNetwork: Network? = null

        override fun onAvailable(network: Network) {
            mainHandler.post { check(network, null) }
        }

        override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
            mainHandler.post { check(network, caps) }
        }

        private fun check(network: Network, caps: NetworkCapabilities?) {
            if (networkCallback !== this) return
            val actual = currentBssid(caps) ?: return
            val verified = verifiedNetwork
            if (verified != null) {
                if (network == verified && actual != bssid) {
                    release()
                    emit(requestId, "error", ssid = ssid, bssid = actual, failure = "bssid_mismatch")
                }
                return
            }
            val onTarget =
                if (bssid.isEmpty()) currentSsid(caps) == ssid else actual == bssid
            if (!onTarget) return
            if (connectivityManager.bindProcessToNetwork(network)) {
                verifiedNetwork = network
                // Nothing locked yet: this BSSID is the router from now on.
                if (bssid.isEmpty()) bssid = actual
                systemTimeout?.let(mainHandler::removeCallbacks)
                systemTimeout = null
                stopSuggestionWait()
                emit(requestId, "connected", ssid = ssid, bssid = actual)
            } else {
                release()
                emit(requestId, "error", ssid = ssid, failure = "bind_failed")
            }
        }

        override fun onLost(network: Network) {
            mainHandler.post {
                if (networkCallback !== this || network != verifiedNetwork) return@post
                verifiedNetwork = null
                connectivityManager.bindProcessToNetwork(null)
                emit(requestId, "lost", ssid = ssid, bssid = bssid)
            }
        }
    }

    // ---------------------------------------------------------------------
    // Parked Android 7–9 (API 24–28) path: system network with a locked BSSID.
    // Reverted by product decision (API 29+ only). To re-enable: uncomment this
    // block, the WifiConfiguration import, the legacy fields, `usesSpecifier`,
    // the SAE line in `securityOf`, the branch in `connect`, the lines in
    // `release`, and widen `isSupported` to Build.VERSION_CODES.N.
    // ---------------------------------------------------------------------

    /*
    @Suppress("DEPRECATION")
    private fun legacyConfig(
        ssid: String,
        bssid: String,
        security: String,
        password: String,
    ): WifiConfiguration? = WifiConfiguration().apply {
        SSID = "\"$ssid\""
        // Restricts association to this one access point.
        BSSID = bssid
        when (security) {
            "wpa2" -> {
                preSharedKey = "\"$password\""
                allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK)
            }
            "open" -> allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
            else -> return null
        }
    }

    private fun connectLegacy(
        requestId: Int,
        ssid: String,
        bssid: String,
        security: String,
        password: String,
    ) {
        val config = legacyConfig(ssid, bssid, security, password)
        // Entries this app added on an earlier run (the id is not kept across
        // restarts). Networks saved by the user or MDM cannot be removed by
        // an app and are left alone; the BSSID check below still guards them.
        @Suppress("DEPRECATION")
        runCatching {
            wifiManager.configuredNetworks
                ?.filter { it.SSID == "\"$ssid\"" }
                ?.forEach { removeLegacyNetwork(it.networkId) }
        }
        @Suppress("DEPRECATION")
        val netId = config?.let(wifiManager::addNetwork) ?: -1
        if (netId == -1) {
            emit(requestId.toLong(), "error", ssid = ssid, failure = "invalid_config")
            return
        }
        legacyNetworkId = netId

        val callback = LegacyNetworkCallback(requestId, ssid, bssid)
        networkCallback = callback
        emit(requestId.toLong(), "connecting", ssid = ssid, bssid = bssid)
        connectivityManager.registerNetworkCallback(
            NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .build(),
            callback,
        )
        @Suppress("DEPRECATION")
        wifiManager.enableNetwork(netId, true) // true: disable the others
        @Suppress("DEPRECATION")
        wifiManager.reconnect()

        val timeout = Runnable {
            if (networkCallback !== callback) return@Runnable
            @Suppress("DEPRECATION")
            val actual = knownBssid(wifiManager.connectionInfo?.bssid)
            release()
            if (actual != null && actual != bssid) {
                emit(requestId.toLong(), "error", ssid = ssid, bssid = actual, failure = "bssid_mismatch")
            } else {
                emit(requestId.toLong(), "unavailable", ssid = ssid, bssid = bssid)
            }
        }
        legacyTimeout = timeout
        mainHandler.postDelayed(timeout, REQUEST_TIMEOUT_MS.toLong())
    }

    @Suppress("DEPRECATION")
    private fun removeLegacyNetwork(netId: Int) {
        if (wifiManager.removeNetwork(netId) &&
            Build.VERSION.SDK_INT < Build.VERSION_CODES.O
        ) {
            wifiManager.saveConfiguration() // persisted implicitly from API 26
        }
    }

    /**
     * Android itself (re)joins the locked network; this only waits until the
     * connection info shows the requested BSSID, binds, and afterwards treats
     * a different BSSID on the same network as a mismatch (a vendor roam).
     */
    private inner class LegacyNetworkCallback(
        private val requestId: Int,
        private val ssid: String,
        private val bssid: String,
    ) : ConnectivityManager.NetworkCallback() {
        private var verifiedNetwork: Network? = null

        override fun onAvailable(network: Network) {
            mainHandler.post { check(network) }
        }

        override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
            mainHandler.post { check(network) }
        }

        private fun check(network: Network) {
            if (networkCallback !== this) return
            @Suppress("DEPRECATION")
            val actual = knownBssid(wifiManager.connectionInfo?.bssid)
            val verified = verifiedNetwork
            if (verified != null) {
                if (network == verified && actual != null && actual != bssid) {
                    release()
                    emit(requestId.toLong(), "error", ssid = ssid, bssid = actual, failure = "bssid_mismatch")
                }
                return
            }
            // Still on the previous router, or not associated yet: the
            // timeout decides if this never settles.
            if (actual != bssid) return
            if (connectivityManager.bindProcessToNetwork(network)) {
                verifiedNetwork = network
                legacyTimeout?.let(mainHandler::removeCallbacks)
                legacyTimeout = null
                emit(requestId.toLong(), "connected", ssid = ssid, bssid = actual)
            } else {
                release()
                emit(requestId.toLong(), "error", ssid = ssid, failure = "bind_failed")
            }
        }

        override fun onLost(network: Network) {
            mainHandler.post {
                if (networkCallback !== this || network != verifiedNetwork) return@post
                verifiedNetwork = null
                connectivityManager.bindProcessToNetwork(null)
                emit(requestId.toLong(), "lost", ssid = ssid, bssid = bssid)
            }
        }
    }
    */

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    private class NetworkEvents : NetworkEventsStreamHandler() {
        var sink: PigeonEventSink<PlatformNetworkEvent>? = null

        override fun onListen(p0: Any?, sink: PigeonEventSink<PlatformNetworkEvent>) {
            this.sink = sink
        }

        override fun onCancel(p0: Any?) {
            sink = null
        }
    }

    private fun emit(
        requestId: Long,
        type: String,
        ssid: String? = null,
        bssid: String? = null,
        failure: String? = null,
    ) {
        val event = PlatformNetworkEvent(requestId, type, ssid, bssid, failure)
        if (Looper.myLooper() == Looper.getMainLooper()) {
            events.sink?.success(event)
        } else {
            mainHandler.post { events.sink?.success(event) }
        }
    }

    companion object {
        private const val PERMISSION_REQUEST_CODE = 4127
        private const val SCAN_TIMEOUT_MS = 10_000L
        private const val REQUEST_TIMEOUT_MS = 60_000
        private const val REDACTED_BSSID = "02:00:00:00:00:00"
        private const val LEGACY_CHECKS = 10
        private const val LEGACY_CHECK_MS = 500L

        /**
         * Router security from the scan capability string. `PSK` wins over
         * `SAE` because a WPA2/WPA3 transition network accepts a WPA2
         * passphrase.
         */
        internal fun securityOf(capabilities: String): String = when {
            capabilities.contains("EAP") -> "unsupported"
            capabilities.contains("PSK") -> "wpa2"
            // Parked Android 7–9 path: WPA3-only (SAE) has no WifiConfiguration key management.
            // capabilities.contains("SAE") -> if (usesSpecifier()) "wpa3" else "unsupported"
            capabilities.contains("SAE") -> "wpa3"
            capabilities.contains("WEP") || capabilities.contains("OWE") -> "unsupported"
            else -> "open"
        }

        /**
         * Whether the connection info's [rawSsid] (quoted by Android) and
         * [rawBssid] name the requested [ssid] and lower-case [bssid]. An
         * empty [bssid] (none locked yet) matches any readable one; a
         * redacted BSSID never matches.
         */
        internal fun isSameAccessPoint(
            rawSsid: String?,
            rawBssid: String?,
            ssid: String,
            bssid: String,
        ): Boolean {
            val current = knownBssid(rawBssid) ?: return false
            return (bssid.isEmpty() || current == bssid) && readableSsid(rawSsid) == ssid
        }

        /** First scan nudge after a suggestion is placed, then the interval. */
        private const val SCAN_NUDGE_FIRST_MS = 3_000L
        private const val SCAN_NUDGE_INTERVAL_MS = 15_000L

        /**
         * What a suggestion approval status asks for: `retry` (just approved:
         * re-add so Android joins now), `denied`, or null (pending / unknown).
         * The `STATUS_SUGGESTION_APPROVAL_*` constants are API 31, inlined.
         */
        internal fun approvalAction(status: Int): String? = when (status) {
            WifiManager.STATUS_SUGGESTION_APPROVAL_APPROVED_BY_USER,
            WifiManager.STATUS_SUGGESTION_APPROVAL_APPROVED_BY_CARRIER_PRIVILEGE,
            -> "retry"
            WifiManager.STATUS_SUGGESTION_APPROVAL_REJECTED_BY_USER -> "denied"
            else -> null
        }

        /**
         * Failure code for an `addNetworkSuggestions` status, or null when the
         * suggestion is in place.
         */
        internal fun suggestionFailure(status: Int): String? = when (status) {
            WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS,
            WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_ADD_DUPLICATE,
            -> null
            // The user declined this app's suggestions.
            WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_APP_DISALLOWED -> "approval_denied"
            // A compile-time constant (API 33); older devices never return it.
            WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_RESTRICTED_BY_ADMIN -> "unsupported"
            else -> "invalid_config"
        }

        /**
         * Whether the connection info ([rawSsid], [rawBssid]) shows the device
         * on a readable network that is neither the requested one nor one of
         * this app's suggestions ([mySuggestionSsids]).
         */
        internal fun isElsewhere(
            rawSsid: String?,
            rawBssid: String?,
            ssid: String,
            bssid: String,
            mySuggestionSsids: List<String>,
        ): Boolean {
            val currentBssid = knownBssid(rawBssid) ?: return false
            val currentSsid = readableSsid(rawSsid) ?: return false
            if (currentSsid == ssid && (bssid.isEmpty() || currentBssid == bssid)) return false
            return currentSsid !in mySuggestionSsids
        }

        /** The SSID without Android's quotes; null when unknown or hidden. */
        internal fun readableSsid(raw: String?): String? =
            raw?.removeSurrounding("\"")
                ?.takeUnless { it.isBlank() || it == UNKNOWN_SSID }

        private const val UNKNOWN_SSID = "<unknown ssid>"

        /** Security code for a `WifiInfo.currentSecurityType` (API 31). */
        internal fun securityOfType(type: Int): String = when (type) {
            WifiInfo.SECURITY_TYPE_OPEN -> "open"
            WifiInfo.SECURITY_TYPE_PSK -> "wpa2"
            WifiInfo.SECURITY_TYPE_SAE -> "wpa3"
            else -> "unsupported"
        }

        /** Null for an empty or redacted (`02:00:00:00:00:00`) BSSID. */
        internal fun knownBssid(raw: String?): String? =
            raw?.lowercase()?.takeUnless { it.isBlank() || it == REDACTED_BSSID }
    }
}
