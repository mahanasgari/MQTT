package com.example.smartplug

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSpecifier
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Temporary local-only join to the plug SoftAP so HTTP to 192.168.4.1
 * works without a browser. Also scans nearby Wi‑Fi so the user picks
 * a home network instead of typing the SSID.
 */
class SoftApWifiPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var callback: ConnectivityManager.NetworkCallback? = null
    private val main = Handler(Looper.getMainLooper())
    private var pendingScan: MethodChannel.Result? = null

    fun attach(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "smartplug/softap_wifi")
        channel?.setMethodCallHandler(this)
    }

    fun detach() {
        disconnectInternal()
        pendingScan = null
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connectToSsid" -> {
                val ssid = call.argument<String>("ssid")
                if (ssid.isNullOrBlank()) {
                    result.error("BAD_ARGS", "ssid required", null)
                } else {
                    connectToSsid(ssid, result)
                }
            }
            "disconnect" -> {
                disconnectInternal()
                result.success(null)
            }
            "hasInternet" -> result.success(hasValidatedInternet())
            "restoreInternet" -> {
                val preferred = call.argument<String>("preferredSsid")
                val timeoutMs = call.argument<Int>("timeoutMs") ?: 30_000
                restoreInternet(preferred, timeoutMs, result)
            }
            "currentSsid" -> result.success(currentSsid())
            "scanNetworks" -> scanNetworks(result)
            "openWifiSettings" -> {
                try {
                    val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    activity.startActivity(intent)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("SETTINGS", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQ_SCAN) return false
        val pending = pendingScan ?: return true
        pendingScan = null
        if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            doScan(pending)
        } else {
            pending.error(
                "PERMISSION",
                "Location / nearby Wi‑Fi permission is needed to list networks. You can still type a name.",
                null,
            )
        }
        return true
    }

    private fun connectivity(): ConnectivityManager =
        activity.applicationContext.getSystemService(Activity.CONNECTIVITY_SERVICE)
            as ConnectivityManager

    private fun wifiManager(): WifiManager =
        activity.applicationContext.getSystemService(Activity.WIFI_SERVICE) as WifiManager

    private fun currentSsid(): String? {
        return try {
            @Suppress("DEPRECATION")
            val raw = wifiManager().connectionInfo?.ssid ?: return null
            raw.trim('"').takeIf { it.isNotEmpty() && it != "<unknown ssid>" }
        } catch (_: Exception) {
            null
        }
    }

    private fun scanPermissions(): Array<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arrayOf(
                Manifest.permission.NEARBY_WIFI_DEVICES,
                Manifest.permission.ACCESS_FINE_LOCATION,
            )
        } else {
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            )
        }
    }

    private fun hasScanPermission(): Boolean {
        return scanPermissions().all {
            ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun scanNetworks(result: MethodChannel.Result) {
        if (!hasScanPermission()) {
            pendingScan = result
            ActivityCompat.requestPermissions(activity, scanPermissions(), REQ_SCAN)
            return
        }
        doScan(result)
    }

    private fun doScan(result: MethodChannel.Result) {
        val wifi = wifiManager()
        try {
            @Suppress("DEPRECATION")
            wifi.startScan()
        } catch (_: Exception) {
        }
        main.postDelayed({
            try {
                @Suppress("DEPRECATION")
                val rows = wifi.scanResults ?: emptyList()
                val mapped = rows.map { ap ->
                    val caps = ap.capabilities ?: ""
                    hashMapOf(
                        "ssid" to (ap.SSID ?: ""),
                        "rssi" to ap.level,
                        "frequency" to ap.frequency,
                        "secure" to (
                            caps.contains("WEP") ||
                                caps.contains("PSK") ||
                                caps.contains("EAP") ||
                                caps.contains("SAE")
                            ),
                    )
                }
                result.success(mapped)
            } catch (e: Exception) {
                result.error("SCAN", e.message ?: "Wi‑Fi scan failed", null)
            }
        }, 2500)
    }

    /**
     * Leave SoftAP binding only. Do NOT call WifiManager.disconnect()/reconnect() here —
     * that tears down home Wi‑Fi when the user taps Back mid-connect.
     * Use [restoreInternet] after a successful SoftAP configure to rejoin home Wi‑Fi.
     */
    private fun disconnectInternal() {
        val pending = pendingScan
        pendingScan = null
        if (pending != null) {
            try {
                pending.error("CANCELLED", "Wi‑Fi scan cancelled", null)
            } catch (_: Exception) {
            }
        }
        val cm = connectivity()
        callback?.let {
            try {
                cm.unregisterNetworkCallback(it)
            } catch (_: Exception) {
            }
        }
        callback = null
        try {
            cm.bindProcessToNetwork(null)
        } catch (_: Exception) {
        }
    }

    private fun hasValidatedInternet(): Boolean {
        return try {
            val cm = connectivity()
            val net = cm.activeNetwork ?: return false
            val caps = cm.getNetworkCapabilities(net) ?: return false
            caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
        } catch (_: Exception) {
            false
        }
    }

    /** Remove saved open SoftAP profiles so Samsung does not stick on SmartPlug-*. */
    private fun forgetSoftApNetworks() {
        try {
            val wifi = wifiManager()
            @Suppress("DEPRECATION")
            val configs = wifi.configuredNetworks ?: return
            var removed = false
            for (c in configs) {
                val sid = c.SSID?.trim('"') ?: continue
                if (sid.startsWith(SOFTAP_PREFIX, ignoreCase = true)) {
                    @Suppress("DEPRECATION")
                    if (wifi.removeNetwork(c.networkId)) removed = true
                }
            }
            if (removed) {
                @Suppress("DEPRECATION")
                wifi.saveConfiguration()
            }
        } catch (_: Exception) {
        }
    }

    private fun enablePreferredHome(preferredSsid: String?) {
        if (preferredSsid.isNullOrBlank()) return
        try {
            val wifi = wifiManager()
            @Suppress("DEPRECATION")
            val configs = wifi.configuredNetworks ?: return
            val match = configs.firstOrNull { it.SSID?.trim('"') == preferredSsid } ?: return
            @Suppress("DEPRECATION")
            wifi.enableNetwork(match.networkId, true)
        } catch (_: Exception) {
        }
    }

    /**
     * After SoftAP HTTP setup: drop SoftAP binding, forget plug hotspots, reconnect
     * home Wi‑Fi, and wait until the network is internet-validated (needed for cloud
     * register / MQTT wait).
     */
    private fun restoreInternet(
        preferredSsid: String?,
        timeoutMs: Int,
        result: MethodChannel.Result,
    ) {
        disconnectInternal()
        forgetSoftApNetworks()
        enablePreferredHome(preferredSsid)
        try {
            @Suppress("DEPRECATION")
            wifiManager().reconnect()
        } catch (_: Exception) {
        }

        if (hasValidatedInternet()) {
            result.success(true)
            return
        }

        val cm = connectivity()
        val replied = AtomicBoolean(false)
        lateinit var waitCb: ConnectivityManager.NetworkCallback
        fun finish(ok: Boolean) {
            if (replied.compareAndSet(false, true)) {
                try {
                    cm.unregisterNetworkCallback(waitCb)
                } catch (_: Exception) {
                }
                main.post { result.success(ok) }
            }
        }

        waitCb = object : ConnectivityManager.NetworkCallback() {
            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities,
            ) {
                if (networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                    networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
                ) {
                    finish(true)
                }
            }

            override fun onAvailable(network: Network) {
                if (hasValidatedInternet()) finish(true)
            }
        }

        try {
            val request = NetworkRequest.Builder()
                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .build()
            cm.registerNetworkCallback(request, waitCb)
        } catch (_: Exception) {
            result.success(hasValidatedInternet())
            return
        }

        main.postDelayed({ finish(hasValidatedInternet()) }, timeoutMs.toLong())
    }

    private fun connectToSsid(ssid: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.error(
                "UNSUPPORTED",
                "Android 10 or newer is required to join the plug Wi‑Fi from the app.",
                null,
            )
            return
        }

        disconnectInternal()
        val replied = AtomicBoolean(false)
        fun stillActive(cb: ConnectivityManager.NetworkCallback): Boolean =
            callback === cb && !replied.get()

        fun replyOk(cb: ConnectivityManager.NetworkCallback) {
            if (stillActive(cb) && replied.compareAndSet(false, true)) {
                main.post { result.success(true) }
            }
        }
        fun replyErr(cb: ConnectivityManager.NetworkCallback, code: String, message: String) {
            if (stillActive(cb) && replied.compareAndSet(false, true)) {
                main.post { result.error(code, message, null) }
            }
        }

        val specifier = WifiNetworkSpecifier.Builder()
            .setSsid(ssid)
            .build()
        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .setNetworkSpecifier(specifier)
            .build()

        val cm = connectivity()
        lateinit var cb: ConnectivityManager.NetworkCallback
        cb = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                if (!stillActive(cb)) return
                cm.bindProcessToNetwork(network)
                replyOk(cb)
            }

            override fun onUnavailable() {
                replyErr(
                    cb,
                    "UNAVAILABLE",
                    "Could not join $ssid. Approve the Connect prompt, and keep the plug hotspot on.",
                )
            }

            override fun onLost(network: Network) {
                if (callback !== cb) return
                try {
                    cm.bindProcessToNetwork(null)
                } catch (_: Exception) {
                }
            }
        }
        callback = cb
        try {
            cm.requestNetwork(request, cb, 45_000)
        } catch (e: Exception) {
            callback = null
            replyErr(cb, "REQUEST", e.message ?: "Wi‑Fi request failed")
        }
    }

    companion object {
        private const val REQ_SCAN = 2401
        private const val SOFTAP_PREFIX = "SmartPlug-"
    }
}
