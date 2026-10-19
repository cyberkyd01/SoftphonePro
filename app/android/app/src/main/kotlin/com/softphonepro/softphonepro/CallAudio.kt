package com.softphonepro.softphonepro

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/** Audio mode, focus and output routing for calls. Main thread only. */
object AudioRouter {
    private val am get() = Hub.app.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var active = false
    private var savedMode = AudioManager.MODE_NORMAL
    private var focus: AudioFocusRequest? = null
    private var desired: String? = null
    private var registered = false
    private var lastEmitted: String? = null
    private val handler = Handler(Looper.getMainLooper())

    private val callback = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>?) = devicesChanged(true)
        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>?) = devicesChanged(false)
    }

    fun init() {
        if (registered) return
        registered = true
        am.registerAudioDeviceCallback(callback, handler)
    }

    private fun outputs(): Array<AudioDeviceInfo> = am.getDevices(AudioManager.GET_DEVICES_OUTPUTS)

    private fun routeOf(d: AudioDeviceInfo): String? = when (d.type) {
        AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> "earpiece"
        AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> "speaker"
        AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> "bluetooth"
        AudioDeviceInfo.TYPE_WIRED_HEADSET, AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
        AudioDeviceInfo.TYPE_USB_HEADSET -> "wired"
        else -> if (Build.VERSION.SDK_INT >= 31 && (d.type == AudioDeviceInfo.TYPE_BLE_HEADSET)) "bluetooth"
        else if (Build.VERSION.SDK_INT >= 26 && d.type == AudioDeviceInfo.TYPE_HEARING_AID) "bluetooth"
        else null
    }

    fun available(): List<String> {
        val s = LinkedHashSet<String>()
        for (d in outputs()) routeOf(d)?.let { s.add(it) }
        if (s.isEmpty()) s.add("speaker")
        return s.toList()
    }

    fun current(): String {
        if (Build.VERSION.SDK_INT >= 31 && active) {
            am.communicationDevice?.let { d -> routeOf(d)?.let { return it } }
        }
        @Suppress("DEPRECATION")
        return when {
            am.isBluetoothScoOn -> "bluetooth"
            am.isSpeakerphoneOn -> "speaker"
            available().contains("wired") -> "wired"
            available().contains("earpiece") -> "earpiece"
            else -> "speaker"
        }
    }

    private fun devicesChanged(added: Boolean) {
        if (active) {
            // Plug-in of a headset / BT device while in a call switches to it; removal falls back.
            val av = available()
            if (added) {
                if (av.contains("wired") && desired != "speaker") applyRoute("wired")
                else if (av.contains("bluetooth") && desired != "speaker") applyRoute("bluetooth")
            } else if (desired != null && !av.contains(desired!!)) {
                applyRoute(if (av.contains("earpiece")) "earpiece" else "speaker")
            }
        }
        emitIfChanged()
    }

    fun emitIfChanged() {
        val c = current()
        if (c != lastEmitted) {
            lastEmitted = c
            Hub.emit("audioRoute", "route" to c)
            Proximity.update()
        }
    }

    fun set(route: String) {
        desired = route
        if (active) applyRoute(route)
        // Not in a call: remembered and applied when the call starts.
        emitIfChanged()
    }

    private fun applyRoute(route: String) {
        try {
            if (Build.VERSION.SDK_INT >= 31) {
                val want = when (route) {
                    "earpiece" -> listOf(AudioDeviceInfo.TYPE_BUILTIN_EARPIECE)
                    "speaker" -> listOf(AudioDeviceInfo.TYPE_BUILTIN_SPEAKER)
                    "bluetooth" -> listOf(AudioDeviceInfo.TYPE_BLUETOOTH_SCO, AudioDeviceInfo.TYPE_BLE_HEADSET, AudioDeviceInfo.TYPE_HEARING_AID)
                    else -> listOf(AudioDeviceInfo.TYPE_WIRED_HEADSET, AudioDeviceInfo.TYPE_WIRED_HEADPHONES, AudioDeviceInfo.TYPE_USB_HEADSET)
                }
                val dev = am.availableCommunicationDevices.firstOrNull { it.type in want }
                if (dev != null) am.setCommunicationDevice(dev) else am.clearCommunicationDevice()
            } else {
                @Suppress("DEPRECATION")
                run {
                    when (route) {
                        "speaker" -> { stopSco(); am.isSpeakerphoneOn = true }
                        "bluetooth" -> { am.isSpeakerphoneOn = false; am.startBluetoothSco(); am.isBluetoothScoOn = true }
                        else -> { stopSco(); am.isSpeakerphoneOn = false }
                    }
                }
            }
        } catch (e: Throwable) {
            Hub.log("applyRoute($route) failed", e)
        }
        handler.postDelayed({ emitIfChanged() }, 150)
    }

    @Suppress("DEPRECATION")
    private fun stopSco() {
        if (am.isBluetoothScoOn) {
            am.isBluetoothScoOn = false
            am.stopBluetoothSco()
        }
    }

    val isActive get() = active

    fun begin() {
        if (active) return
        active = true
        try {
            savedMode = am.mode
            val attrs = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build()
            if (Build.VERSION.SDK_INT >= 26) {
                focus = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT).setAudioAttributes(attrs)
                    .setOnAudioFocusChangeListener { }.build()
                am.requestAudioFocus(focus!!)
            } else {
                @Suppress("DEPRECATION")
                am.requestAudioFocus(null, AudioManager.STREAM_VOICE_CALL, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            }
            am.mode = AudioManager.MODE_IN_COMMUNICATION
        } catch (e: Throwable) {
            Hub.log("audio begin failed", e)
        }
        val av = available()
        val pick = when {
            desired != null && av.contains(desired!!) && desired != "earpiece" -> desired!!
            av.contains("wired") -> "wired"
            av.contains("bluetooth") -> "bluetooth"
            av.contains("earpiece") -> "earpiece"
            else -> "speaker"
        }
        applyRoute(pick)
    }

    fun end() {
        if (!active) return
        active = false
        desired = null
        try {
            if (Build.VERSION.SDK_INT >= 31) am.clearCommunicationDevice()
            else {
                stopSco()
                @Suppress("DEPRECATION")
                am.isSpeakerphoneOn = false
            }
            am.mode = savedMode
            if (Build.VERSION.SDK_INT >= 26) focus?.let { am.abandonAudioFocusRequest(it) }
            else @Suppress("DEPRECATION") am.abandonAudioFocus(null)
            focus = null
        } catch (e: Throwable) {
            Hub.log("audio end failed", e)
        }
        emitIfChanged()
    }
}

