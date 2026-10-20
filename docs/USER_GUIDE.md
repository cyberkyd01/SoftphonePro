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

Also in this guide, in this order: Recordings; Audio: devices, noise
cancellation, hold music and announcements; Musicbed; Audio mixer; Language.
Linux users start with **Install on Linux / Raspberry Pi** below.

---

## Install on Linux / Raspberry Pi

SoftphonePro for Linux is a 64-bit app. It runs on:

* Ubuntu 22.04 and later;
* Debian 12 and later;
* Raspberry Pi OS (64-bit), Bookworm, on a Raspberry Pi 4 or 5 (a Pi 3
  works too).

32-bit Raspberry Pi OS is not supported, because Flutter has no 32-bit ARM
Linux build. To check, run `uname -m`: you need `x86_64` (a normal PC) or
`aarch64` (a Raspberry Pi or other ARM computer).

**Choose the file**

| Your computer | `.deb` package | Portable archive |
|---|---|---|
| PC (`x86_64`) | `SoftphonePro-<ver>-linux-amd64.deb` | `SoftphonePro-<ver>-linux-amd64.tar.gz` |
| Raspberry Pi, ARM Ubuntu or Debian (`aarch64`) | `SoftphonePro-<ver>-linux-arm64.deb` | `SoftphonePro-<ver>-linux-arm64.tar.gz` |

**Install the `.deb`**

1. Open a terminal in the folder with the download.
2. Run `sudo apt install ./SoftphonePro-<ver>-linux-<arch>.deb`, with the
   version and architecture of your file. `apt` installs the libraries the
   app needs. (You can also double-click the file to open it in the software
   centre.)
3. Start **SoftphonePro** from the application menu, or run `softphonepro`.

**Use the portable archive**

1. Extract it: `tar -xzf SoftphonePro-<ver>-linux-<arch>.tar.gz`.
2. Run `./softphonepro` in the extracted folder.
3. Optional: run `./install-desktop-entry.sh` for a menu entry and `sip:`,
   `sips:`, `tel:`, `callto:` and `softphonepro:` link handling (for the
   current user only). Run it again if you move the folder. To undo it, run
   `./uninstall-desktop-entry.sh`.

The archive needs these packages (the `.deb` installs them for you): the GTK 3,
ALSA, libsecret, AppIndicator, libnotify, keybinder, OpenGL and GStreamer
libraries. The full list is in `README-linux.txt` in the archive.

**Update.** Install the new `.deb` the same way. Your accounts and settings
are kept.

**Uninstall.** Run `sudo apt remove softphonepro`. Your accounts, history and
settings stay in your home folder; delete the SoftphonePro folders there too if
you want them gone. For the archive, delete the folder (and run
`./uninstall-desktop-entry.sh` first if you installed the menu entry).

**Good to know on Linux**

* Audio goes through ALSA. On PulseAudio and PipeWire systems pick the
  **default** device in **Settings → Audio → Devices**.
* Passwords are kept in the Secret Service keyring (GNOME Keyring or KWallet).
  If the system has no keyring, SoftphonePro stores them in an encrypted file
  instead.
