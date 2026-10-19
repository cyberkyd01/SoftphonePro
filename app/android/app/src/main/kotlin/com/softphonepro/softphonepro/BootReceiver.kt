package com.softphonepro.softphonepro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Starts the background service (and with it the Dart engine) after boot / app update. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Hub.init(context)
        val p = Prefs.of(context)
        if (p.getBoolean(Prefs.START_AT_BOOT, false) || (intent.action == Intent.ACTION_MY_PACKAGE_REPLACED && p.getBoolean(Prefs.SERVICE_WANTED, false))) {
            SipService.start(context, boot = true)
        }
    }
}
