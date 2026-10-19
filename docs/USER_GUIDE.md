# SoftphonePro User Guide

**Contents**

1. Adding accounts
2. Provisioning (for administrators)
3. Making and handling calls
4. Transfers, conferences, park and pickup
5. Do Not Disturb, forwarding, auto-answer
6. LAN Link: hand calls to your other devices, chat and send files
7. Messages, presence and BLF
8. Security
9. Diagnostics and troubleshooting
10. Platform notes

---

## 1. Adding accounts

When you first start the app, choose **Get started → Add account**.

You can add an account in any of these ways:

* **Provider template.** Asterisk/FreePBX, 3CX, FreeSWITCH, Kamailio, Twilio,
  Telnyx, VoIP.ms, Vonage, WebRTC gateway (WSS) and IAX2 (Asterisk). The
  template fills in the transport, ports and NAT options. Enter your username,
  password and server.
* **Generic SIP.** Enter the username, password and SIP domain, plus any
  of these:
  * auth username;
  * outbound proxy;
  * transport: UDP, TCP, TLS, WS, WSS or **Automatic (DNS SRV)**.
* **IAX2.** Choose IAX2 at the top of the form. Then enter the host, port
  (4569 by default), username, password and an optional context.
* **Scan QR** or **Import from URL.** Use the code or link your
  administrator gave you.

You can register as many accounts as you like at the same time (the limit
is 64).

* Each account shows a status chip in the top bar:
  * green means registered;
  * amber means registering;
  * red means failed.
* Tap a chip to register or unregister that account, or to see the reason
  it failed.
* Choose the account for outgoing calls in the selector above the keypad.
  "Direct (no account)" makes peer-to-peer IP calls.

**Settings → Accounts → (account)** opens the full account editor:

| Section | What you can set |
|---|---|
| Server & transport | Registrar, proxies, backup registrar (automatic failover), local port, WebSocket path |
| NAT | STUN, ICE, TURN, keep-alive, contact rewrite |
| Security | SRTP off, optional or mandatory; SDES or DTLS keying |
| Codecs | A codec order for this account only |
| Features | Voicemail number, DND, forwarding, auto-answer, auto-record, ringtone, feature codes (park, pickup, DND, forwarding) |
| Advanced | Session timers, 100rel, SIP outbound, DTMF mode, DSCP, IPv6 |

**Automatic transport (DNS SRV).** Choose *Automatic (DNS SRV)* as the
transport and SoftphonePro asks DNS which transport the server offers. It
tries the `_sips._tcp` records (TLS), then `_sip._tcp` (TCP), then
`_sip._udp` (UDP), in order of preference, and falls back to UDP on port
5060. Tap the account chip to see the result under **Transport** and
**Resolved server**.

**Client certificate (mutual TLS).** Some servers want the app to identify
itself with a certificate. With a TLS, WSS or automatic transport, the
account editor shows **Client certificate (mutual TLS)**: choose the
certificate file and the private key file (PEM), and enter the key password
if the key is encrypted. Both files are needed; until both are set nothing
is sent. On iPhone and Android the files are copied into the app when you
pick them. The key password is kept in the device's secure storage, not in
the account database.

If the server rejects your password (401/403), SoftphonePro **stops
retrying**, so the provider doesn't lock you out. Correct the password or
tap **Register** to try again.

## 2. Provisioning (for administrators)

SoftphonePro imports a JSON configuration:

```json
{
  "version": 1,
  "accounts": [
    {
      "label": "Office",
      "template": "asterisk",
      "username": "${USER}",
      "password": "s3cret",
      "domain": "pbx.example.com",
      "transport": "tls",
      "displayName": "Front desk",
      "proxies": ["sip:proxy.example.com;lr"]
    }
  ],
  "settings": {
    "callWaiting": true,
    "defaultCountryPrefix": "+44"
  }
}
```

**Account fields**

* Required: `username` and `domain`. You can use `server` instead of
  `domain`.
* Optional: `password`, `label`, `displayName`, `authUser`, `transport`
  (`udp|tcp|tls|ws|wss`), `proxies`, and `template`.
* `template` is one of `asterisk`, `3cx`, `freeswitch`, `kamailio`,
  `twilio`, `telnyx`, `voipms`, `vonage`, `iax2`, `webrtc` or `generic`.

**Variables**

These are replaced on the device when the file is imported:

* `${USER}`: the operating-system user name.
* `${HOSTNAME}`: the device's host name.
* `${MAC}`: a stable identifier for this installation.

