# SoftphonePro 1.1.0 Android E2E QA (musicbed + mixer)

Date 2026-10-20. Debug APK (`flutter build apk --debug --target-platform android-arm64`, Flutter 3.32.1, JDK 17 via GRADLE_OPTS),
engine rebuilt with `SPC_VERSION=1.1.0 native/scripts/build_spcore.sh android`. Emulator `Medium_Phone_API_35` (arm64, Android 15, 1080x2400)
on emulator-5554. PBX: `up.sh --emulator` (advertises 10.0.2.2), account 1001 / host 10.0.2.2, UDP. Fresh install (uninstall first).
Recording format switched to "Stereo" for the volume/hold analysis. PBX restored to host mode (`up.sh`), font scale 1.0, night mode off,
auto-rotate on, emulator stopped.

Files: `ui.py` (adb/uiautomator helper), `analyze_wav.py` (Goertzel 440 Hz per channel/window, pure python), `inbound_cli.py` (spcore_cli as 1002 calls 1001),
`musicbed_call_test.sh` (scenario; final numbers were produced by running the same steps by hand, see its header). Screenshots: `docs/qa-screenshots/v110_android_*.png`.

## Results

| ID | Check | Result | Evidence |
|---|---|---|---|
| A1 | Fresh install, add account via UI, registers | PASS | Onboarding > Asterisk > 1001; first attempt registered with wrong data (my typing), fixed in Settings > Accounts; `pjsip show contacts` lists `1001`, green chip (A5, C3). |
| A2 | Settings > About version | PASS | "SoftphonePro / Version 1.1.0". |
| B1 | Import 10 s 440 Hz MP3 via Android file picker, select, enable, 100% | PASS | Settings > Audio files > "Import a WAV or MP3..." (system Downloads picker, B2) added "bed440 MP3 00:10"; selected under Music file; toggle on; volume 100% (B3). See bug 3 (guide says Music file list has "Add a file..."). |
| B2 | Call 600, mute, record, analyse | PASS | Run 3 (stereo, 16 kHz): both channels have a clean 440 Hz tone, amplitude 0.1187 = bed at 100% (ch0 local, ch1 echoed by PBX while mic muted). Mono run 1: tone share 70%+ of energy. |
| B3 | Local channel has bed, remote has echoed bed | PASS | ch0 (local) 0.1187 steady; ch1 (remote echo) rms 0.0840 throughout, tone present (amp at exactly 440 Hz wobbles per 1-2 s window, see obs. 2). |
| B4 | Live volume 100% -> 20% from the in-call mixer | PASS | Slider tap showed "20%, Musicbed volume". rec3.wav: ch0 0.1187 -> 0.0241 (ratio 0.203 = 20.3%, -13.8 dB); rms ch1 0.0840 -> 0.0171 (0.204). Change took effect within the 2 s window. |
| B5 | Hold stops the bed | PASS | rec3.wav: from hold (t~38 s) to resume (t~58 s) rms = 0.0000 on BOTH channels (no bed, and no hold music audible in the recording since none is configured); after resume 0.0171 / 0.0241 (20%) returns. Meter row empty while held (D_hold). |
| B6 | Disable musicbed -> bed gone | PASS | rec4.wav (call 600 with musicbed off): rms 0.0000, 440 Hz -99 dBFS on both channels (the emulator mic is silent, so silence is expected). No chip (B7_incall_bed_off). |
| B7 | "Musicbed on" chip on the call screen | PASS | Shown in every call with the bed enabled (B4_incall_muted_rec, C8, C10, C16 Arabic "الموسيقى الخلفية قيد التشغيل"); absent when disabled. Chip stays while the call is held (obs. 3). |
| B8 | Recording includes local bed | PASS | see B2/B3. Mono format (run 1) mixes local+echo; levels there vary 0.05..0.2 because the two tones add with changing phase. |
| C1 | Keypad: mixer strip collapsed / expanded | PASS | C3_keypad_collapsed, C2_keypad_expanded_idle, C1_keypad_mixer_expanded; A5 shows the collapsed strip with three bars. Layout clean, no clipping. |
| C2 | In-call compact mixer, meters moving, 601 tone in speaker meter | PASS | C4_incall_mixer_601_a / _b: speaker meter ~50% lit, musicbed meter ~20% lit (bed at 20%), mic meter empty (silent emulator mic). Expanded (C5_devices_route) shows route chip, file chip, "Hear it myself". |
| C3 | Landscape keypad and in-call | PASS (note) | C8/C9: in-call fits, but the mixer is below the fold and needs a scroll (obs. 4). Landscape keypad shot not taken separately (rotation was done during a call only). |
| C4 | Large font 1.6 | PASS | C10, C11 (scrolled): no overflow, chips wrap to two lines, account chip ellipsizes ("Asterisk / F..."), mixer readable. |
| C5 | Arabic | PASS | C14/C15 keypad (mirrored strip, sliders fill from right), C16 in-call. All translated. |
| C6 | Dark theme | PASS | C12, C13. |
| C7 | Route chips: speaker <-> earpiece | BLOCKED (env) | The emulator exposes only the speaker device (`dumpsys audio`: only `speaker`, setCommunicationDevice type=2 for every call), so only one chip ("Speaker") is shown; the in-call Speaker toggle cannot move to an earpiece. Not testable on this AVD. The single chip renders correctly (C5). |
| C8 | Mic and speaker sliders change % | PASS | Swipes gave 44% (mic) and 153% (speaker) (C7_sliders_changed); returned to 100%. Settings > Audio shows the same state. |
| D1 | Inbound call from second registration | PASS | spcore_cli as 1002 called 1001: full-screen Incoming page (D1_incoming), answered, 00:06 timer (D2), remote hangup returns to keypad, recent entry (D3). |
| D2 | DTMF | PASS | Via 602 (logs digits; 600 is plain echo): `dtmf_all.log` `1234` from 1001. |
| D3 | Hold / unhold | PASS | "Resume" orange button, bed silenced and restored (B5). |
| D4 | Blind transfer of incoming 1002 call to 601 | PASS | Transfer > Blind > 601 > Transfer now: PBX `core show channels` shows `PJSIP/1002... 601 Playback(tone-long) Up`; app returned to keypad. |
| E1 | CPU idle, keypad with strip (collapsed), screen on | PASS | `top`: 0.0 / 0.5 / 0.5 % (RES 282 MB). |
| E2 | CPU during call 601, bed on, meters live, mixer expanded | PASS | 7.6 / 8.0 / 10.5 %. Idle expanded strip was not measured separately. |

