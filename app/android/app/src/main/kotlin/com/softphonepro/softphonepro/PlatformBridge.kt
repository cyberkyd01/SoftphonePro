package com.softphonepro.softphonepro

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.ContactsContract
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** MethodChannel / EventChannel endpoint used by AndroidPlatformServices (Dart). */
object PlatformBridge : MethodChannel.MethodCallHandler {
    const val CHANNEL = "softphonepro/platform"
    const val EVENTS = "softphonepro/platform/events"
    private const val REQ_PERMS = 4711

    private var keepOn = false
    private var pendingPerms: MethodChannel.Result? = null
    private var netRegistered = false
    private var lastDns: List<String> = emptyList()

    fun register(engine: FlutterEngine) {
        val m = engine.dartExecutor.binaryMessenger
        MethodChannel(m, CHANNEL).setMethodCallHandler(this)
        // Channel used by the LAN controller (app/lib/lan): idempotent, owner "lan".
        MethodChannel(m, "com.softphonepro/lan").setMethodCallHandler { call, result ->
            when (call.method) {
                "acquireMulticastLock" -> { Locks.setMulticast(true, "lan"); result.success(true) }
                "releaseMulticastLock" -> { Locks.setMulticast(false, "lan"); result.success(true) }
                else -> result.notImplemented()
            }
        }
        EventChannel(m, EVENTS).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) = Hub.attach(events)
            override fun onCancel(arguments: Any?) = Hub.detach()
        })
    }

    private val ctx get() = Hub.app

    // ---- permissions -----------------------------------------------------------

    private fun granted(p: String) = ContextCompat.checkSelfPermission(ctx, p) == PackageManager.PERMISSION_GRANTED

    private fun status(p: String?): String {
        if (p == null) return "unsupported"
        if (granted(p)) return "granted"
        val asked = Prefs.of(ctx).getBoolean("asked_$p", false)
        val act = Hub.activity
        val rationale = act != null && ActivityCompat.shouldShowRequestPermissionRationale(act, p)
        return if (asked && !rationale) "permanentlyDenied" else "denied"
    }

    private fun notifPerm() = if (Build.VERSION.SDK_INT >= 33) Manifest.permission.POST_NOTIFICATIONS else null
    private fun btPerm() = if (Build.VERSION.SDK_INT >= 31) Manifest.permission.BLUETOOTH_CONNECT else null

    private fun statusMap(): Map<String, Any?> = mapOf(
        "microphone" to status(Manifest.permission.RECORD_AUDIO),
        "notifications" to (if (Build.VERSION.SDK_INT >= 33) status(notifPerm())
        else if (androidx.core.app.NotificationManagerCompat.from(ctx).areNotificationsEnabled()) "granted" else "denied"),
        "contacts" to status(Manifest.permission.READ_CONTACTS),
        "bluetooth" to (if (btPerm() == null) "granted" else status(btPerm())),
        "fullScreenIntent" to canFullScreen(),
        "batteryOptimizationsIgnored" to ignoringBattery(),
        "sdk" to Build.VERSION.SDK_INT,
        "manufacturer" to Build.MANUFACTURER,
    )

    private fun requestPerms(perms: List<String>, result: MethodChannel.Result) {
        val missing = perms.filter { !granted(it) }
        val act = Hub.activity
        Hub.log("requestPerms missing=$missing activity=${act != null} pending=${pendingPerms != null}")
        if (missing.isEmpty() || act == null || pendingPerms != null) {
            result.success(statusMap())
            return
        }
        pendingPerms = result
        val p = Prefs.of(ctx).edit()
        missing.forEach { p.putBoolean("asked_$it", true) }
        p.apply()
        ActivityCompat.requestPermissions(act, missing.toTypedArray(), REQ_PERMS)
    }

    fun onPermissionsResult(code: Int) {
        if (code != REQ_PERMS) return
        pendingPerms?.success(statusMap())
        pendingPerms = null
    }

    private fun canFullScreen(): Boolean {
        if (Build.VERSION.SDK_INT < 34) return true
        return ctx.getSystemService(NotificationManager::class.java).canUseFullScreenIntent()
    }

    private fun ignoringBattery(): Boolean {
        val pm = ctx.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(ctx.packageName)
    }

    private fun startSettings(vararg intents: Intent): Boolean {
        for (i in intents) {
            try {
                i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (i.resolveActivity(ctx.packageManager) != null || i.component != null) {
                    ctx.startActivity(i)
                    return true
                }
            } catch (_: Throwable) {
            }
        }
        return false
    }

    private fun appDetails() = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${ctx.packageName}"))

    private fun autostartIntents(): List<Intent> {
        fun c(pkg: String, cls: String) = Intent().setComponent(android.content.ComponentName(pkg, cls))
        return when (Build.MANUFACTURER.lowercase()) {
            "xiaomi", "redmi", "poco" -> listOf(c("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"))
            "huawei", "honor" -> listOf(
                c("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
                c("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
            )
            "oppo", "realme", "oneplus" -> listOf(
                c("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
                c("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
            )
            "vivo" -> listOf(
                c("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
                c("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
            )
            "samsung" -> listOf(c("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity"))
            "asus" -> listOf(c("com.asus.mobilemanager", "com.asus.mobilemanager.autostart.AutoStartActivity"))
            else -> emptyList()
        }
    }

    // ---- network / DNS ---------------------------------------------------------

    private fun dnsServers(): List<String> {
        val cm = ctx.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val out = LinkedHashSet<String>()
        try {
            val net = cm.activeNetwork
            val lp = if (net != null) cm.getLinkProperties(net) else null
            lp?.dnsServers?.forEach { a -> a.hostAddress?.let { out.add(it.substringBefore('%')) } }
        } catch (e: Throwable) {
            Hub.log("dns lookup failed", e)
        }
        return out.toList()
    }

    private fun watchNetwork() {
        if (netRegistered) return
        netRegistered = true
        val cm = ctx.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val cb = object : ConnectivityManager.NetworkCallback() {
            private fun changed() {
                val d = dnsServers()
                if (d != lastDns) {
                    lastDns = d
                    Hub.emit("dns", "servers" to d)
                }
            }
            override fun onAvailable(network: Network) = changed()
            override fun onLinkPropertiesChanged(network: Network, lp: android.net.LinkProperties) = changed()
            override fun onLost(network: Network) = changed()
        }
        try {
            cm.registerDefaultNetworkCallback(cb)
        } catch (e: Throwable) {
            Hub.log("network callback failed", e)
            netRegistered = false
        }
    }

    // ---- screen ------------------------------------------------------------------

    fun applyKeepScreenOn() {
        val a = Hub.activity ?: return
        a.runOnUiThread {
            if (keepOn) a.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            else a.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }

    // ---- contacts ----------------------------------------------------------------

    private fun readContacts(): List<Map<String, Any?>> {
        if (!granted(Manifest.permission.READ_CONTACTS)) return emptyList()
        val byId = LinkedHashMap<Long, Pair<String, MutableList<Map<String, String>>>>()
        val proj = arrayOf(
            ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER,
            ContactsContract.CommonDataKinds.Phone.TYPE,
            ContactsContract.CommonDataKinds.Phone.LABEL,
        )
        ctx.contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI, proj, null, null,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " COLLATE NOCASE ASC",
        )?.use { c ->
            while (c.moveToNext()) {
                val id = c.getLong(0)
                val name = c.getString(1) ?: ""
                val num = c.getString(2) ?: continue
                val label = ContactsContract.CommonDataKinds.Phone.getTypeLabel(
                    ctx.resources, c.getInt(3), c.getString(4),
                ).toString()
                byId.getOrPut(id) { Pair(name, ArrayList()) }.second.add(mapOf("number" to num, "label" to label))
            }
        }
        return byId.map { (id, v) -> mapOf("id" to id.toString(), "name" to v.first, "numbers" to v.second) }
    }

    // ---- method calls --------------------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            handle(call, result)
        } catch (e: Throwable) {
            Hub.log("method ${call.method} failed", e)
            result.error("native", e.message, null)
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        fun s(k: String) = call.argument<String>(k) ?: ""
        when (call.method) {
            "init" -> {
                AudioRouter.init()
                NotificationHelper.ensureChannels(ctx)
                TelecomHub.register(ctx)
                watchNetwork()
                result.success(statusMap())
            }
            "permissions" -> result.success(statusMap())
            "requestPermissions" -> {
                val l = ArrayList<String>()
                l.add(Manifest.permission.RECORD_AUDIO)
                notifPerm()?.let { l.add(it) }
                btPerm()?.let { l.add(it) }
                if (call.argument<Boolean>("contacts") == true) l.add(Manifest.permission.READ_CONTACTS)
                requestPerms(l, result)
            }
            "requestContactsPermission" -> requestPerms(listOf(Manifest.permission.READ_CONTACTS), result)
            "readContacts" -> Thread { val r = readContacts(); Hub.post { result.success(r) } }.start()
            "openFullScreenIntentSettings" -> result.success(
                startSettings(
                    if (Build.VERSION.SDK_INT >= 34) Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, Uri.parse("package:${ctx.packageName}")) else appDetails(),
                    appDetails(),
                ),
            )
            "openNotificationSettings" -> result.success(
                startSettings(Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, ctx.packageName), appDetails()),
            )
            "openAppSettings" -> result.success(startSettings(appDetails()))
            "isIgnoringBatteryOptimizations" -> result.success(ignoringBattery())
            "requestIgnoreBatteryOptimizations" -> result.success(
                startSettings(
                    Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:${ctx.packageName}")),
                    Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS),
                ),
            )
            "openAutostartSettings" -> result.success(startSettings(*autostartIntents().toTypedArray()))
            "hasAutostartSettings" -> result.success(autostartIntents().isNotEmpty())
            "getDnsServers" -> result.success(dnsServers())
            "audioEffectsAvailable" -> result.success(mapOf(
                "noiseSuppressor" to android.media.audiofx.NoiseSuppressor.isAvailable(),
                "echoCanceler" to android.media.audiofx.AcousticEchoCanceler.isAvailable()
            ))

            "showIncoming" -> {
                NotificationHelper.showIncomingCall(ctx, s("callKey"), s("title"), s("body"), call.argument<String>("account"))
                result.success(null)
            }
            "cancelIncoming" -> { NotificationHelper.cancelCall(ctx, s("callKey")); result.success(null) }
            "showMissed" -> { NotificationHelper.missedCall(ctx, s("title"), s("body"), call.argument<String>("payload")); result.success(null) }
            "showMessage" -> { NotificationHelper.message(ctx, s("title"), s("body"), call.argument<String>("payload")); result.success(null) }

            "startRingtone" -> {
                Ringer.start(ctx, call.argument<String>("ringtone") ?: "default", (call.argument<Double>("volume") ?: 1.0).toFloat())
                result.success(null)
            }
            "stopRingtone" -> { Ringer.stop(); result.success(null) }

            "availableRoutes" -> result.success(AudioRouter.available())
            "getRoute" -> result.success(AudioRouter.current())
            "setRoute" -> { AudioRouter.set(s("route")); result.success(null) }
            "setProximity" -> { Proximity.wanted = call.argument<Boolean>("enabled") == true; Proximity.update(); result.success(null) }
            "setKeepScreenOn" -> { keepOn = call.argument<Boolean>("enabled") == true; applyKeepScreenOn(); result.success(null) }

            "startCallService" -> {
                SipService.inCall = true
                SipService.callText = s("text").ifEmpty { "Call in progress" }
                SipService.callKey = TelecomHub.anyKey()
                Prefs.of(ctx).edit().putBoolean(Prefs.SERVICE_WANTED, true).apply()
                Locks.setInCall(true)
                SipService.start(ctx)
                result.success(null)
            }
            "stopCallService" -> {
                SipService.inCall = false
                SipService.callKey = null
                Locks.setInCall(false)
                if (Prefs.of(ctx).getBoolean(Prefs.SERVICE_WANTED, false)) SipService.start(ctx) else SipService.stop(ctx)
                result.success(null)
            }
            "setBackgroundService" -> {
                val on = call.argument<Boolean>("enabled") == true
                Prefs.of(ctx).edit().putBoolean(Prefs.SERVICE_WANTED, on)
                    .putInt(Prefs.ONLINE, call.argument<Int>("online") ?: 0)
                    .putInt(Prefs.TOTAL, call.argument<Int>("total") ?: 0).apply()
                if (on) SipService.start(ctx) else if (!SipService.inCall) SipService.stop(ctx)
                result.success(null)
            }
            "setIdleWakeLock" -> {
                val on = call.argument<Boolean>("enabled") == true
                Prefs.of(ctx).edit().putBoolean(Prefs.IDLE_WAKELOCK, on).apply()
                if (SipService.running) Locks.setIdleWake(on)
                result.success(null)
            }
            "idleWakeLock" -> result.success(Prefs.of(ctx).getBoolean(Prefs.IDLE_WAKELOCK, false))
            "setMulticast" -> { Locks.setMulticast(call.argument<Boolean>("enabled") == true); result.success(null) }
            "setStartAtBoot" -> {
                Prefs.of(ctx).edit().putBoolean(Prefs.START_AT_BOOT, call.argument<Boolean>("enabled") == true).apply()
                result.success(null)
            }
            "startAtBoot" -> result.success(Prefs.of(ctx).getBoolean(Prefs.START_AT_BOOT, false))

            "telecomIncoming" -> { TelecomHub.reportIncoming(ctx, s("callKey"), s("handle"), s("name")); result.success(null) }
            "telecomOutgoing" -> {
                activeCalls.add(s("callKey"))
                AudioRouter.begin()
                TelecomHub.reportOutgoing(ctx, s("callKey"), s("handle"), s("name"))
                result.success(null)
            }
            "callConnected" -> {
                val key = s("callKey")
                activeCalls.add(key)
                AudioRouter.begin()
                TelecomHub.connected(key)
                NotificationHelper.showOngoingCall(ctx, key)
                if (SipService.inCall) SipService.callKey = key
                result.success(null)
            }
            "callEnded" -> {
                val key = s("callKey")
                TelecomHub.ended(key, call.argument<String>("reason") ?: "remoteEnded")
                activeCalls.remove(key)
                NotificationHelper.cancelCall(ctx, key)
                if (activeCalls.isEmpty() && TelecomHub.connections.isEmpty()) AudioRouter.end()
                Proximity.update()
                result.success(null)
            }

            "initialLink" -> { result.success(MainActivity.launchLink); MainActivity.launchLink = null }
            "bringToFront" -> {
                if (Hub.activity == null) {
                    try {
                        ctx.startActivity(
                            Intent(ctx, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                                .putExtra(MainActivity.EXTRA_INCOMING, true),
                        )
                    } catch (e: Throwable) {
                        Hub.log("bringToFront blocked", e)
                    }
                } else {
                    Hub.activity?.runOnUiThread { Hub.activity?.showOverLockScreen(true) }
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private val activeCalls = HashSet<String>()

    /** A call was answered from the system UI: take the audio mode right away. */
    fun markActive(key: String) {
        activeCalls.add(key)
        AudioRouter.begin()
    }
}