**Ways to deliver it**

* **Link.** Use `softphonepro://provision?url=https://example.com/softphone.json`.
  The app shows what will be imported and asks the user to confirm.
* **QR code.** The code can contain the JSON itself or a provisioning link.
  Users scan it in **Add account → Scan QR** or
  **Settings → Provisioning**.
* **File or clipboard.** Use **Settings → Provisioning → Import**.
* **Desktop command line.** Run
  `SoftphonePro --provision <file-or-url>`. This imports without a prompt,
  so it suits deployment scripts.

**Settings → Provisioning → Export** writes the current configuration as
JSON or as a QR code, with or without passwords.

## 3. Making and handling calls

**Making calls**

* Dial from the keypad. Typing digits searches your contacts and history
  (T9).
* Long-press `0` for `+`, and long-press `1` for voicemail.
* **Speed dial:** long-press `2`–`9` with an empty number field. Set slots
  up in **Settings → Calls → Speed dial**.
* **Links:** `sip:`, `tel:` and `callto:` links open the keypad with the
  number filled in. Turn on **Settings → Calls → Call links immediately**
  to call straight away instead.
* To make SoftphonePro the default app for these links, use
  **Settings → Calls → System → Make default** on macOS or Windows.
* **Dial plan** (**Settings → Calls → Dial plan**) rewrites numbers before
  dialling, using regex rules, prefix stripping, `+` replacement and a
  country prefix. The **Test** box shows how a number will be rewritten.

**During a call**

* Controls: mute, keypad (DTMF), hold, audio route, add call, transfer,
  record, merge, and More (park, call info, quality, SIP trace).
* The bars and number next to the timer show the live call quality (MOS).
* The padlock shows whether the call is encrypted:
  * signalling over TLS/WSS;
  * media over SRTP.

**Incoming calls**

* Answer, decline, or reply with a message.
* **Who is calling.** When the network states the caller's identity
  (`P-Asserted-Identity` or `Remote-Party-ID`), SoftphonePro shows that name
  and number in preference to the "From" name, and adds "From 1002" when the
  "From" number differs. Your own contact name always wins. A call that was
  forwarded to you says "Forwarded from 2001 (no-answer)" (from `Diversion`
  or `History-Info`), and a call that arrives through a transfer says
  "Transferred by 1005". This appears on the incoming screen and banner, the
  in-call screen, the desktop call card and in the call's history details.
* Send the call to voicemail by redirecting it.
* Transfer it to another of your devices with LAN Link.
* When a second call arrives, you hear a call-waiting tone. Answering it
  puts the first call on hold.

## 4. Transfers, conferences, park and pickup

* **Blind transfer:** choose *Transfer* → enter the number → *Transfer
  now*. If the server does not confirm within 10 seconds, the call shows
  "Transfer not confirmed by the server" with **Keep call** and **Retry**.
* **Attended transfer:**
  1. Choose *Transfer* → *Consult first*.
  2. Talk to the other party.
  3. Choose *Complete transfer*.
* **Conference:** start a second call, then choose *Merge*. Each party has
  its own volume and mic sliders. *Split* separates the calls again.
* **Park and pickup:**
  * Park a call with *More → Park*.
  * Get it back with *Retrieve parked call*.
  * Pick up calls with the group or directed pickup codes set in the
    account's feature codes.
* **BLF pickup:** on the **Presence** board, long-press a ringing colleague
  to pick up their call. SoftphonePro uses SIP Replaces when the PBX
  provides dialog details, and the pickup feature code otherwise.

## 5. Do Not Disturb, forwarding, auto-answer

* **DND:** turn it on for everyone (status menu) or per account. Calls are
  rejected with the code you choose.
* **Forwarding:** always, when busy, or when unanswered after N seconds.
  SoftphonePro redirects the call itself. To store DND and forwarding on
  the PBX too, turn on **Sync DND/forwarding via feature codes**.
* **Auto-answer:** turn it on for everyone or per account, or only when
  the PBX asks for intercom. SoftphonePro recognises these headers:
  * `Call-Info: answer-after`;
  * `Alert-Info: auto-answer`;
  * `Answer-Mode: Auto`.
* **Blocklist and anonymous rejection** are in **Settings → Calls**. A
  number can also be blocked from its entry in the history.

## 6. LAN Link

LAN Link connects the SoftphonePro devices on your network: desktops,
laptops and phones. No server or account is involved.

