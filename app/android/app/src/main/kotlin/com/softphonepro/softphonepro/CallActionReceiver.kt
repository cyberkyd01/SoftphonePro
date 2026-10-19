package com.softphonepro.softphonepro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Decline / hang-up buttons of call notifications. */
class CallActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_DECLINE = "com.softphonepro.action.DECLINE"
        const val ACTION_END = "com.softphonepro.action.END"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Hub.init(context)
        val key = intent.getStringExtra(MainActivity.EXTRA_CALL_KEY) ?: return
        val kind = if (intent.action == ACTION_DECLINE) "decline" else "end"
        if (kind == "decline") NotificationHelper.cancelCall(context, key)
        Hub.emit("callAction", "kind" to kind, "callKey" to key)
    }
}
