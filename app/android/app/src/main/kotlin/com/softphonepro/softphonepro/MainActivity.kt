package com.softphonepro.softphonepro

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    companion object {
        const val ACTION_ANSWER = "com.softphonepro.action.ANSWER"
        const val ACTION_OPEN_ROUTE = "com.softphonepro.action.OPEN_ROUTE"
        const val EXTRA_CALL_KEY = "callKey"
        const val EXTRA_INCOMING = "incoming"
        const val EXTRA_ROUTE = "route"

        /** Link that launched the process, consumed by initialLink(). */
        @Volatile
        var launchLink: String? = null
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        return EngineHolder.ensure(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }

    // Keep the engine (and with it the Dart isolate running libspcore) alive.
    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        Hub.init(this)
        Hub.activity = this
        super.onCreate(savedInstanceState)
        handleIntent(intent, cold = !Hub.dartAttached)
        PlatformBridge.applyKeepScreenOn()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent, cold = false)
    }

    override fun onResume() {
        super.onResume()
        Hub.activity = this
        PlatformBridge.applyKeepScreenOn()
    }

    override fun onStop() {
        super.onStop()
        // Only show over the lock screen while an incoming call is on screen.
        showOverLockScreen(false)
    }

    override fun onDestroy() {
        if (Hub.activity === this) Hub.activity = null
        super.onDestroy()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        PlatformBridge.onPermissionsResult(requestCode)
    }

    @Suppress("DEPRECATION")
    fun showOverLockScreen(show: Boolean) {
        if (Build.VERSION.SDK_INT >= 27) {
            setShowWhenLocked(show)
            setTurnScreenOn(show)
        } else {
            val f = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (show) window.addFlags(f) else window.clearFlags(f)
        }
        if (show) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }

    private fun handleIntent(i: Intent?, cold: Boolean) {
        if (i == null) return
        if (i.getBooleanExtra(EXTRA_INCOMING, false)) showOverLockScreen(true)
        when (i.action) {
            ACTION_ANSWER -> {
                val key = i.getStringExtra(EXTRA_CALL_KEY) ?: return
                showOverLockScreen(true)
                PlatformBridge.markActive(key)
                NotificationHelper.showOngoingCall(this, key)
                Hub.emit("callAction", "kind" to "answer", "callKey" to key)
                i.action = null
            }
            ACTION_OPEN_ROUTE -> {
                i.getStringExtra(EXTRA_ROUTE)?.let { Hub.emit("route", "route" to it) }
                i.action = null
            }
            Intent.ACTION_VIEW, Intent.ACTION_DIAL -> {
                val d: Uri = i.data ?: return
                if (cold) launchLink = d.toString() else Hub.emit("link", "uri" to d.toString())
                i.data = null
            }
        }
    }
}