1. **Turn it on:** go to **LAN** (on mobile, **More → LAN**) and enable
   LAN Link.
   * Devices on the same network appear automatically.
   * On guest Wi-Fi or other networks that isolate clients, use
     **Connect by address**, or scan the other device's QR code.
2. **Pair:** choose **Pair**.
   * Both screens show a **6-digit code**. Check that the codes match,
     then confirm on both devices.
   * From then on, the devices talk over an end-to-end encrypted channel.
3. **What you can do with a paired device:**
   * **Chat:** messages appear in **Messages** with a LAN badge.
   * **Send files:** the other device has to accept each file.
     SoftphonePro checks every file with SHA-256 after it arrives.
   * **Call or intercom** the device directly. Intercom calls are
     auto-answered only if the other person allows it, and you can set the
     app to ask first.
   * **Transfer a call to it:** during any call, choose **Transfer → LAN
     device**.
     * If the other device is registered on the same PBX, SoftphonePro
       transfers the call normally.
     * Otherwise your device keeps the call and relays the audio. Your
       screen shows *Relayed to …*, with **Take back** and **End**.
     * Choose *Consult first* to talk to the other person before handing
       the call over.
   * **Pull a call:** on the LAN page you can see a paired device's
     active calls. **Pull** moves one of them to your device. The other
     device must allow pulls in its LAN settings.

## 7. Messages, presence and BLF

* **Messages:** SIP instant messages, with delivery ticks and typing
  indicators.
* **Presence and BLF:** turn on *BLF/presence* for a contact. You can
  choose which account watches them.
  * The **Presence** board shows each person's state: idle (green),
    ringing (amber) or busy (red).
  * Tap a person to call them, or long-press to pick up their call or
    transfer to them.
* **Voicemail:** the badge in the top bar shows how many new voicemail
  messages you have. Tap it to call your voicemail.

## 8. Security

* **TLS:** server certificates are checked against the bundled Mozilla CA
  list. You can add your own CA file in **Settings → Network → TLS**.
  * For a PBX with a self-signed certificate, open
    **Diagnostics → Network wizard → Trust this certificate**. This pins
    that exact certificate.
* **SRTP / DTLS-SRTP:** choose *optional* or *mandatory* per account.
* **App lock:** go to **Settings → Privacy & Security** and set a PIN.
  * You can also allow fingerprint or face unlock.
  * Choose how long the app can stay in the background before it locks.
  * Incoming calls still show and can be answered while the app is
    locked.
* **Passwords** are stored in the operating system's keystore. They're
  never included in exports unless you choose to include them.

## 9. Diagnostics and troubleshooting

**Settings → Diagnostics** has these tools:

| Tool | What it does |
|---|---|
| SIP trace | Records SIP messages and shows them as a ladder diagram or raw text. Export as `.log` or `.pcap`, with passwords removed by default. |
| Network wizard | Checks your network interfaces, DNS/SRV for each account, NAT type (STUN), SIP OPTIONS reachability and TLS certificates, and looks for signs of SIP ALG. Every check comes with advice. |
| Call quality | Charts MOS, jitter, packet loss and RTT live. Each call's summary is saved in the history. |
| Audio | Mic level meter, echo test and test tones. |
| Logs | Engine log viewer. The rotating log file (`logs/engine.log`) is included in the support bundle. |

**Common problems**

| Symptom | What to try |
|---|---|
| **403 / Wrong password** | Check the auth username. Some providers need it to differ from the username. |
| **408 / Timeout** | Check the server address and port. Try TCP or TLS. The network wizard shows if UDP is blocked. |
| **One-way or no audio** | Turn on STUN, or ICE plus TURN. Turn off SIP ALG on your router. Try TCP or TLS signalling. |
| **Echo** | Try a different echo canceller in **Settings → Audio**: *platform* or *AEC3*. |
| **Missed calls on Android** | Open **Settings → Notifications → Background reliability**. Allow the app to run in the background and turn off battery optimisation for it. |

## Recordings

**Recording a call.** Tap **Record** during a call, or let SoftphonePro do
it automatically. A red **REC** marker shows while recording.

**Settings → Recording**

* **Format**
  * *Standard (WAV)*: mono, about 2 MB a minute, plays everywhere.
  * *Stereo (WAV)*: you on the left channel and the caller on the right,
    about 4 MB a minute. Useful for transcription and review.
  * *Compressed (Opus)*: about 0.2 MB a minute (Ogg Opus). Android and Linux
    play it in the app; on iPhone, Mac and Windows use **Open with...** or
    export it, because the system players there cannot decode Ogg Opus.
