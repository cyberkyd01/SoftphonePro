package com.softphonepro.softphonepro

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * Foreground service that keeps the process (and the Dart isolate running
 * libspcore) alive so SIP accounts stay registered.
 *
 * Foreground service type choice (see report):
 *  - idle:    API 34+ `specialUse` (allowed from BOOT_COMPLETED, no time limit);
 *             API 29-33 `dataSync` (no restrictions before 34).
 *  - in call: `phoneCall` (+ `microphone` when it may be started).
 */
class SipService : Service() {
    companion object {
        const val EXTRA_BOOT = "boot"
        @Volatile var running = false

        // Live state shown in the notification.
        @Volatile var inCall = false
        @Volatile var callKey: String? = null
        @Volatile var callText = "Call in progress"

        fun start(ctx: Context, boot: Boolean = false) {
            Hub.init(ctx)
            try {
                ContextCompat.startForegroundService(ctx, Intent(ctx, SipService::class.java).putExtra(EXTRA_BOOT, boot))
            } catch (e: Throwable) {
                // ForegroundServiceStartNotAllowedException etc: app is in the background.
                Hub.log("cannot start SipService now", e)
            }
        }

        fun stop(ctx: Context) {
            ctx.stopService(Intent(ctx, SipService::class.java))
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        Hub.init(this)
        NotificationHelper.ensureChannels(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        running = true
        promote()
        // Make sure the Dart side exists (boot, or sticky restart after the process was killed).
        Hub.post {
            try {
                EngineHolder.ensure(this)
            } catch (e: Throwable) {
                Hub.log("engine start failed", e)
            }
        }
        Locks.setIdleWake(Prefs.of(this).getBoolean(Prefs.IDLE_WAKELOCK, false))
        return START_STICKY
    }

    private fun notificationParts(): Pair<String, String> {
        val p = Prefs.of(this)
        val online = p.getInt(Prefs.ONLINE, 0)
        val total = p.getInt(Prefs.TOTAL, 0)
        val title = when {
            inCall -> "SoftphonePro — $callText"
            total == 0 -> "SoftphonePro — no accounts"
            else -> "SoftphonePro — $online ${if (online == 1) "account" else "accounts"} online"
        }
        val text = if (inCall) "Tap to return to the call" else "Staying registered to receive calls"
        return Pair(title, text)
    }

    fun promote() {
        val (title, text) = notificationParts()
        val n = NotificationHelper.service(this, title, text, inCall, callKey)
        val candidates: List<Int> = if (Build.VERSION.SDK_INT < 29) listOf(0) else if (inCall) {
            val mic = if (Build.VERSION.SDK_INT >= 30) ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE else 0
            listOf(ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL or mic, ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL, idleType())
        } else listOf(idleType())
        var ok = false
        for (t in candidates) {
            try {
                ServiceCompat.startForeground(this, NotificationHelper.ID_SERVICE, n, t)
                ok = true
                break
            } catch (e: Throwable) {
                Hub.log("startForeground(type=$t) refused", e)
            }
        }
        if (!ok) {
            // Never leave the 5 s startForeground contract unfulfilled.
            try {
                startForeground(NotificationHelper.ID_SERVICE, n)
            } catch (e: Throwable) {
                Hub.log("startForeground failed, stopping", e)
                stopSelf()
            }
        }
    }

    private fun idleType(): Int = when {
        Build.VERSION.SDK_INT >= 34 -> ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        Build.VERSION.SDK_INT >= 29 -> ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        else -> 0
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Swiping the app from recents must not stop registration.
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        running = false
        Locks.setIdleWake(false)
        if (Hub.activity == null) Locks.releaseAllMulticast()
        super.onDestroy()
    }
}
