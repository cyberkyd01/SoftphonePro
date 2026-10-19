package com.softphonepro.softphonepro

import android.content.ComponentName
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.telecom.CallAudioState
import android.telecom.Connection
import android.telecom.ConnectionRequest
import android.telecom.ConnectionService
import android.telecom.DisconnectCause
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager

/**
 * Self-managed Telecom integration: gives Bluetooth / car / headset-button
 * support and makes the platform aware of our calls (GSM call interplay).
 * Everything here is best effort; calls work without it.
 */
object TelecomHub {
    const val KEY = "spKey"
    val connections = HashMap<String, SpConnection>()
    private val pending = ArrayDeque<String>()
    private var registered = false

    private fun tm(ctx: Context) = ctx.getSystemService(Context.TELECOM_SERVICE) as TelecomManager

    fun handle(ctx: Context) = PhoneAccountHandle(ComponentName(ctx, SpConnectionService::class.java), "softphonepro")

    fun register(ctx: Context): Boolean {
        if (registered) return true
        return try {
            val acct = PhoneAccount.builder(handle(ctx), ctx.getString(R.string.phone_account_label))
                .setCapabilities(PhoneAccount.CAPABILITY_SELF_MANAGED)
                .addSupportedUriScheme(PhoneAccount.SCHEME_SIP)
                .addSupportedUriScheme(PhoneAccount.SCHEME_TEL)
                .build()
            tm(ctx).registerPhoneAccount(acct)
            registered = true
            true
        } catch (e: Throwable) {
            Hub.log("telecom register failed", e)
            false
        }
    }

    private fun uriFor(handle: String): Uri =
        if (handle.matches(Regex("^[+0-9*#]+$"))) Uri.fromParts(PhoneAccount.SCHEME_TEL, handle, null)
        else Uri.fromParts(PhoneAccount.SCHEME_SIP, handle.removePrefix("sip:"), null)

    fun reportIncoming(ctx: Context, key: String, handle: String, name: String) {
        if (!register(ctx)) return
        try {
            val extras = Bundle().apply {
                putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, uriFor(handle))
                putBundle(TelecomManager.EXTRA_INCOMING_CALL_EXTRAS, Bundle().apply {
                    putString(KEY, key); putString("name", name); putString("handle", handle)
                })
                putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, handle(ctx))
            }
            synchronized(pending) { pending.addLast("$key\u0000$name\u0000$handle") }
            tm(ctx).addNewIncomingCall(handle(ctx), extras)
        } catch (e: Throwable) {
            Hub.log("addNewIncomingCall refused", e)
        }
    }

    fun reportOutgoing(ctx: Context, key: String, handle: String, name: String) {
        if (!register(ctx)) return
        try {
            val extras = Bundle().apply {
                putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, handle(ctx))
                putBundle(TelecomManager.EXTRA_OUTGOING_CALL_EXTRAS, Bundle().apply {
                    putString(KEY, key); putString("name", name); putString("handle", handle)
                })
            }
            synchronized(pending) { pending.addLast("$key\u0000$name\u0000$handle") }
            tm(ctx).placeCall(uriFor(handle), extras)
        } catch (e: Throwable) {
            Hub.log("placeCall refused", e)
        }
    }

    fun takePending(): List<String>? = synchronized(pending) { pending.removeFirstOrNull()?.split('\u0000') }

    fun connected(key: String) {
        connections[key]?.let { c ->
            try { c.setActive() } catch (_: Throwable) {}
        }
    }

    fun ended(key: String, reason: String) {
        synchronized(pending) { pending.removeAll { it.startsWith("$key\u0000") } }
        val c = connections.remove(key) ?: return
        c.silent = true
        try {
            val code = when (reason) {
                "missed" -> DisconnectCause.MISSED
                "rejected", "declined" -> DisconnectCause.REJECTED
                "localEnded", "local" -> DisconnectCause.LOCAL
                "failed", "error" -> DisconnectCause.ERROR
                else -> DisconnectCause.REMOTE
            }
            c.setDisconnected(DisconnectCause(code))
            c.destroy()
        } catch (_: Throwable) {
        }
    }

    /** First active connection key, used for the notification's hang-up button. */
    fun anyKey(): String? = connections.keys.firstOrNull()
}

class SpConnection(val key: String) : Connection() {
    @Volatile var silent = false

    init {
        connectionProperties = PROPERTY_SELF_MANAGED
        connectionCapabilities = CAPABILITY_HOLD or CAPABILITY_SUPPORT_HOLD or CAPABILITY_MUTE
        audioModeIsVoip = true
    }

    private fun act(kind: String) {
        if (!silent) Hub.emit("callAction", "kind" to kind, "callKey" to key)
    }

    override fun onAnswer() {
        Hub.post {
            AudioRouter.begin()
            NotificationHelper.showOngoingCall(Hub.app, key)
        }
        act("answer")
    }

    override fun onAnswer(videoState: Int) = onAnswer()
    override fun onReject() = act("decline")
    override fun onReject(replyMessage: String?) = act("decline")
    override fun onDisconnect() {
        act("end")
        setDisconnected(DisconnectCause(DisconnectCause.LOCAL))
        destroy()
        TelecomHub.connections.remove(key)
    }

    override fun onAbort() {
        act("end")
    }

    override fun onHold() {
        setOnHold()
        act("hold")
    }

    override fun onUnhold() {
        setActive()
        act("unhold")
    }

    override fun onShowIncomingCallUi() {
        // The notification (full-screen intent) is posted by Dart's showIncomingCallNotification.
    }

    @Deprecated("Deprecated in Java")
    override fun onCallAudioStateChanged(state: CallAudioState?) {
        Hub.post { AudioRouter.emitIfChanged() }
    }
}

class SpConnectionService : ConnectionService() {
    private fun build(request: ConnectionRequest?, incoming: Boolean): SpConnection {
        val ex = request?.extras
        val nested = if (incoming) ex?.getBundle(TelecomManager.EXTRA_INCOMING_CALL_EXTRAS)
        else ex?.getBundle(TelecomManager.EXTRA_OUTGOING_CALL_EXTRAS)
        var key = nested?.getString(TelecomHub.KEY) ?: ex?.getString(TelecomHub.KEY)
        var name = nested?.getString("name") ?: ex?.getString("name")
        var handle = nested?.getString("handle") ?: ex?.getString("handle")
        if (key == null) {
            TelecomHub.takePending()?.let { key = it[0]; name = it[1]; handle = it[2] }
        }
        val k = key ?: "unknown-${System.nanoTime()}"
        val c = SpConnection(k)
        c.setAddress(request?.address ?: Uri.fromParts("sip", handle ?: "unknown", null), TelecomManager.PRESENTATION_ALLOWED)
        if (!name.isNullOrEmpty()) c.setCallerDisplayName(name, TelecomManager.PRESENTATION_ALLOWED)
        TelecomHub.connections[k] = c
        return c
    }

    override fun onCreateIncomingConnection(acct: PhoneAccountHandle?, request: ConnectionRequest?): Connection =
        build(request, true).also { it.setRinging() }

    override fun onCreateOutgoingConnection(acct: PhoneAccountHandle?, request: ConnectionRequest?): Connection =
        build(request, false).also { it.setDialing() }

    override fun onCreateIncomingConnectionFailed(acct: PhoneAccountHandle?, request: ConnectionRequest?) {
        Hub.log("telecom refused the incoming call; continuing without it")
    }

    override fun onCreateOutgoingConnectionFailed(acct: PhoneAccountHandle?, request: ConnectionRequest?) {
        Hub.log("telecom refused the outgoing call; continuing without it")
    }
}
