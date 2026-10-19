# Feature-completeness audit — 2026-10-19 (Fable 5.1)

**Status at audit time:**
* 51 features ✅ (implemented and tested).
* About 35 ◐ (implemented but partial, untested, or with no UI path).
* 4 ☐ missing or deferred: video, ZRTP, localisation, QR scanning.

The fix work is split into polish tracks A1, A2, B, C, D and E. Each item
below names its track. File references are relative to the repo root.

## P0 — release blockers
1. **[A1] TLS CA bundle and the silent demo fallback**
   * Ship Mozilla `cacert.pem` as an asset (`app/assets/certs/cacert.pem`),
     copy it to the app support dir at startup, and set
     `TlsTransportConfig.caFile` in `engine_controller.dart` (around line 91).
   * Today `core.start` fails with INVALID_PARAM on iOS and Windows when
     tlsVerify is on, which is the default.
   * `engine_controller.dart` (lines 189-200) must NOT silently fall back to
     FakeSipEngine when the native library *loaded* but `core.start` failed.
     It should show a blocking error with the engine message plus Retry,
     Settings, and an explicit "Use simulator" choice.
   * Add a widget test that a start failure surfaces.
2. **[A1] Deep links**
   * `app_services.dart` `handleLink` sends every link to the dialer.
   * Add `softphonepro://provision?url=<https>`, which confirms and then
     imports.
   * Add `softphonepro://lan?...`, which does a LAN manual connect
     (`LanTarget.parse`).
   * `softphonepro://call?number=` and `sip:`/`tel:` keep going to the
     dialer.
   * Add a setting "Call links immediately" (default off).
   * Desktop CLI arguments: `--provision <path|url>` imports without a
     prompt, because it is local user intent; `--dial <target>` places the
     call.
3. **[B] IAX2 account UI**
   * Add a protocol picker in `add_account.dart` and `account_editor.dart`.
   * IAX2 fields: host, port 4569, context, codecs PCMU/PCMA/GSM. Hide
     SIP-only groups.
   * Add an "IAX2 (Asterisk)" template in `provider_templates.dart`.
   * Add a flow test.
4. **[A2] iOS CallKit DTMF:** consume `IosPlatformServices.systemDtmf` and
   call `sendDtmf`.
5. **[A2] Call-progress tones**
   * Ringback while an outgoing call is calling/early with media none.
   * Busy on 486 or 600.
   * Congestion on 503, 408 or 5xx, for about 3 s.
   * `calls_controller.dart` today only plays the waiting and DTMF tones.

## P1 — premium parity
* **[A2] Real ringtones:** bundle 2–3 WAVs (synthesise pleasant tones) and
  map 'classic'/'soft' to files. Desktop uses `ringStart(file:)` and Android
  uses `Ringer.start` with a path. Per-account and per-contact ringtones are
  no-ops today.
* **[A2] Speed dial:** slots 1–9, long-press on the DialPad, a settings page,
  and `AppSettings.speedDial`.
* **[A2] Recording beep and per-account auto-record:** `recordBeep` is stored
  but unused. Implement the beep with a periodic tone, and add
  `AccountProfile.autoRecord`.
* **[E] Device contacts import:**
  * Android: wire the existing `readDeviceContacts` into ContactsPage
    ("Import from phone").
  * iOS: `CNContactStore`.
  * macOS: the Contacts framework plus an entitlement and usage string.
* **[E] QR scanning:** `mobile_scanner` on Android, iOS and macOS, for
  provisioning QR codes and LAN pairing QR codes.
* **[A2] Conference per-party volume:** sliders that call
  `engine.setCallLevels`.
* **[A2] Park and pickup:**
  * "Retrieve parked call" (dial a slot).
  * BLF directed pickup with Replaces via `engine.pickup()` using
    `BuddyInfo.blf.dialogs` callId and tags, falling back to the feature
    code.
* **[A1] Registration failover:** `AccountProfile.backupRegistrar`. After N
  failures, modify the account to use the backup, and flip back on recovery.
* **[A1] E.164 / country prefix:** expose `stripPrefix`, `plusReplacement`
  and `defaultCountryPrefix` in the Dial plan section, and pass them in
  `calls_controller.dart` (around lines 853-859).
* **[B] WS/WSS UI:** expose `wsPath` and `rtcpFb`, and add a "WebRTC gateway
  (WSS)" template (srtp mandatory, dtls, ice, rtcpMux, rtcpFb).
