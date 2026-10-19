package com.softphonepro.softphonepro

import android.content.Context
import android.content.SharedPreferences

object Prefs {
    const val START_AT_BOOT = "start_at_boot"
    const val SERVICE_WANTED = "service_wanted"
    const val ONLINE = "svc_online"
    const val TOTAL = "svc_total"
    const val IDLE_WAKELOCK = "idle_wakelock"
    private const val NONCE = "intent_nonce"
    @Volatile private var nonceCache: String? = null

    /**
     * Random secret that only this app's own PendingIntents carry. MainActivity is exported
     * (link handler), so privileged actions (answer, open route, show-over-lockscreen)
     * require it. Persisted so notifications survive a process restart.
     */
    @Synchronized
    fun intentNonce(ctx: Context): String {
        nonceCache?.let { return it }
        val sp = of(ctx)
        var n = sp.getString(NONCE, null)
        if (n == null) {
            val b = ByteArray(24)
            java.security.SecureRandom().nextBytes(b)
            n = android.util.Base64.encodeToString(b, android.util.Base64.NO_WRAP or android.util.Base64.URL_SAFE)
            sp.edit().putString(NONCE, n).apply()
        }
        nonceCache = n
        return n
    }

    fun of(ctx: Context): SharedPreferences = ctx.getSharedPreferences("softphonepro_native", Context.MODE_PRIVATE)
}
