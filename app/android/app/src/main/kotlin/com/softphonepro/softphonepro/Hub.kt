package com.softphonepro.softphonepro

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel

/**
 * Process-wide rendezvous between native components (service, Telecom,
 * receivers, activity) and the Dart side. Events are queued until Dart
 * subscribes, so a notification action tapped before the isolate is ready is
 * not lost.
 */
object Hub {
    const val TAG = "SoftphonePro"
    lateinit var app: Context
        private set
    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private val queue = ArrayDeque<Map<String, Any?>>()

    @Volatile
    var activity: MainActivity? = null

    /** True once Dart has subscribed at least once. */
    @Volatile
    var dartAttached = false
        private set

    fun init(ctx: Context) {
        if (!::app.isInitialized) app = ctx.applicationContext
    }

    fun post(r: Runnable) {
        if (Looper.myLooper() == Looper.getMainLooper()) r.run() else main.post(r)
    }

    fun emit(type: String, vararg kv: Pair<String, Any?>) {
        val m = HashMap<String, Any?>()
        m["type"] = type
        for ((k, v) in kv) m[k] = v
        main.post {
            val s = sink
            if (s != null) {
                s.success(m)
            } else {
                queue.addLast(m)
                while (queue.size > 50) queue.removeFirst()
            }
        }
    }

    fun attach(s: EventChannel.EventSink) {
        log("dart attached")
        sink = s
        dartAttached = true
        while (queue.isNotEmpty()) s.success(queue.removeFirst())
    }

    fun detach() {
        sink = null
    }

    fun log(msg: String, t: Throwable? = null) {
        if (t != null) Log.w(TAG, msg, t) else Log.i(TAG, msg)
    }
}
