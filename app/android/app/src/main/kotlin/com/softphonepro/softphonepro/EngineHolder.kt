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
    private const val ID = "main"

    fun ensure(ctx: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        cache.get(ID)?.let { return it }
        val app = ctx.applicationContext
        Hub.init(app)
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationComplete(app, null)
        val engine = FlutterEngine(app)
        PlatformBridge.register(engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        cache.put(ID, engine)
        Hub.log("Flutter engine started (headless=${Hub.activity == null})")
        return engine
    }
}
