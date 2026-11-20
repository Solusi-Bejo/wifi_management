package com.solusibejo.wifi_management

import android.app.admin.DeviceAdminReceiver

/**
 * Admin component for provisioning the host app as Device Owner, which lets
 * this plugin keep the device's own saved Wi-Fi networks in step with
 * connect / disconnect / reset (see the README).
 *
 * Not declared in this plugin's manifest on purpose: only apps that opt in
 * register it, so other apps never show up as a device admin. Open so an app
 * can extend it with its own callbacks.
 */
open class WifiManagementDeviceAdminReceiver : DeviceAdminReceiver()
