package com.softphonepro.softphonepro

import android.content.Context
import android.content.SharedPreferences

object Prefs {
    const val START_AT_BOOT = "start_at_boot"
    const val SERVICE_WANTED = "service_wanted"
    const val ONLINE = "svc_online"
    const val TOTAL = "svc_total"
    const val IDLE_WAKELOCK = "idle_wakelock"
    fun of(ctx: Context): SharedPreferences = ctx.getSharedPreferences("softphonepro_native", Context.MODE_PRIVATE)
}