Total: 24 PASS (incl. notes), 1 BLOCKED (C7 earpiece/speaker route switch), 0 FAIL.

## Environment limits
* No earpiece/Bluetooth/wired route on the AVD (C7).
* Emulator mic is silent: mic meter stays empty; no mic-gain effect is measurable.
* Speaker meters were only checked against the 601 tone; audibility cannot be heard.
* spcore_cli media does not reach the app (PBX advertises 10.0.2.2); signalling-only for D1/D4.

## Bugs / observations (none blocks the feature; no app crash seen)
1. **Live-volume doc/behaviour mismatch of the recording ("local" channel).** Not a bug: noted for clarity. The 20% change applies to both the sent bed and the local recording (ch0 dropped to 0.0241).
2. **Echoed bed (ch1) loses coherence at exactly 440 Hz in some windows** while rms stays constant (e.g. run 2: amp at 440 Hz alternating 0.012-0.119 with rms 0.084; run 3 at 20%: 0.0146-0.0242 vs 0.0171 rms). Looks like slight frequency/phase wobble in the received/echoed stream (jitter-buffer time stretching, PBX path) rather than a level change; the local channel is rock steady. Low severity, probably emulator/PBX path. Repro: record call to 600 with a pure tone bed, window at 1 s with Goertzel (`analyze_wav.py rec.wav 440 1`).
3. **Docs: "Music file" dropdown has no "Add a file..." entry.** USER_GUIDE says the list offers "Add a file..."; in Settings > Audio the dropdown lists only Choose a file / built-in / imported files. Importing is via Settings > Audio > Audio files > "Import a WAV or MP3...". Also the in-call mixer file chip ("Musicbed file: bed440. Tap to change.") was not exercised. Repro: Settings > Audio > Music file.
4. **"Musicbed on" chip stays visible while the call is on hold** although the bed is not sent (meter empty). Cosmetic. Repro: call with bed on, tap Hold.
5. **Landscape in-call: compact mixer is below the fold** (needs scrolling the right pane); action row labels for the 3rd row are also below the fold (C8). Same on phone with font 1.6 (C10 needs a scroll to see the mixer). Cosmetic/discoverability.
6. **Expanded in-call mixer on a phone is clipped by the End call area until scrolled** (B4/D_incall_mixer_20, C_incall_mixer_expanded): after "Show audio mixer" only the mic row and a sliver of the speaker row are visible above the End button; swipe up reveals all. It does scroll, so low severity; the page does not auto-scroll to the opened mixer.
7. **Caption "The microphone follows the selected audio output." sits directly on top of the speaker meter** in the expanded device section (C5), visually ambiguous which control it belongs to. Cosmetic.
8. Pre-existing/other: first attempt of the onboarding "Add account" with the soft keyboard produced an account pointing at `pbx.example.com` with a truncated password (my adb typing, not app logic; the Server field keeps the placeholder text as a real value until edited). Not reported as a bug.
9. Emulator: Android stylus-handwriting tutorial sheet popped over a text dialog and blocked it until `settings put secure stylus_handwriting_enabled 0` (environment).

Pull recordings with `adb exec-out run-as com.softphonepro.softphonepro cat app_flutter/Recordings/<file>.wav` (dir `app_flutter/Recordings`).
