# macOS QA

Build under test: CI run 39221469917 on branch `macos-qa` (commit 1e3aa45), artifact `macos-dmg`
(`SoftphonePro-1.0.0-dev.26-macOS.dmg`, ad-hoc signed). The `.app` was copied out of the DMG, `xattr -cr`,
and run on macOS 24.6 (Apple silicon) against the local Asterisk test PBX (127.0.0.1:5060, account 1016) with the
host engine CLI as far end (1015).

Automated run: `tests/macos_e2e/e2e.py` (provisions with `--provision http://127.0.0.1:<port>/cfg.json`,
drives the app through the local automation API, checks the PBX with `docker exec ... asterisk -rx`, screenshots the
app's own window with `screencapture -l<id>`).

| # | Case | Result | Notes |
|---|---|---|---|
| 1 | `--provision` URL enables the automation API (settings `automation*` accepted from the command line) | PASS | engine running, API up on the provisioned port |
| 2 | Registration of 1016 | PASS | API `regState: registered`; PBX `pjsip show contacts` lists 1016 |
| 3 | Auth: no/wrong token 401, right token 200 | PASS | |
| 4 | Outgoing call to 600 | PASS | PBX `core show channels`: `PJSIP/1016-... 600@default Echo()`; in-call window screenshot checked |
| 5 | Hold / unhold / mute / unmute | PASS | states `held` / `active`; repeated unhold gives 409 |
| 6 | Hangup | PASS | PBX channel gone |
| 7 | DTMF 1234 to 602 | PASS | PBX `dtmf_1016.txt` rewritten with `1234` |
| 8 | Incoming 1015 -> 1016: SSE `call/incoming`, answer via API, far end hangs up | PASS | banner screenshot checked (Answer / Decline), `call/ended` event received |
| 9 | Blind transfer to 600 | PASS | API 200; PBX shows 1015 bridged to 600 Echo |
| 10 | DND on: incoming rejected | PASS | far end got 486, no `incoming` event, `history/added` event with result `rejected` |
| 11 | Message to 1015 (and reply as `message/received` event) | PASS | far end received the body |
| 12 | History contains the calls | PASS | |
| 13 | API errors (400/404/405/409 JSON) | PASS | |
| 14 | `open -a SoftphonePro.app sip:600` while running (finding 1) | PASS | native log `link received sip:600`, dialer shows 600 (06_sip_link_prefill.png). Before the fix the handler installed in `awakeFromNib` was replaced by NSApplication's own |
| 15 | `--dial 600` at launch (finding 2) | PASS | no "Could not place the call"; the call is placed once 1016 is registered |
| 16 | Screens: keypad, settings (Advanced, Calls), diagnostics, LAN, recents, messages | PASS | looked at; no layout problems found. Calls shows the new default-handler tile with the current handlers (`sip: Zoiper5 | tel: FaceTime | callto: Zoom`) |
| 17 | Default handler: read current handlers (no change made) | PASS | `NSWorkspace.urlForApplication` / `LSCopyDefaultHandlerForURLScheme` read in a standalone check and through the tile. Setting was NOT exercised on this Mac (Zoiper/FaceTime own the schemes) |

Unit/widget tests: `flutter test` (251 tests) green, including `test/automation/` (real `HttpServer` on an ephemeral
port with `FakeSipEngine`) and `test/link_dial_test.dart` (dial waits for registration, failed registration message,
timeout message, provisioning then dial, `DefaultHandlerService` with a mocked channel).

## Notes

* The app ad-hoc build is not sandboxed when run this way; its data is in
  `~/Library/Application Support/com.softphonepro.softphonepro`. The Release entitlements already contain
  `network.server`, so the automation API also works in a signed, sandboxed build.
* The far end and the app sit behind the Docker UDP forwarder (colima gRPC), whose NAT mappings expire when idle.
  Occasionally the first inbound request after a quiet minute is lost; the script refreshes the far end's registration
  and retries the far-end-originated cases once. Not an app defect.
* The test PBX dialplan cannot route a MESSAGE from 1015 to 1016 in some runs ("not a valid SIP/SIPS URI" warning);
  the reply case passed in the final run.
* The Advanced screenshot is cut at the top of the "Local automation API" group at the default 1200x780 window size.

## v1.0.0 final

Date: 2026-10-19. App: CI-built DMG `SoftphonePro-1.0.0-dev.50-macOS.dmg` (run 39290552186, main `9eb7cb7`), installed to a scratch dir with `xattr -cr`, ad-hoc signed, universal. PBX in host mode. Data dir is `~/Library/Application Support/com.softphonepro.softphonepro` (not a sandbox container in this ad-hoc build). Screenshots: `docs/qa-screenshots/v100final_macos_*.png`.

### Environment blocker: microphone permission (TCC)

Every case that opens the audio device is BLOCKED on this Mac. `tccd` logs `Failed to match existing code requirement for subject com.softphonepro.softphonepro and service kTCCServiceMicrophone` (earlier grants belong to other ad-hoc cdhashes; each new CI build has a new one), the macOS prompt cannot be answered because the login session is locked (`CGSSessionScreenIsLocked = true`; nobody to click Allow, and I will not unlock it). The engine log stops at `coreaudio_dev.c Using VoiceProcessingIO audio unit` and the API answers `409 dial_failed`. Not an app defect; to finish, run the e2e on an unlocked session and click Allow once (or grant the microphone to the DMG build).

### Harness fix (tests/macos_e2e/e2e.py)

`open` forwards the caller's environment to the app. The script sets `SPCORE_LIB` for the far-end CLI, which made the app dlopen the host `libspcore.dylib` (the app hung in `dlopen`, API never came up, "automation API did not come up" after 90 s) and means the DMG's own engine was not under test. `launch()` now runs `env -u SPCORE_LIB -u SPCORE_CLI open ...`.

### tests/macos_e2e/e2e.py on the DMG (19 cases: 9 PASS, 10 BLOCKED by the microphone prompt)

| Case | Result |
|---|---|
| boot: `--provision` enables the automation API | PASS (engine running, version 1.0.0) |
| registration of 1016 (API + PBX contacts) | PASS |
| screenshot: keypad registered | PASS |
| API auth (401/401/200) | PASS |
| API error responses (400/404/405) | PASS |
| `open sip:600` while running reaches the app, dialer prefilled | PASS |
| screenshots: settings, diagnostics, LAN, recents, messages | PASS |
| default handler tile (read only) | PASS |
| screenshot: in-call window | PASS (the window is captured, but no call was placed) |
| outgoing call to 600; hold/unhold/mute; hangup; DTMF 1234 to 602; incoming 1015 > 1016; blind transfer; DND incoming rejected; message to 1015 and reply; history; `--dial 600` at launch | BLOCKED (`dial_failed` / `engine_not_running` after the audio device could not open) |

### v1.1 spot checks (provisioned with `--provision`, settings `recordRule all`, `recordFormat wavStereo`, `viMicOn true`, `holdMusic builtin`, `language`)

| Check | Result |
|---|---|
| recordRule all + stereo format applied | PASS: Settings > Recording shows "Stereo ... (WAV)" selected and "Record calls automatically: All calls" (`m_recording2`). Note the wire value is `wavStereo`; `stereo` is silently ignored and falls back to WAV (`m_recording`). |
| Recording call 600, stereo WAV in the recordings folder (python `wave`, 2 channels) | BLOCKED (no call possible; on Android a stereo WAV of 19 s was 1.2 MB, i.e. 64 KB/s) |
| `viMicOn true` call works | BLOCKED (no audio device); setting accepted by the import |
| `holdMusic builtin` hold/unhold via API | BLOCKED (no call); the Android build holds with built-in music fine |
| `language ar` RTL | PASS: sidebar on the right, Settings list/detail mirrored, toggles and chevrons mirrored (`m_ar_calls`, `m_ar_keypad`) |
| Settings screenshots: Audio, Recording, Calls (incoming/system), Privacy and security incl. Encryption, About | PASS (`m_audio`, `m_recording2`, `m_calls`, `m_privacy`, `m_about`). About shows version 1.0.0, update check, GPL v3 licence and the Third-party notices (PJSIP ...). Voice isolation, Audio files and Announcements groups are below the fold of these pages and the window cannot be resized or scrolled without Accessibility permission, so they were not seen: BLOCKED. |
| Update banner | not shown (1.0.0 is current; "Last checked 10/19/2026") |

### CI smoke artifacts (run 39290552186, all jobs green)

* macos-smoke-logs: `provision.json`, `status.json` only. The status was sampled while `engine.state` was still `starting` and the account `offline`; it proves launch and API, not registration.
* windows-smoke-logs: portable and installer runs: engine `running` 1.0.0, account `smoke1@127.0.0.1:5999` `registering` (no server there, expected); installer log "Installation process succeeded", `stderr.log` empty.
* ios-smoke: simulator screenshot shows the Welcome / Get started onboarding page, correct layout (`v100final_ci_ios_sim.png`). `stderr.log`: `objc: Class FileUtils is implemented in both OSAnalytics.framework (iOS 26.2 simulator runtime) and file_picker.framework ... may cause spurious casting failures and mysterious crashes`.
* android-smoke: emulator screenshot shows the same onboarding page at 320x640 (`v100final_ci_android_emu.png`); logcat has 0 `FATAL EXCEPTION`; only warnings "Attempted to register plugin ... already registered with this FlutterEngine".

### Other findings

* Re-provisioning adds duplicate accounts (not idempotent): repeated `--provision` of the same 1016 left four `1016@127.0.0.1` accounts.
* Arabic: the account chip text reads `127.0.0.1@1016` (bidi reordering of `1016@127.0.0.1`).
* iOS: duplicate Objective-C class `FileUtils` (file_picker vs the OS) reported by the simulator.
