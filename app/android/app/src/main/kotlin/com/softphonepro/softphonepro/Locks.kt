package com.softphonepro.softphonepro

import android.content.Context
import android.net.wifi.WifiManager
import android.os.Build
import android.os.PowerManager

/** Wake / Wi-Fi / multicast locks. All methods are idempotent. */
object Locks {
    private var cpu: PowerManager.WakeLock? = null
    private var wifi: WifiManager.WifiLock? = null
    private var multicast: WifiManager.MulticastLock? = null
    private var idleCpu: PowerManager.WakeLock? = null
    private var inCall = false

    private fun pm() = Hub.app.getSystemService(Context.POWER_SERVICE) as PowerManager
    private fun wm() = Hub.app.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

    @Synchronized
    fun setInCall(on: Boolean) {
        if (on == inCall) return
        inCall = on
        try {
            if (on) {
                if (cpu == null) cpu = pm().newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "softphonepro:call").apply { setReferenceCounted(false) }
                cpu?.acquire(4 * 60 * 60 * 1000L)
                if (wifi == null) {
                    val mode = if (Build.VERSION.SDK_INT >= 29) WifiManager.WIFI_MODE_FULL_LOW_LATENCY
                    else @Suppress("DEPRECATION") WifiManager.WIFI_MODE_FULL_HIGH_PERF
                    wifi = wm().createWifiLock(mode, "softphonepro:call").apply { setReferenceCounted(false) }
                }
                wifi?.acquire()
            } else {
                if (cpu?.isHeld == true) cpu?.release()
                if (wifi?.isHeld == true) wifi?.release()
            }
        } catch (e: Throwable) {
            Hub.log("call locks failed", e)
        }
    }

    /** Optional: keep the CPU awake while idle-registered (unreliable networks). */
    @Synchronized
    fun setIdleWake(on: Boolean) {
        try {
            if (on) {
                if (idleCpu == null) idleCpu = pm().newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "softphonepro:idle").apply { setReferenceCounted(false) }
                if (idleCpu?.isHeld != true) idleCpu?.acquire()
            } else if (idleCpu?.isHeld == true) idleCpu?.release()
        } catch (e: Throwable) {
            Hub.log("idle wakelock failed", e)
        }
    }

    @Synchronized
    fun setMulticast(on: Boolean) {
        try {
            if (on) {
                if (multicast == null) multicast = wm().createMulticastLock("softphonepro:lan").apply { setReferenceCounted(false) }
                if (multicast?.isHeld != true) multicast?.acquire()
            } else if (multicast?.isHeld == true) multicast?.release()
        } catch (e: Throwable) {
            Hub.log("multicast lock failed", e)
        }
    }

    fun multicastHeld() = multicast?.isHeld == true
}
