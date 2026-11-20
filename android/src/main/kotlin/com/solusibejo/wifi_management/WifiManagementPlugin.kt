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
import android.net.wifi.WifiNetworkSpecifier
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
 * - Regular app: a [WifiNetworkSpecifier] request (app-scoped); the device's
 *   saved Wi-Fi networks are untouched.
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
            connectSystem(requestId, ssid, bssid, request.security, request.password)
            return
        }

        // Parked Android 7–9 path:
        // if (!usesSpecifier()) {
        //     connectLegacy(requestId, ssid, bssid, request.security, request.password)
        //     return
        // }

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
    }

    override fun disconnect() = release()

    /**
     * Removes every saved system network named [ssid]. Releasing the
     * specifier request alone does not help when the same router is also
     * saved in Settings: the device rejoins it by itself.
     *
     * `getConfiguredNetworks` and `removeNetwork` always fail for apps that
     * target API 29+, except for Device Owner, Profile Owner and system apps,
     * so anything else gets `not_device_owner` without trying.
     */
    @Suppress("DEPRECATION")
    override fun forgetSystemNetwork(ssid: String): String {
        if (!::wifiManager.isInitialized) return "unsupported"
        if (!isDeviceOwner()) return "not_device_owner"
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
    ): WifiConfiguration? = WifiConfiguration().apply {
        SSID = "\"$ssid\""
        // Restricts association to this one access point.
        BSSID = bssid
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
    ) {
        val config = systemConfig(ssid, bssid, security, password)
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
        wifiManager.enableNetwork(netId, true) // true: disable the others
        wifiManager.reconnect()

        val timeout = Runnable {
            if (networkCallback !== callback) return@Runnable
            val actual = currentBssid(null)
            release()
            if (actual != null && actual != bssid) {
                emit(requestId, "error", ssid = ssid, bssid = actual, failure = "bssid_mismatch")
            } else {
                emit(requestId, "unavailable", ssid = ssid, bssid = bssid)
            }
        }
        systemTimeout = timeout
        mainHandler.postDelayed(timeout, REQUEST_TIMEOUT_MS.toLong())
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
     * Android itself (re)joins the saved network; this waits until the
     * requested BSSID shows up, binds, and afterwards treats a different
     * BSSID on that network as a mismatch. Until then, another router (the
     * device leaving the previous one) is not a failure: the timeout decides.
     */
    private inner class SystemNetworkCallback : ConnectivityManager.NetworkCallback {
        private val requestId: Long
        private val ssid: String
        private val bssid: String

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
            if (actual != bssid) return
            if (connectivityManager.bindProcessToNetwork(network)) {
                verifiedNetwork = network
                systemTimeout?.let(mainHandler::removeCallbacks)
                systemTimeout = null
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

        /** Null for an empty or redacted (`02:00:00:00:00:00`) BSSID. */
        internal fun knownBssid(raw: String?): String? =
            raw?.lowercase()?.takeUnless { it.isBlank() || it == REDACTED_BSSID }
    }
}