/** Screen off next to the ear: only for earpiece routing. */
object Proximity {
    private var wl: PowerManager.WakeLock? = null
    var wanted = false

    fun update() {
        val pm = Hub.app.getSystemService(Context.POWER_SERVICE) as PowerManager
        val want = wanted && AudioRouter.current() == "earpiece"
        try {
            if (want) {
                if (wl == null && pm.isWakeLockLevelSupported(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK)) {
                    wl = pm.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, "softphonepro:proximity").apply { setReferenceCounted(false) }
                }
                if (wl?.isHeld != true) wl?.acquire(4 * 60 * 60 * 1000L)
            } else if (wl?.isHeld == true) {
                wl?.release()
            }
        } catch (e: Throwable) {
            Hub.log("proximity failed", e)
        }
    }
}

/** System ringtone + vibration, honouring silent / vibrate ringer modes. */
object Ringer {
    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null

    @Synchronized
    fun start(ctx: Context, ringtone: String, volume: Float) {
        stop()
        val am = ctx.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val mode = am.ringerMode
        val uri: Uri? = if (ringtone.startsWith("content://") || ringtone.startsWith("file://")) Uri.parse(ringtone)
        else if (ringtone.startsWith("/")) Uri.fromFile(java.io.File(ringtone))
        else RingtoneManager.getActualDefaultRingtoneUri(ctx, RingtoneManager.TYPE_RINGTONE)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        if (mode == AudioManager.RINGER_MODE_NORMAL && uri != null) {
            try {
                player = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build(),
                    )
                    setDataSource(ctx, uri)
                    isLooping = true
                    val v = volume.coerceIn(0f, 1f)
                    setVolume(v, v)
                    prepare()
                    start()
                }
            } catch (e: Throwable) {
                Hub.log("ringtone failed", e)
                player?.release(); player = null
            }
        }
        if (mode != AudioManager.RINGER_MODE_SILENT) vibrate(ctx)
    }

    private fun vibrate(ctx: Context) {
        try {
            val v: Vibrator = if (Build.VERSION.SDK_INT >= 31) {
                (ctx.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
            } else @Suppress("DEPRECATION") (ctx.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator)
            if (!v.hasVibrator()) return
            val pattern = longArrayOf(0, 800, 800, 800, 1600)
            if (Build.VERSION.SDK_INT >= 26) v.vibrate(VibrationEffect.createWaveform(pattern, 0))
            else @Suppress("DEPRECATION") v.vibrate(pattern, 0)
            vibrator = v
        } catch (e: Throwable) {
            Hub.log("vibrate failed", e)
        }
    }

    @Synchronized
    fun stop() {
        try { player?.stop() } catch (_: Throwable) {}
        player?.release(); player = null
        try { vibrator?.cancel() } catch (_: Throwable) {}
        vibrator = null
    }
}
