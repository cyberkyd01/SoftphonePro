# Android device QA

Date: 2026-10-19. Build: `flutter build apk --release --target-platform android-arm64`
(Flutter 3.32.1, app version from pubspec), installed on emulator-5554 (arm64, Android 15) with the
real `libspcore` engine. Far end: Asterisk test PBX (tests/sipserver, reached as 10.0.2.2) and the host
`spcore_cli`. Screenshots: `docs/qa-screenshots/` (names below).

Release-build gotcha: after editing Dart, an incremental `flutter build apk --release` once re-used a stale
AOT snapshot (a 4 s build that ignored the changes). Delete `app/build/app/intermediates/flutter` before
building when a change does not show up.

## Environment limits (not app bugs)

The PBX container was started with `PBX_EXTERNAL_ADDR=127.0.0.1` (not `up.sh --emulator`) and must not be
restarted for this run, so:

* Asterisk puts `127.0.0.1` in its SDP and Contact. The emulator therefore sends no RTP to the PBX
  (nothing arrives at Asterisk; `rtp set debug` confirmed zero inbound packets) and DTMF/echo audio cannot be
  verified through the PBX.
* On calls Asterisk originates (incoming to the app), its Contact is the container address 172.18.0.2, so
  in-dialog requests from the app (BYE, REFER) do not reach Asterisk. The app's own BYE to the far end was never
  seen by the host CLI. BYE from Asterisk to the app does arrive.
* Asterisk keeps stale 1020 contacts after force-stop / airplane mode (new source port each time) and rings
  the stale one first, so incoming calls fail for up to a few minutes after a re-registration with a new port.
  This is registrar behaviour, not an app fault; calls worked again once the stale contacts expired.
* pjsip switches to TCP for INVITEs larger than the MTU. A far-end CLI with TCP disabled never sees them.

To make the PBX-dependent cases (D, F via the PBX, media) fully verifiable, restart the PBX with
`tests/sipserver/scripts/up.sh --emulator`.

## Results

| Case | Result | Notes / screenshots |
|---|---|---|
| A. Fresh install, provisioning by deep link (cold and warm), account 1020 registers | PASS | Cold: confirm dialog over onboarding (`A1_cold_dialog`), Import finishes onboarding, green chip (`A1_after_import`); `pjsip show contacts` lists `1020`. Warm: dialog appears, no "Page Not Found" (`A2_warm_dialog`). Both were broken before the fixes below. |
| B. Outgoing call to 600 from the keypad | PASS | In-call screen, timer, quality 4.4 (`B1_incall`), hang up gives a history row (`B2_recents`). |
| C. Incoming 1019 to 1020: foreground, background / screen off, answer, hang up from each side, missed call | PASS (with env note) | In-app incoming page plus heads-up (`C1_incoming_fg`), answered (`C2_answered`), screen-off full-screen incoming (`C3_locked_incoming`), missed-call notification (`C4_missed_notification`), remote hangup ends the app call and returns to Recents (`C5_after_remote_hangup`); history rows for incoming, missed. App-side hangup ends the app call and writes history, but the BYE does not reach the host CLI (environment limit above). |
| D. DTMF 1234 | PASS (direct call), BLOCKED via PBX 602 | Through 602 the PBX read nothing (no inbound RTP, see limits). The in-call keypad shows `1234` (`D2_typed`). Against a host CLI called directly (`sip:far@10.0.2.2:5090`) the far end logged RFC 2833 digits 1, 2, 3, 4 (`D5_dtmf_far`). |
| E. Hold/unhold, mute | PASS | "On hold" label, orange Resume button, mute state; no crash (`E1_mute_hold`, `E2_unmuted`). |
| F. Blind transfer from an incoming call to 600 | BLOCKED | REFER cannot reach Asterisk (limit above). The transfer sheet works; found and fixed the keyboard-covered sheet (below; `F1_transfer_ui`, `F6_transfer_kb_fixed`). Re-test after a PBX restart in emulator mode. |
| G. Settings: codec order, DND, dial rules, themes | PASS | Codec reorder persisted (`G2e_after_drag`); DND rejects with 486, history "Declined" (`G4_dnd`, `K4_recents`); dial-rule live test cleans `+1 (555) 010-2030` to `+15550102030` (`G11_dialrules`); dark theme (`G7`..`G10`), light theme in the A to E shots. Codec list had a visual gap (fixed, below; `G2c` before, `G2d_codecs_fixed` after). |
| H. App lock | PASS | PIN set (`H2_setpin`), lock after "Immediately" locks on return (`H4_lockscreen`), incoming call over the lock screen is shown and answerable (`H6`, `H7`), lock returns after the call (`H8`), unlock and turn off with PIN (`H9`, `H10b`). Note: with "Lock after: 1 minute" a 70 s background did not lock once (not reproduced; unit logic in `app_lock_controller.dart` looks right). Worth one more manual run. |
| I. Diagnostics | PASS | SIP trace list with INVITE/100/180/200/ACK/BYE (`I2_trace_list`), ladder (`I3_ladder`, `I4_ladder_detail`), network wizard 5 pass / 1 warn (STUN did not answer in the emulator) (`I5_network`, `I6_network_results`). |
| J. tel:/sip: links | PASS | `tel:600` with "call links immediately" on starts the call (`J1_tel_immediate`). With it off the dialer is prefilled; before the fix the app stayed on whatever page was open (`J2_tel_prefill`), now it opens the keypad. The system chooser lists SoftphonePro next to Phone. |
| K. Engine resilience | PASS | Force-stop during a call then relaunch re-registers within seconds (`K1_after_forcestop`); airplane mode on/off re-registers in 7 s (new contact seen on the PBX) (`K3_after_airplane`). The call that was interrupted by force-stop is not written to history. |

