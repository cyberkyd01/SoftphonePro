# SoftphonePro 1.1.0 Linux arm64: calls, audio, musicbed, mixer QA

Date 2026-10-20. Package `dist/linux/SoftphonePro-1.1.0-linux-arm64.deb` (installed with `apt-get install ./...deb`, no errors).
Scripts, helpers and the raw JSON results are in `tests/linux_e2e/audio/` (see "Rerun"). Screenshots: `docs/qa-screenshots/v110_linux_audio_*.png`.

## Environment

* Docker VM `spc-linux` (colima), `--platform linux/arm64`, network `spc-qa`, Asterisk `spc-qa-pbx` 172.30.0.10 (untouched).
* Images: `spc-qa-audio:arm64` (ubuntu:24.04), `spc-qa-audio-deb12:arm64` (debian:12), `spc-qa-audio-noxdg:arm64` (ubuntu:24.04 without xdg-user-dirs, bug 1 only).
  Dockerfile: `tests/linux_e2e/audio/docker/Dockerfile` (copy the .deb next to it as `SoftphonePro.deb`). Tools: openbox, xvfb, dbus-x11, xdotool, imagemagick, python3-numpy, sox, lame, pulseaudio, libasound2-plugins, zenity, curl, fonts-noto-core.
* Containers (all removed at the end): A `qa-audio-a` .21 acct 1001, B `qa-audio-b` .22 acct 1002 (ubuntu); `qa-audio-d1` .23 acct 1003, `qa-audio-d2` .24 acct 1004 (debian 12); `qa-audio-x` .25 acct 1005 (bug repro). Only accounts 1001-1005.
* Each app runs as non-root user `qa` under `dbus-run-session`, Xvfb :99 1280x900x24, openbox (the window is unmapped / paints black without a window manager), PulseAudio with null sink `out` (default output) and `micfeed` (default source = `micfeed.monitor`; "speaking" = `paplay --device=micfeed tone.wav`). App started with local `--provision` (automation API, auto-record stereo WAV). Encrypted-file secret store (no keyring). GL is software (llvmpipe).
* Analysis: stereo WAV recordings (left = local side, right = remote side) analysed with numpy FFT (`tone.py`), segments aligned to the hang-up time.
* The file picker (zenity) was driven with xdotool like a user, so the provisioning shortcut for the musicbed file was not needed (it cannot set the file anyway; `musicbedFile` is not an exportable key).

## Results