* **[A1] Jitter buffer and ptime:** add an Advanced audio group that sets
  `MediaConfig.jb` and `ptime`, and include them in the restart keys.
* **[A1] Audio hot-plug:** listen to `MediaDevicesChangedEvent`, then
  invalidate the audio devices provider. On desktop, also refresh
  periodically.
* **[E] App lock:** `local_auth` plus a PIN gate. The switch is currently
  disabled ("Coming soon").
* **[A2] Direct IP calls when accounts exist:** route `sip:user@<ip-literal>`
  and an explicit "Direct (no account)" selector entry to `AccountRef.direct`.
* **[A2] BLF and presence per account:** add an account picker on the contact.
  Today everything subscribes through the default profile
  (`presence_controller.dart`).
* **[A1] On-disk engine log:** set `CoreConfig.logFile` to the support dir
  with rotation, and include it in the diagnostics export.
* **Dead or misleading settings:**
  * **[D] DONE** apply per-account `dscp.sip` in the engine (own-transport + shared UDP; see ENGINE_API.md "SIP DSCP").
  * **[A1]** dial `FeatureCodes.dndOn/dndOff/forwardOn/forwardOff` when the
    per-account DND or forwarding toggles change (if the codes are set).
  * **[A2]** RedirectPolicy.ask: implement a prompt via `processRedirect`.
  * **[A1]** `defaultCountryPrefix`.
  * **[A2]** `recordBeep`.
  * **[E]** `appLock`.

## Correctness bugs
1. **[A1]** Silent demo mode on iOS/Windows (P0 item 1).
2. **[A2]** Blocklist substring match in `calls_controller.dart` (around line
   611): `i.remoteUri.contains(b)` means blocking "100" also blocks "1001".
   Use exact-number matching (`sameNumber`).
3. **[A2]** Emergency dial with zero profiles throws a StateError in
   `calls_controller.dart` (lines 888-894). Emergency numbers should also be
   able to use the direct path.
4. **[A1]** Endless retry on auth failures in `accounts_controller.dart`
   (lines 351-375). On 401/403/404, stop retrying until the profile changes.
   This prevents fail2ban lockouts.
5. **[A1]** Engine-restart race in account sync in `accounts_controller.dart`
   (lines 138-145): `_added` is cleared while a queued `_sync` is still
   iterating. Queue the clear or check the generation inside the loop.
6. **[A2]** CallKit DTMF is dropped (P0 item 4).
7. **[D] DONE** Wrong security badge for TLS calls (`spc_call.c`):
   `secureSignaling = srtp && dlg->secure`, but `dlg->secure` is only set for
   `sips:` targets. Derive it from the dialog's transport type (TLS/WSS) and
   don't AND it with srtp.
8. **[C]** Legacy LAN intercom API: migrate `lan_controller.dart` and
   `lan_handoff_impl.dart` to `LanLink.requestIntercom` /
   `intercomNegotiations` / `intercomGranted()`.
9. **[C]** Double handling of a REFER-mode handoff failure:
   `lan_handoff_impl.dart` (lines 246-262) and `calls_controller.dart` (lines
   561-576) both react to the same `transferStatus`. Gate CallsController's
   handling when a LAN relay session owns the cid.
10. **[D] DONE** A TLS transport creation failure is swallowed in `spc_core.c`
    (around lines 1041-1055). Fail `core.start` with a clear message (for
    example a bad cert or key file), or report it in the result.
11. **[D] DONE** `dscp.sip` is not applied.
12. **[A2]** Per-contact and per-account ringtones are no-ops (see Real
    ringtones above).
13. **[A1]** `softphonepro://lan` and `provision` links land in the dialer
    (P0 item 2).
14. **[A2]** BLF works only via the default account.
15. **Minor:**
    * **[D] DONE** `G.tls_verify` keeps its value when a later `core.start` has no
      `tls` object.
    * **[A2]** `_syncSideEffects` re-invokes the proximity, screen and tray
      platform calls at 1 Hz. Only invoke them when the value changes.

## Not covered by FEATURES.md (new rows to add)
* Push notifications (needs a server — document a self-hosted gateway).
* CardDAV/LDAP contacts (v1.1).
* A browser click-to-dial extension.
* A local automation API (the Bria API equivalent, free here).
* Encrypted-at-rest history and recordings.
* Visual voicemail.
* LAN group chat.
* A desktop update checker.
* Linux desktop packaging, which isn't a target.
* Video and ZRTP: deferred to v1.1, and stated in the release notes.
