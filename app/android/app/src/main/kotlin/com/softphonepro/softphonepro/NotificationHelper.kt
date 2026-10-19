package com.softphonepro.softphonepro

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person

object NotificationHelper {
    const val CH_SERVICE = "service"
    const val CH_INCOMING = "incoming_calls"
    const val CH_ONGOING = "ongoing_calls"
    const val CH_MISSED = "missed_calls"
    const val CH_MESSAGES = "messages"

    const val ID_SERVICE = 1
    private const val ID_CALL_BASE = 1000
    private var seq = 5000

    /** callKey -> info needed to rebuild the notification as "ongoing". */
    private val calls = HashMap<String, Pair<String, String>>()

    fun callId(key: String) = ID_CALL_BASE + (key.hashCode() and 0x3FFF)

    fun ensureChannels(ctx: Context) {
        if (Build.VERSION.SDK_INT < 26) return
        val nm = ctx.getSystemService(NotificationManager::class.java)
        fun ch(id: String, name: Int, imp: Int, desc: Int? = null, cfg: NotificationChannel.() -> Unit = {}) {
            val c = NotificationChannel(id, ctx.getString(name), imp)
            if (desc != null) c.description = ctx.getString(desc)
            c.cfg()
            nm.createNotificationChannel(c)
        }
        ch(CH_SERVICE, R.string.ch_service, NotificationManager.IMPORTANCE_LOW, R.string.ch_service_desc) { setShowBadge(false) }
        // The app plays the ringtone itself (respecting ringer mode), so the channel is silent.
        ch(CH_INCOMING, R.string.ch_incoming, NotificationManager.IMPORTANCE_HIGH, R.string.ch_incoming_desc) {
            setSound(null, null); enableVibration(false); setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        ch(CH_ONGOING, R.string.ch_ongoing, NotificationManager.IMPORTANCE_LOW) { setShowBadge(false) }
        ch(CH_MISSED, R.string.ch_missed, NotificationManager.IMPORTANCE_DEFAULT)
        ch(CH_MESSAGES, R.string.ch_messages, NotificationManager.IMPORTANCE_DEFAULT)
    }

    private fun flags() = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT

    private fun activityIntent(ctx: Context, req: Int, configure: Intent.() -> Unit): PendingIntent {
        val i = Intent(ctx, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            configure()
        }
        return PendingIntent.getActivity(ctx, req, i, flags())
    }

    private fun broadcast(ctx: Context, req: Int, action: String, key: String): PendingIntent {
        val i = Intent(ctx, CallActionReceiver::class.java).setAction(action).putExtra(MainActivity.EXTRA_CALL_KEY, key)
        return PendingIntent.getBroadcast(ctx, req, i, flags())
    }

    fun openAppIntent(ctx: Context): PendingIntent = activityIntent(ctx, 1) {}

    private fun canNotify(ctx: Context): Boolean = NotificationManagerCompat.from(ctx).areNotificationsEnabled()

    private fun notify(ctx: Context, id: Int, n: Notification) {
        try {
            if (canNotify(ctx)) NotificationManagerCompat.from(ctx).notify(id, n)
        } catch (e: Throwable) {
            // SecurityException (no permission) or IllegalArgumentException (CallStyle rules): never crash.
            Hub.log("notify failed", e)
        }
    }

    // ---- service ------------------------------------------------------------

    fun service(ctx: Context, title: String, text: String, inCall: Boolean, callKey: String?): Notification {
        ensureChannels(ctx)
        val b = NotificationCompat.Builder(ctx, CH_SERVICE)
            .setSmallIcon(R.drawable.ic_stat_phone)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(if (inCall) NotificationCompat.CATEGORY_CALL else NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(openAppIntent(ctx))
            .addAction(0, ctx.getString(R.string.act_open), openAppIntent(ctx))
        if (inCall && callKey != null) {
            b.addAction(0, ctx.getString(R.string.act_hangup), broadcast(ctx, 4, CallActionReceiver.ACTION_END, callKey))
        }
        return b.build()
    }

    // ---- calls --------------------------------------------------------------

    fun showIncomingCall(ctx: Context, key: String, title: String, body: String, account: String?) {
        ensureChannels(ctx)
        calls[key] = Pair(title, body)
        val fs = activityIntent(ctx, callId(key)) {
            putExtra(MainActivity.EXTRA_CALL_KEY, key)
            putExtra(MainActivity.EXTRA_INCOMING, true)
        }
        val answer = activityIntent(ctx, callId(key) + 20000) {
            action = MainActivity.ACTION_ANSWER
            putExtra(MainActivity.EXTRA_CALL_KEY, key)
            putExtra(MainActivity.EXTRA_INCOMING, true)
        }
        val decline = broadcast(ctx, callId(key) + 30000, CallActionReceiver.ACTION_DECLINE, key)
        val b = NotificationCompat.Builder(ctx, CH_INCOMING)
            .setSmallIcon(R.drawable.ic_stat_phone)
            .setContentTitle(title)
            .setContentText(body)
            .setSubText(account)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setContentIntent(fs)
            .setFullScreenIntent(fs, true)
        if (Build.VERSION.SDK_INT >= 31) {
            val person = Person.Builder().setName(title).setImportant(true).build()
            b.setStyle(NotificationCompat.CallStyle.forIncomingCall(person, decline, answer))
        } else {
            b.addAction(0, ctx.getString(R.string.act_decline), decline)
            b.addAction(0, ctx.getString(R.string.act_answer), answer)
        }
        notify(ctx, callId(key), b.build())
    }

    /** Replaces the incoming-call notification by an ongoing one with a hang-up action. */
    fun showOngoingCall(ctx: Context, key: String) {
        val info = calls[key] ?: return
        ensureChannels(ctx)
        val hang = broadcast(ctx, callId(key) + 40000, CallActionReceiver.ACTION_END, key)
        val b = NotificationCompat.Builder(ctx, CH_ONGOING)
            .setSmallIcon(R.drawable.ic_stat_phone)
            .setContentTitle(info.first)
            .setContentText("Call in progress")
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setUsesChronometer(true)
            .setContentIntent(openAppIntent(ctx))
        // Not CallStyle: the platform only accepts it for foreground-service / full-screen
        // notifications, and the foreground service already carries the call UI.
        b.addAction(0, ctx.getString(R.string.act_hangup), hang)
        notify(ctx, callId(key), b.build())
    }

    fun cancelCall(ctx: Context, key: String) {
        calls.remove(key)
        NotificationManagerCompat.from(ctx).cancel(callId(key))
    }

    // ---- missed / messages -----------------------------------------------------

    private fun simple(ctx: Context, channel: String, title: String, body: String, route: String, group: String) {
        ensureChannels(ctx)
        val id = seq++
        val pi = activityIntent(ctx, id) {
            action = MainActivity.ACTION_OPEN_ROUTE
            putExtra(MainActivity.EXTRA_ROUTE, route)
        }
        val b = NotificationCompat.Builder(ctx, channel)
            .setSmallIcon(R.drawable.ic_stat_phone)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setGroup(group)
            .setContentIntent(pi)
            .setCategory(if (channel == CH_MISSED) NotificationCompat.CATEGORY_MISSED_CALL else NotificationCompat.CATEGORY_MESSAGE)
        notify(ctx, id, b.build())
    }

    fun missedCall(ctx: Context, title: String, body: String, route: String?) =
        simple(ctx, CH_MISSED, title, body, route ?: "/recents", "missed")

    fun message(ctx: Context, title: String, body: String, route: String?) =
        simple(ctx, CH_MESSAGES, title, body, route ?: "/messages", "messages")
}
