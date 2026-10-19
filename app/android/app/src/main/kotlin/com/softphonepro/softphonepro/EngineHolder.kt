package com.softphonepro.softphonepro

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * The single FlutterEngine / Dart isolate that drives libspcore. It is created
 * by whoever needs it first (the activity, or SipService after boot) and
 * outlives the activity, so SIP registration keeps working in the background.
 * Must be called on the main thread.
 */
object EngineHolder {
    const val ID = "main"

    /** The engine we created and have not seen destroyed; cleared by the lifecycle listener. */
    @Volatile
    private var live: FlutterEngine? = null

    fun ensure(ctx: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        cache.get(ID)?.let { e ->
            if (e === live) return e
            // Engine was destroyed behind our back: drop it and build a fresh one (new isolate,
            // plugins re-registered by the FlutterEngine constructor, channels re-bound below).
            Hub.log("cached Flutter engine is dead; recreating")
            cache.remove(ID)
            Hub.resetForNewEngine()
            try { e.destroy() } catch (_: Throwable) {}
        }
        val app = ctx.applicationContext
        Hub.init(app)
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationComplete(app, null)
        val engine = FlutterEngine(app)
        engine.addEngineLifecycleListener(object : FlutterEngine.EngineLifecycleListener {
            override fun onPreEngineRestart() {}
            override fun onEngineWillDestroy() {
                if (live === engine) live = null
                cache.remove(ID)
                Hub.resetForNewEngine()
                Hub.log("Flutter engine destroyed")
            }
        })
        live = engine
        PlatformBridge.register(engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        cache.put(ID, engine)
        Hub.log("Flutter engine started (headless=${Hub.activity == null})")
        return engine
    }
}