* Not available on Linux: QR camera scanning (paste the code's text instead),
  biometric app unlock (use the PIN), mDNS discovery for LAN Link (LAN Link
  finds other devices by multicast, which still works with the other
  platforms) and import of system contacts.
* More in [Platform notes](#10-platform-notes).

## 1. Adding accounts

When you first start the app, choose **Get started → Add account**.

You can add an account in any of these ways:

* **Provider template.** Asterisk / FreePBX, 3CX, FreeSWITCH, Kamailio /
  OpenSIPS, Twilio SIP Registration, Telnyx, VoIP.ms, Vonage Business,
  WebRTC gateway (WSS) and IAX2 (Asterisk). The template fills in the
  transport, ports and NAT options. Enter your username, password and server.
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
| Basic | Name, colour, username, password, domain, display name |
| Registration | Registration expiry and retry timing |
| Server and transport | Transport, registrar, proxies, backup registrar (automatic failover), local port, WebSocket path, client certificate |
| NAT | STUN, ICE, TURN, keep-alive, contact rewrite |
| Advanced media | RTCP options needed by WebRTC gateways |
| Security | Media encryption (SRTP) off, optional or mandatory; SDES or DTLS key exchange |
| Codecs | A codec order for this account only |
| Features | Voicemail number, voicemail indicator (MWI), presence, DND, forwarding, auto-answer, ringtone, recording, hold music, opening announcement |
| Feature codes | Star codes the PBX uses for park, pickup, DND and forwarding |
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
  Users scan it in **Add account → Scan QR** or in
  **Settings → Provisioning → Import → Scan QR code**. Devices without a
  camera (such as Windows PCs) can paste the code's text instead.
* **URL, file or clipboard.** Use **Settings → Provisioning → Import**
  (*From URL or pasted JSON*, *From file*, *From clipboard*).
* **Desktop command line.** Run
  `SoftphonePro --provision <file-or-url>`. This imports without a prompt,
  so it suits deployment scripts.

**What an import may and may not change**

Everything except the desktop command line is treated as untrusted: links,
QR codes, pasted JSON or URLs, files and URLs fetched from Settings. The app
shows one confirmation dialog for all of them. It lists each account's
server, registrar, proxies, transport and headers, warns about sensitive items
(auto-answer, automatic recording, call forwarding and its target, intercom,
dial-plan rewriting, the blocklist, emergency numbers, speed dial, logging)
and lists what it ignores.

* *Applied:* appearance and language, call-handling preferences, audio
  processing, codecs, jitter buffer, recording format, and the sensitive items
  above once you confirm. Auto-answer and automatic recording stay off unless
  you tick their checkboxes.
* *Ignored (listed in the dialog):* every file or folder path, audio device
  names, ports and transports, STUN servers, LAN sharing, hotkeys, start at
  login, update settings, client-certificate files of accounts, and anything
  the app does not know.
* *Refused (nothing is imported):* turning TLS verification off, a custom CA
  file, certificate pins, custom DNS servers, the local automation API and the
  app lock.

The desktop command line (`SoftphonePro --provision <file-or-url>`) is the
only trusted path. It applies the whole file, including the settings that
untrusted imports refuse.

**Settings → Provisioning → Export** copies the current configuration as
JSON (*Copy configuration (JSON)*) or shows it as a QR code (*QR code →
Account*), with or without passwords (*Include passwords*).

## 3. Making and handling calls

**Making calls**

* Dial from the keypad. Typing digits searches your contacts and history
  (T9).
* Long-press `0` for `+`.
* **Speed dial:** with an empty number field, long-press `1`–`9`. A slot
  that is empty opens a dialog to assign it. Slot `1` calls voicemail until
  you assign it. You can also set slots up in
  **Settings → Calls → Speed dial**.
* **Links:** `sip:`, `tel:` and `callto:` links open the keypad with the
  number filled in. Turn on **Settings → Calls → Call links immediately**
  to call straight away instead.
* To make SoftphonePro the default app for these links on macOS, Windows or
  Linux, use **Settings → Calls → System** ("Make SoftphonePro the default
  app for sip:, tel: and callto: links"). Windows opens its Default apps
  page. On Linux the setting uses `xdg-mime`.
* **Dial plan** (**Settings → Calls → Dial plan**) rewrites numbers before
  dialling, using regex rules, prefix stripping, `+` replacement and a
  country prefix. The **Live test** box shows how a number will be rewritten.

**During a call**

* Controls: Mute, Keypad (DTMF), Speaker or audio route, Hold, Add call,
  Transfer, Record, Merge (Split in a conference) and More. **More** has
  Audio output (Audio devices on desktop), Park call, Retrieve parked call,
  Send DTMF digits, Noise cancellation, Call info, Call quality and SIP trace.
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

* **Blind transfer:** choose *Transfer* → *Blind* → enter the number →
  *Transfer now*. If the server does not confirm within 10 seconds, the call
  shows "Transfer not confirmed by the server" with **Keep call** and
  **Retry**.
* **Attended transfer:**
  1. Choose *Transfer* → *Attended* → enter the number → *Call and consult*.
  2. Talk to the other party. The original caller is on hold.
  3. Choose *Complete transfer*, or *Cancel* to go back to the caller.
* **Conference:** start a second call, then choose *Merge*. The
  *Conference levels* panel gives each party a volume slider. *Split*
  separates the calls again.
* **Park and pickup:**
  * Park a call with *More → Park call*.
  * Get it back with *More → Retrieve parked call* (on a phone it is also
    in the *More* tab) and enter the park slot.
  * Pick up calls with the group or directed pickup codes set in the
    account's feature codes.
* **BLF pickup:** on the **Presence** board, long-press a ringing colleague
  to pick up their call. SoftphonePro uses SIP Replaces when the PBX
  provides dialog details, and the pickup feature code otherwise.

## 5. Do Not Disturb, forwarding, auto-answer

* **DND:** turn on *Do not disturb* in **Settings → Calls → Incoming**, in
  your status menu, or per account (account editor → *Features*). Calls are
  rejected with the code you choose under *Reject with*.
* **Forwarding:** per account, in the account editor under *Features* →
  *Call forwarding*: always, when busy, or when unanswered after N seconds.
  SoftphonePro redirects the call itself. To store DND and forwarding on
  the PBX too, turn on **Sync DND / forwarding to PBX via feature codes**
  in **Settings → Calls → Incoming**.
* **Auto-answer:** **Settings → Calls → Auto-answer** has *Auto-answer all
  calls*, *Answer after* and *Honour intercom headers*. Each account can
  also turn it on, optionally only for intercom calls (account editor →
  *Features*). SoftphonePro recognises these headers:
  * `Call-Info: answer-after`;
  * `Alert-Info: auto-answer`;
  * `Answer-Mode: Auto`.
* **Blocked numbers** and *Reject anonymous calls* are in
  **Settings → Calls**. A number can also be blocked from its entry in the
  history.

## 6. LAN Link

LAN Link connects the SoftphonePro devices on your network: desktops,
laptops and phones. No server or account is involved.

1. **Turn it on:** go to **LAN** (on a phone, **More → LAN Link**) and
   enable LAN Link. More options are in **Settings → LAN Link**.
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
   * **Transfer a call to it:** during any call, choose **Transfer → LAN**
     and tap the device.
     * If the other device is registered on the same PBX, SoftphonePro
       transfers the call normally.
     * Otherwise your device keeps the call and relays the audio. Your
       screen shows *Relayed to …*, with **Take back** and **End**.
     * Tap *Talk first* next to the device to talk to the other person
       before handing the call over.
   * **Pull a call:** on the LAN page you can see a paired device's
     active calls. **Pull** moves one of them to your device. The other
     device must turn on *Let paired devices pull my calls* in its
     **Settings → LAN Link**.

## 7. Messages, presence and BLF

* **Messages:** SIP instant messages, with delivery ticks and typing
  indicators.
* **Presence and BLF:** turn on *Show on BLF board* in a contact. You can
  choose which account watches them under *Presence via account*.
  * The **Presence** board shows each person's state: idle (green),
    ringing (amber) or busy (red).
  * Tap a person to call them, or long-press to pick up their call or
    transfer to them.
* **Voicemail:** the voicemail button in the top bar shows how many new
  messages you have (turn on *Voicemail indicator (MWI)* in the account
  editor). Tap it to call your voicemail.

## 8. Security

* **TLS:** server certificates are checked against the bundled Mozilla CA
  list. You can add your own CA file in **Settings → Network → Transports**
  (*Custom CA file*).
  * For a PBX with a self-signed certificate, open
    **Settings → Diagnostics → Network** and choose **Trust this
    certificate**. This pins that exact certificate.
* **SRTP / DTLS-SRTP:** choose *optional* or *mandatory* per account.
* **App lock:** go to **Settings → Privacy and security** and turn on
  *Require PIN to open the app* to set a PIN (4 to 8 digits).
  * You can also turn on *Unlock with biometrics* where the device has it
    (not on Linux, where the PIN is the only way to unlock).
  * Choose *Lock after*, the time the app can stay in the background before
    it locks, or use *Lock now*.
  * Incoming calls still show and can be answered while the app is
    locked.
  * App lock gates the screen only: calls, hotkeys, links and the
    automation API keep working while the app is locked.
* **Passwords** are stored in the operating system's keystore (on Linux, the
  Secret Service keyring, with an encrypted-file fallback when there is none).
  They're
  never included in exports unless you choose to include them.
* **Encrypted local data (optional):** in **Settings → Privacy and security**
  turn on *Encrypt call history, contacts and messages on this device*.
  * The database is encrypted with AES-256-GCM. The key is created on the
    device and kept in the operating system's keystore.
  * The change is applied the next time SoftphonePro starts, so quit it
    completely (on desktop use *Quit* in the tray or menu bar icon) and open
    it again. Turning it off later decrypts the data the same way.
  * The old file is kept as a backup until the start after that, then deleted.
    If the change fails, nothing is changed and an error is shown.
  * If the key is no longer in the keystore (for example after a keychain
    reset), SoftphonePro shows a recovery screen: *Try again*, or *Start
    fresh* (an empty history, contacts and messages; the old file is kept
    next to the app data). Without the key the data cannot be read.
  * Call recordings and exported files are not encrypted.
* **Updates (Windows, macOS, Linux):** **Settings → About → Updates** has
  *Check for updates* (on by default) and *Check now*. About once a week
  SoftphonePro asks `api.github.com` for the latest release and sends nothing
  but that request. If a newer version exists a banner offers *Release notes*,
  *Download* (opens the release page in your browser) and *Skip this version*.
  Nothing is downloaded or installed automatically. Turn the option off to
  stop all checks. The Android and iOS apps don't check.

## 9. Diagnostics and troubleshooting

**Settings → Diagnostics** has these tools:

| Tool | What it does |
|---|---|
| SIP trace | Records SIP messages and shows them as a ladder diagram or raw text. Export as `.log` or `.pcap`, with passwords removed by default. |
| Network | The network wizard: checks your network interfaces, DNS/SRV for each account, NAT type (STUN), SIP OPTIONS reachability and TLS certificates, and looks for signs of SIP ALG. Every check comes with advice. |
| Quality | Charts MOS, jitter, packet loss and RTT live. Each call's summary is saved in the history. |
| Audio test | Mic level meter, echo test and test tones. |
| Logs | Engine log viewer. The rotating log file (`logs/engine.log`) is included in the support bundle. |
| System | Version and system information. |

**Common problems**

| Symptom | What to try |
|---|---|
| **403 / Wrong password** | Check the auth username. Some providers need it to differ from the username. |
| **408 / Timeout** | Check the server address and port. Try TCP or TLS. The network wizard shows if UDP is blocked. |
| **One-way or no audio** | Turn on STUN, or ICE plus TURN. Turn off SIP ALG on your router. Try TCP or TLS signalling. |
| **Echo** | Try a different *Echo cancellation* setting under **Settings → Audio → Processing**: *WebRTC AEC3*, *Speex* or *Platform*. |
| **Missed calls on Android** | Open **Settings → Notifications and ringtones → Background reliability**. Allow the app to run in the background and turn off battery optimisation for it. |

## Recordings

**Recording a call.** Tap **Record** during a call, or let SoftphonePro do
it automatically. A red **REC** marker shows while recording.

**Settings → Recording**

* **Format**
  * *Standard (WAV)*: mono, about 2 MB a minute, plays everywhere.
  * *Stereo, you and the caller on separate channels (WAV)*: you on the left channel and the caller on the right,
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

## Musicbed

A musicbed is a music file that loops under your voice, so the people you are
talking to hear both. Use it for background music during a presentation or a
long call.

**Set it up**

1. Open **Settings → Audio → Musicbed**, or open the mixer (see *Audio mixer*
   below) and choose **Show devices and musicbed**.
2. Choose a file under **Music file**. The list is your audio library;
   **Add a file…** imports an MP3 or WAV (a file can be up to 30 minutes
   long).
3. Turn on **Play musicbed**. The file plays in a loop, with no gap at the
   end.
4. Set **Musicbed volume**. It goes from 0% to 200% and you can change it
   live, during a call. The default is low (30%) so your voice stays on top.

**Hear it yourself.** Turn on **Hear it myself** to monitor the musicbed in
your own speaker or headphones. It has its own **Monitor volume**, separate
from the volume your callers hear. Use it with headphones, or the microphone
will pick the music up again.

**How it behaves in calls**

* It goes to everyone on your active calls. In a local conference it goes to
  every member.
* It keeps playing while you **mute** your microphone.
* A call on **hold** does not get the musicbed. The held party hears your hold
  music instead, and gets the musicbed back when you resume.
* Recordings you make with **Record** include the musicbed on your side.
* Between calls it pauses, and it continues from where it stopped when the
  next call connects. With **Hear it myself** on, it plays on your side even
  with no call, which lets you preview it.
* If the file is deleted, SoftphonePro turns the musicbed off and tells you.

The musicbed cannot be switched on or off through the local automation API.
Developers can read the engine calls in [ENGINE_API.md](ENGINE_API.md), section 10.

## Audio mixer

The mixer shows how loud things are and lets you change them, while a call is
running.

* **Microphone:** a level bar and an input volume (gain) slider.
* **Headphones & speaker:** a level bar and an output volume slider.
* **Musicbed:** a level bar and the musicbed volume (see *Musicbed*).
* **Devices:** pickers for the input and output device. On a phone, the
  output picker is the audio route (earpiece, speaker, Bluetooth or wired
  headset), and the microphone follows the selected route.

**Where it is**

* **Keypad screen:** a card on desktop and tablets, and a collapsible strip
  on phones (**Show audio mixer** / **Hide audio mixer**).
* **During a call:** in the calls panel on desktop, and on the in-call page
  on a phone.
* **Settings → Audio:** the microphone and speaker bars and sliders sit in the
  levels and test group, and the musicbed settings are in their own group.

The bars show the signal live. The level bar of the musicbed stays empty when
nothing is playing it, for example while it is paused between calls. Choose
**Show devices and musicbed** to open the device pickers and the musicbed
controls, and **Show fewer controls** to close them.

## Language

SoftphonePro follows your system language by default. To change it, open **Settings > Appearance > Language** and pick a language; each language is listed by its own name (English, Español, Français, Deutsch, Português (Brasil), Italiano, Nederlands, Русский, Türkçe, हिन्दी, العربية, 简体中文, 日本語). The change applies immediately, without restarting. Arabic switches the whole layout to right-to-left. Phone numbers, SIP addresses, log and trace contents, and codec names always stay in their original form.

## 10. Platform notes

* **Windows**
  * The installer registers `sip:`, `sips:`, `tel:`, `callto:` and
    `softphonepro:` links.
  * With **Close to tray** on (**Settings → Advanced → Desktop**), closing
    the window keeps SoftphonePro running in the tray so calls can still
    ring. Choose **Quit** in the tray menu to exit.
  * Global hotkeys are set in **Settings → Shortcuts**.
  * The headset or keyboard play/pause button answers a ringing call and
    ends (or mutes) the active call. Choose which in **Settings → Shortcuts →
    Headset and media keys**. SoftphonePro takes the button only while a call
    is ringing or active, so music players keep it otherwise.
* **Linux**
  * Install and uninstall steps are in
    [Install on Linux / Raspberry Pi](#install-on-linux--raspberry-pi).
  * The **tray icon** appears on desktops with a StatusNotifierItem host:
    Ubuntu, KDE and the Raspberry Pi panel have one. Stock GNOME on Debian
    needs the AppIndicator extension. **Without a tray, closing the window
    quits SoftphonePro**, so incoming calls no longer ring. With a tray,
    **Close to tray** (**Settings → Advanced → Desktop**) keeps it running.
  * Notifications for incoming calls have **Answer** and **Decline**.
  * **Links:** `sip:`, `sips:`, `tel:`, `callto:` and `softphonepro:` links
    open SoftphonePro. Turn on the default-app setting in
    **Settings → Calls → System**. The portable archive needs
    `./install-desktop-entry.sh` for this.
  * Only one copy runs at a time. Starting it again, or opening a link, hands
    over to the running one.
  * **Start at login** is in **Settings → Advanced → Desktop**.
  * The headset or keyboard play/pause button works through MPRIS, as on
    Windows (see above).
  * **Global shortcuts** (**Settings → Shortcuts**) work on X11 sessions
    only. They are not available on Wayland.
  * Audio uses ALSA. Pick the **default** device to reach PulseAudio or
    PipeWire.
* **macOS**
  * The first time you open the app, right-click it and choose **Open**
    (the build isn't notarised yet).
  * The headset or keyboard play/pause button works the same way as on
    Windows (see above).
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
