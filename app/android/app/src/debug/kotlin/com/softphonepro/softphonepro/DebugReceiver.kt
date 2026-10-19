package com.softphonepro.softphonepro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Debug/profile builds only. Mimics what Dart does when a call arrives / ends. */
class DebugReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Hub.init(context)
        val key = intent.getStringExtra("key") ?: "7777"
        val name = intent.getStringExtra("name") ?: "Debug Caller"
        when (intent.action) {
            "com.softphonepro.debug.INCOMING" -> {
                TelecomHub.reportIncoming(context, key, "1001", name)
                NotificationHelper.showIncomingCall(context, key, name, "Incoming call on Debug", "Debug")
                Ringer.start(context, "default", 1f)
                SipService.inCall = true
                Locks.setInCall(true)
                SipService.start(context)
            }
            "com.softphonepro.debug.CONNECTED" -> {
                Ringer.stop()
                TelecomHub.connected(key)
                AudioRouter.begin()
                NotificationHelper.showOngoingCall(context, key)
            }
            "com.softphonepro.debug.END" -> {
                Ringer.stop()
                TelecomHub.ended(key, "remoteEnded")
                NotificationHelper.cancelCall(key = key, ctx = context)
                AudioRouter.end()
                SipService.inCall = false
                Locks.setInCall(false)
                SipService.start(context)
            }
            "com.softphonepro.debug.ROUTE" -> AudioRouter.set(intent.getStringExtra("route") ?: "speaker")
        }
    }
}