| id | check | result | evidence |
|---|---|---|---|
| A1 | .deb installs on ubuntu:24.04 | PASS | `dpkg -l softphonepro` 1.1.0 arm64, apt resolved deps |
| A2 | .deb installs on debian:12 | PASS | same, `PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"` |
| A3 | `/v1/status` version is 1.1.0 | **FAIL** | reports `"version":"1.0.0"` on both OSes, engine too (bug 2). The package itself is 1.1.0 (version.json 1.1.0+2) |
| A4 | launch, API up, A=1001 and B=1002 register | PASS | API up < 2 s after launch, regState registered, regCode 200 |
| A5 | call A->B, B answers via API, hang up | PASS | dialing -> ringing_in -> active/confirmed on both, hangup -> ended (ubuntu); same on debian (A-deb-call) |
| A6 | `LANG=C` gives English UI | PASS | `v110_linux_audio_A_lang_C_english.png`, process env LANG=C LC_ALL=C |
| A7 | basic call + musicbed on debian:12 | PASS | `debian_checks.json`: file chosen via UI, bed -11.5 dBFS at B with A muted, 0.2 vol -> -23.3 dBFS |
| B0 | musicbed file chosen through the UI (zenity) | PASS | Settings > Audio > Audio files > Import a WAV or MP3: Ctrl+L, typed path, Enter (twice: first Enter selects the file); toast `Added "tone440"` (10 s, MP3); then Music file dropdown. `GET /v1/audio` file=tone440 (ubuntu and debian) |
| B1 | bed (440 Hz) reaches B while A's mic is muted | PASS | B right ch, steady section: 440 Hz -10.8 dBFS (tone is -6 dBFS RMS in the file); A's 1 kHz mic feed -90 dBFS = muted |
| B2 | live volume 1.0 -> 0.2 | PASS | -9.5 -> -23.3 dBFS = 13.8 dB (ideal 13.98) |
| B3 | no bed to a locally held call | PASS | 440 Hz exactly absent; B hears Asterisk MOH (peaks wander 427-452 Hz at about -34 dBFS, total -13); `test_hold_repeat.py`: same level with the bed disabled (-33.8/-34.0/-180), so it is PBX MOH, not the bed |
| B4 | bed back after unhold | PASS | -10.3 dBFS |
| B5 | bed gone when disabled | PASS | digital silence (-180 dBFS) |
| B6 | bed gone when paused (`musicbedPaused`) | PASS | -180 dBFS, `levels.musicbed` 0, `musicbed.paused` true |
| B7 | A unmuted + 1 kHz in mic: B hears voice and bed | PASS | 1 kHz -21.9 dBFS and 440 Hz -10.4 dBFS together, 440 Hz level unchanged by the voice |
| B8 | mute silences the voice but not the bed | PASS | 1 kHz -90.2 muted vs -21.9 unmuted |
| B9 | A's own recording has the bed on the local (left) side | PASS | A left: 440 Hz -10.8 dBFS; off/paused -180; 1 kHz only when unmuted (-21.7 vs -124.6) |
| B10 | A's recording right = remote side (B's 880 Hz feed) | PASS | -21.8 dBFS, no 440 leak on the remote side (-96) |
| B11 | loop has no gap at the seam (10 s file, 27 s span) | PASS | no >3 dB dip in the 20 ms envelope |
| L1 | `levels.musicbed` > 0 while playing, 0 off/paused/held | PASS | 99 / 64 (vol 0.2) / 0 (held, off, paused) |
| L2 | `levels.mic` > 0 while the mic is fed | PASS | 67 (continuous tone), 88-98 (tremolo tone); 0 while muted |
| L3 | `levels.speaker` > 0 when B sends audio | PASS | 67 (A hears B's 880 Hz), 0 while held |
| M1 | monitor off: nothing on A's output sink | PASS | `parec out.monitor`: no samples |
| M2 | "Hear it myself": bed on A's output sink (even with no call) | PASS | -15.7 dBFS at monitor volume 0.5 |
| M3 | monitor volume scales the monitor | PASS | 0.5 -> 1.0: -15.7 -> -9.5 dBFS (+6.2 dB) |
| M4 | monitor in a call: A's sink has bed and the far end | PASS | 440 Hz -15.5, 880 Hz -33.4 (monitorVolume 0.5) |
| M5 | far-end bed level independent of monitor volume | PASS | -10.8 vs -11.7 dBFS at B (0.5 vs 1.0) |
| P1 | musicbed setting and file persist across restart | PASS | enabled, file tone440, volume 0.7 after restart (no --provision) |
| P2 | bed plays on the next call after restart | PASS | B hears 440 Hz -12.6 dBFS at vol 0.7 |
| API1 | `/v1/audio` validation | PASS | invalid_mic_level, invalid_speaker_level, invalid_musicbed_volume, invalid_musicbed_monitor_volume, invalid_musicbed_enabled, invalid_field (400); 0 and 2 accepted; 401 without token |
| API2 | `musicbedEnabled:true` with no file | PASS | 409 `no_musicbed_file` |
| API3 | SSE `audio` events | PASS | 7 events for enable/start, monitor, pause, resume, disable/stop; none sent for the volume-only change |
| C1 | keypad at desktop size shows the mixer card | PASS | `01_keypad_desktop_idle`, `10_keypad_desktop_1240x860`: Inter font, three meters + sliders + two pickers + musicbed switch |
| C2 | in-call: meters move, "Musicbed on" chip | PASS | `02_incall_desktop_1..3`: levels 65/39/92 (mic) and 94/63/1 (speaker) one second apart; chip and REC visible |
| C3 | Settings > Audio: musicbed group and mixer | PASS (cosmetic notes) | `09_settings_audio_desktop_a/b` |
| C4 | phone width 400x820: keypad strip collapsed / expanded | PASS (issue 4) | `03`, `04`, `07`, `08`, `08b` |
| C5 | phone width: in-call page compact mixer | PASS (issue 4) | `05`, `05b`, `06` (below the fold, needs a scroll; expands with "Show devices and musicbed") |
| C6 | dark theme (keypad, in call, settings, phone) | PASS | `11`-`15`: contrast fine, meters readable |
| C7 | Arabic RTL, desktop | **FAIL (partial)** | layout mirrored correctly, meters fill from the right, but the left nav rail labels render as tofu boxes (issue 6) |
| C8 | Arabic RTL, phone width | PASS | `17`, `18`: bottom-nav labels, strip and in-call page mirrored |
| C9 | slider drags (xdotool) change values | PASS | mic 1.0 -> 1.5, speaker 1.0 -> 0.5, musicbed 0.5 -> 1.5, read back from `GET /v1/audio` |
| C10 | UI device pickers change devices | PASS | pickers offer System default / default / pulse; `devices` became `{"capture":"ALSA:pulse","playback":"ALSA:pulse"}`; a call then worked with both (bed -9.5 dBFS at B, voice -20 dBFS) |
| C11 | API changes are followed by the UI sliders/switches | PASS | Settings slider showed 50% after `POST /v1/audio` |
| D1 | idle CPU, keypad + mixer card visible, no call | PASS | 0.2-0.3 % of one core over 20 s (Recents baseline 0.3-0.5 %) |
| D2 | CPU in a call with meters animating | **NOTE (issue 3)** | desktop keypad: 76 % of one core (software GL); phone width 25 %; with static meters (no bed, no feed) 11.7 %; bed only 47 % |
| E1 | file removed while enabled, restart | PASS | bed switched off (`enabled:false`), notice (snackbar, Arabic at the time) "file no longer available, so the feature was switched off" visible for > 3 s: `E1_restart_missing_file_*` |
| E2 | text file renamed .mp3 | PASS | rejected at import: "This audio file cannot be used (unsupported or corrupt audio file (need WAV or MP3)). Use PCM, mu-law or A-law WAV, or MP3."; nothing added to the library: `E2_invalid_mp3_*` |
| R1 | recording works on a minimal system without xdg-user-dirs | **FAIL (bug 1)** | auto-record and the Record button do nothing, no message |

Tally: 44 PASS, 3 FAIL (A3, C7, R1), 1 performance NOTE (D2), plus the visual issues below.

## Bugs and issues (most severe first)

1. **Recording silently fails when `xdg-user-dirs` is not installed** (medium-high; recording is part of the musicbed contract).
   Repro: ubuntu:24.04 (or debian:12) with the .deb installed but no `xdg-user-dir` binary (the .deb does not depend on it; typical for minimal / Lite installs, containers), auto-record on or press Record in a call.
   Result: `call.recording` stays false, the REC button stays black (`v110_linux_audio_noxdg_manual_record_click.png`), no notice; stderr has
   `Unhandled Exception: MissingPlatformDirectoryException(Unable to get application documents directory) #0 getApplicationDocumentsDirectory ... recordingsDirProvider (providers.dart:97) ... CallsController.startRecording (calls_controller.dart:1664)`.
   Fix ideas: fall back to `~/.local/share/softphonepro/Recordings` when `getApplicationDocumentsDirectory` throws, show an error, and add `xdg-user-dirs` to Depends/Recommends. Script: `test_noxdg_recording.py` (image `spc-qa-audio-noxdg`).
2. **App version constant is still 1.0.0** (medium). `app/lib/services/engine_controller.dart:17 const String kAppVersion = '1.0.0'` although pubspec/package are 1.1.0. Effects seen: `/v1/status` version and engine version 1.0.0; the SIP `User-Agent` is `SoftphonePro/1.0.0`; Settings > About, LAN-link app version and the update checker (`update_checker.dart:237` parses `kAppVersion`) use it too, so a 1.1.0 install will see 1.1.0 as an available update.
3. **High UI CPU while meters animate** (medium, needs a real-hardware check). In a call on the desktop keypad the app uses about 76 % of one core (software GL, llvmpipe under Xvfb in an arm64 VM); with all meters flat 11.7 %, with only the steady musicbed meter 47 %; phone width about 25 %; idle with the mixer card visible 0.2 %. The meters appear to repaint a large area each frame (no repaint isolation). On a Raspberry Pi with a weak GPU this may be felt. `perf.json`, `perf_attrib.json`. (An attempt to isolate the engine by minimising the window gave inconsistent numbers, 2.4 % once and 74 % once, so engine-only cost is unproven.)
4. **Mixer layout clipping** (low).
   a. Phone keypad strip with devices expanded ("Show devices and musicbed" is shared state with the in-call page) is capped at about 200 px and clips mid-widget (second picker cut, musicbed row and "Show fewer controls" only after scrolling inside the strip; no scroll cue): `07`/`08`/`08b`, state shown in the first keypad shot of that group.
   b. Desktop mixer card in the in-call right panel scrolls inside itself; at 1200x780 and 1240x860 the "Hear it myself" switch is cut off at the card's bottom edge (`10_..._1240x860`, `12_dark_incall_desktop`).
   c. Settings > Audio while a call is active (right panel visible, 1240 px wide): the settings pane is squeezed, "Microphone" breaks mid-word as "Microph / one", "Music file" wraps, the Ringer subtitle takes 5 lines (`13_dark_settings_audio_incall`).
   d. Phone in-call page: the mixer is below the fold at 400x820 (needs scrolling); the speaker meter touches the input picker border when devices are expanded (`06`).
5. **Sliders are inset from their meters** (cosmetic): every slider track starts and ends 14-24 px inside the meter bar above it (desktop card, phone strip, Settings), so the thumb position does not line up with the level bar ends. Also "Audio files" appears twice in Settings > Audio (musicbed group and Voice and files), and `GET /v1/audio` `devices` shows `ALSA:pulse` for a picked device while the docs say device names / `default`.
6. **Tofu glyphs** (low-medium, may be environment): Arabic desktop left nav rail labels (`16_arabic_dark_incall_desktop`, `E1_...`) and the Hindi entry of the language picker render as empty boxes although `fonts-noto-core` (Noto Sans Arabic UI, Devanagari) is installed and fontconfig finds them. Other Arabic text (calls panel, phone bottom nav) renders fine, so the rail text style probably lacks a fallback. Verify on a real desktop.
7. Observations, not audio bugs: a continuous pure sine on the mic is removed by noise suppression (mic level 0, B hears nothing) while modulated tones pass, so use tremolo/noise as test voice; in the UI the remote party of an outgoing call to the Asterisk test PBX shows as `s` ("From 1002" on the phone page) while the API `display` is empty (probably the PBX connected-line, not checked); a bare Xvfb without a window manager leaves the app window black/unmapped for a long time.

## Not tested

Real audio hardware, Bluetooth, Wayland, PipeWire; bed in a local conference (needs 3 parties) and during transfers; the 30 minute limit; B-side musicbed through the UI (a mic feed was used for B instead); hold with a non-default hold-music track; tray/keyring/MPRIS/notifications/LAN (other QA agent); Raspberry Pi hardware (only debian:12 arm64 in a VM).

## Rerun

```sh
export DOCKER_HOST=unix://$HOME/.colima/<profile>/docker.sock   # any Docker host with arm64 support
cd tests/linux_e2e/audio/docker && cp ../../../../dist/linux/SoftphonePro-1.1.0-linux-arm64.deb SoftphonePro.deb
docker build --platform linux/arm64 -t spc-qa-audio:arm64 .      # --build-arg BASE=debian:12 for the Debian image, --build-arg XDG=0 for bug 1
cd .. && for n in a:21 b:22; do docker run -d --platform linux/arm64 --name qa-audio-${n%%:*} --network spc-qa --ip 172.30.0.${n##*:} -v "$PWD":/e2e --shm-size=512m spc-qa-audio:arm64 sleep infinity; done
python3 boot_pair.py                       # boots A (1001) and B (1002) with auto-record
docker exec qa-audio-a bash -c 'mkdir -p /home/qa/Music && cd /home/qa/Music && sox -n -r 44100 -c 2 t.wav synth 10 sine 440 vol 0.5 && lame --quiet t.wav tone440.mp3 && chown -R qa . '
python3 -c "import ui_choose_musicbed as u; u.run('qa-audio-a','/home/qa/Music/tone440.mp3','tone440')"   # then click the item in the dropdown (1050,781)
python3 test_musicbed_call.py; python3 test_monitor_persist.py; python3 test_api_audio.py; python3 test_hold_repeat.py
python3 test_perf.py; python3 test_perf_attrib.py; python3 test_robustness.py; python3 test_robustness_e2.py
# debian: containers qa-audio-d1/.23 and qa-audio-d2/.24 from spc-qa-audio-deb12:arm64, then python3 test_debian12.py
```

Files: `lib_qa.py` (helpers), `node_boot.sh`/`app_start.sh` (in-container boot), `tone.py`/`envelope.py` (analysis), `boot_pair.py`, `ui_choose_musicbed.py`, `ui_shots_call.py`, `test_*.py`, `out/*.json` (results of the final runs).

## Final retest (merged main)

Build: `build_linux.sh --docker --arch arm64` from the merged main, `SoftphonePro-1.1.0-linux-arm64.deb` (Depends now include `xdg-user-dirs`). Images `spc-qa-audio:final` (built with `--build-arg XDG=0`, so `~/Documents` is not set up) and `spc-qa-desk:final`. `/v1/status` now reports app version 1.1.0 (A3 fixed; `engine.version` still says `1.0.0`). Containers A/B `.51/.52` (accts 1001/1002), X `.53` (1005); all removed afterwards. Screenshots: `docs/qa-screenshots/v110_linux_final_*.png`. Scripts: `audio/test_perf_final.py`, `audio/test_final_r5.py`, `out/perf_final.json`. In the new build the "Audio files" import and the music-file picker moved (Settings > Audio > Voice and files > Audio files; built-in tracks exist), so the UI was re-driven by screenshot; the imported file is a 10 s 440 Hz WAV named `t`.

| id | check | result | evidence |
|---|---|---|---|
| R1 | meter CPU in a call drops (software GL) | **FAIL** | desktop keypad 1280x800, call with mic+speaker+bed meters animating, 10 s warm-up then 20 s: **78.1 %** of one core (before 76-81 %). Phone width 400x820: **22.7 %** (before 25-29 %). No clear drop. Per-thread: 8 `llvmpipe-N` workers 8.3-9.4 % each (about 70 % total), `io.flutter.raster` 1.9 %, UI thread 1.9 %. Meters do move (screenshots 1 s apart `desktop_1280x800_meters_1/2`, `phone_400x820_meters_1/2` differ; `levels` speaker 80->93, mic 0->91). Probable cause: `RasterCostMonitor` (`audio_levels.dart`, threshold 12 ms median of `FrameTiming.rasterDuration`) never flips to slow because llvmpipe does the work on its own worker threads, so the raster thread's frame time stays small; the 5 Hz mode does not engage in this software-GL setup (not proven, no instrumentation). Static-meter reference from the first pass: 11.7 % |
| R5 | manual Record button, no `~/Documents` | PASS | (a) xdg-user-dirs installed but never run (`xdg-user-dir DOCUMENTS` = `/home/qa`): click Record at (1179,264) -> `recording` true, second click -> false, file `~/Recordings/rec_*_1002.wav` (105 KB); (b) xdg-user-dirs removed with `dpkg --force-depends -r` (no `xdg-user-dir` binary): same, file `~/Documents/Recordings/rec_*.wav`; no "Unhandled"/exception lines in stderr in either run. Screenshots `r5_nodocs_*`, `r5_nobin_*` |
| R6 | musicbed regression | PASS | `test_musicbed_call.py`: all 15 checks PASS. Bed at far end -11.1 dBFS (before -10.8); volume 1.0 -> 0.2: -11.1 -> -26.3 dBFS = 15.2 dB (before 13.8, ideal 13.98; 1.2 dB off, within the test's 10-18 dB window, WAV source instead of MP3); held: 440 Hz -55.2 (MOH only); unhold -10.9; disabled/paused -180; unmuted voice 1 kHz -21.8 with bed -9.1; A's recording left has the bed (-10.2), right has B's 880 Hz (-21.8, no 440 leak -96); seam check no dip <25 s; levels mic/speaker/musicbed 67/67/100 |
| R7 | screenshots | PASS | `desktop_incall_mixer`, `phone_incall`, `arabic_desktop_incall`, `settings_audio_desktop` (+ meters pairs). Arabic desktop: nav rail labels now render as Arabic text (bug 6 / C7 tofu is gone); layout mirrored. |
| A3 | version constant | PASS (fixed) | `/v1/status` `"version":"1.1.0"` |

Observations: phone in-call page at 400x820 has the red End call button overlapping the label row of the third button row ("Merge"/"Stop" labels clipped, `phone_incall.png`); everything else in the new layouts looks right (mixer fits at 1280x800).

## Retest 2 (low-power meters + phone fit)

Image `spc-qa-audio:final2` (XDG=0), containers `.51/.52`, removed afterwards. Scripts: `audio/test_perf_final2.py`, `audio/test_final2_shots.py`, `audio/test_final2_shots2.py`; screenshots `docs/qa-screenshots/v110_linux_final2_*.png`.

* R1 CPU (same method as `test_perf_final.py`): desktop 1280x800 keypad **33.1 %** of one core (was 78.1 %); phone 400x820 **11.6 %** (was 22.7 %). Meters still move (screenshots 1 s apart; levels mic 0->52, speaker 81->88 desktop; mic 11->91 phone). Threads present: `llvmpipe-0..7`, `io.flutter.rast`, `io.flutter.ui`.
* Phone fit, in call, musicbed on, strip collapsed: 400x820 PASS (3 rows with labels above End, nothing clipped); 360x740 FAIL (third row Stop/Merge/More clipped, no labels, End call button overlaps it).
* Musicbed regression `test_musicbed_call.py`: all 15 checks PASS (volume drop 14.3 dB; hold 440 Hz -33.8 = MOH only).