## Bugs fixed

1. Warm-start deep link showed "Page Not Found": Flutter's own deep-link handling forwarded
   `softphonepro://...` to go_router. `AndroidManifest.xml` now sets `flutter_deeplinking_enabled=false`;
   `macos/Runner/Info.plist` sets `FlutterDeepLinkingEnabled=false` (iOS already did; the Windows runner has no
   built-in deep-link routing).
2. Cold-start provisioning link never showed the confirm dialog: `link_handler.dart` read the root navigator
   context before the router had mounted. It now waits (up to 20 s) for the navigator overlay. Test:
   `test/polish_a1_test.dart` "cold-start provision link during onboarding shows the confirm dialog and
   finishes onboarding".
3. Codecs screen showed a tall blank gap and duplicate list keys: the engine reports some codecs several times
   (G7221 variants share an id). `orderCodecs` / `codecListProvider` in `lib/ui/settings/sections.dart` now
   de-duplicate. Test: `test/codec_order_test.dart`.
4. Transfer sheet was hidden behind the keyboard: it used the call page's `MediaQuery` (inset already consumed by
   the Scaffold). `showTransferSheet` in `lib/ui/widgets/call_widgets.dart` now uses the sheet's own context.
   Test: `test/transfer_keyboard_test.dart` (fails without the fix).
5. `tel:` / `sip:` links with "call links immediately" off only filled the dial field without showing it when
   another page was open. `link_handler.dart` now opens `/keypad` (not during onboarding or a call). Test:
   `test/polish_a1_test.dart` "tel: link shows the dialer prefilled even from another page".

## Remaining issues / observations

* Blind transfer (F) and PBX DTMF (D) need the PBX in emulator mode to be confirmed end to end.
* After a blind transfer whose REFER gets no answer, the call stays up with no "transferring" feedback.
* In-call keypad panel: the bottom button row is clipped behind the End button until scrolled; the on-screen
  keyboard squeezes the call page (labels disappear) while the transfer field is focused.
* Network wizard shows the raw engine string "ErrUnknown" for the STUN failure detail.
* Transfer sheet: the "LAN device" segment label wraps to two lines at 411 dp width.
* Dial rules page uses a smaller, differently aligned header than the other settings pages.
* While the app is foreground, an incoming call shows both the in-app page and a heads-up notification.
* Speaker is on by default for calls on the emulator (no earpiece route reported).
* History labels a DND-rejected call "Declined" (the call model result is `rejected`/declined).