* **Automatic recording:** off, all calls, incoming only or outgoing only.
  Each account can override this (use the global setting, record all,
  incoming only, outgoing only, or never). A contact with **Always record
  calls with this contact** is recorded whatever the rules say.
* **Play a notice before recording** plays your recording announcement to
  the other party before recording starts (set the file in *Settings →
  Calls → Announcements*). **Recording beep** warns periodically.
* **Continue recording through transfers.** When you record a call and start
  an attended transfer, the consultation call is recorded too. A call handed
  to you by a transfer or relay keeps being recorded. The recordings are
  linked: the history details and the Recordings page show "Related" links.
* **Storage:** the recordings folder, **Delete old recordings** (never, 7,
  30, 90 days or 1 year; checked at startup and once a day) and, on
  desktop, **Open recordings folder**.

**The Recordings page** (desktop: *Recordings* in the left rail; phone:
*More → Recordings*)

* Recordings are grouped by day with the contact name, number, direction,
  account, duration, size and a format badge. A summary line shows the
  number of recordings and the space they use.
* Search by name or number; filter by incoming or outgoing, by account and
  by date range.
* Tap a recording to play it (play, pause, seek). **Rename** it, **Delete**
  it (with confirmation), or select several (long-press or the checklist
  button) to delete them together.
* **Export:** on desktop, **Save as...** and **Show in Finder / folder**; on
  iPhone and Android, **Share**.
* **View call** opens the call in the history; the call's details link back
  with **Open in Recordings**.
* Check your local laws before recording calls.

## Audio: devices, noise cancellation, hold music and announcements

**Devices.** *Settings → Audio → Devices* picks the microphone, speaker and (desktop) ringer. "System default" shows which device the OS is using now. *Test speaker* plays a short tone; the mic meter and *Echo test* show your level. During a call, **More → Audio devices** (desktop) or the speaker button (phone) switches devices; on a phone you can choose Phone, Speaker, Bluetooth or a wired headset.

**Voice isolation (AI noise cancellation).** *Settings → Audio → Voice isolation* removes keyboard noise, fans and background voices using an on-device neural network. Turn it on for *My microphone* (what the other person hears) and/or *Other participants* (noisy callers), and set the strength from Low to Max. The speech meter and *Test with echo* let you hear the effect (use headphones). In a call, **More → Noise cancellation** toggles it and a "Noise cancellation on" chip shows on the call. macOS 12+ and iOS 15+ also offer *System microphone mode (Voice Isolation)*; on Android the page shows whether the phone's own noise suppressor and echo canceller exist. If the call engine lacks the feature, the controls are disabled.

**Audio files.** *Settings → Audio → Audio files* holds your hold music and announcements. Import a WAV or MP3, or record your own with the microphone (timer, level meter, preview). Rename or delete files; two hold tracks and a chime are built in.

**Music on hold.** *Settings → Calls → Hold → Hold music*: "PBX default" holds plainly (your phone system may play its own music); otherwise the chosen track is played to the held caller at the chosen volume. Each account can override this in its editor.

**Announcements.** *Settings → Calls → Announcements*: play a file when a call connects (incoming, outgoing or both, optionally muting your microphone and letting you hear it; a *Skip* button appears in the call), a notice before recording starts, and a notice before a caller is transferred (blind, attended or LAN hand-off; it is played to the caller, then the transfer happens, after at most 15 seconds).

## 10. Platform notes

* **Windows**
  * The installer registers `sip:`, `sips:`, `tel:`, `callto:` and
    `softphonepro:` links.
  * Closing the window keeps SoftphonePro running in the tray. Choose
    **Quit** in the tray menu to exit.
  * Global hotkeys are set in **Settings → Shortcuts**.
* **macOS**
  * The first time you open the app, right-click it and choose **Open**
    (the build isn't notarised yet).
  * Allow microphone access when macOS asks. Contacts and local network
    access are needed only for those features.
* **Android**
  * A permanent notification keeps your accounts registered while the app
    is in the background.
  * Incoming calls show full screen, even on the lock screen.
  * Bluetooth and car controls work through Android's call integration.
* **iOS**
  * Calls use CallKit.
  * Without push notifications, incoming calls only arrive while the app
    is running.
