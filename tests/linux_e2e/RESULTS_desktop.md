# SoftphonePro 1.1.0 Linux arm64: desktop integration QA

Package: `dist/linux/SoftphonePro-1.1.0-linux-arm64.deb`. Date 2026-10-20. No app code was changed.
Screenshots: `docs/qa-screenshots/v110_linux_desktop_*.png` (57 files; file names in the evidence column are abbreviated, the prefix is always `v110_linux_desktop_`).

## Environment

* Colima VM `spc-linux` (arm64 Docker). PBX `spc-qa-pbx` (172.30.0.10), accounts 1014 and 1015 used (1011 needs SRTP-SDES, which the app's default account profile rejects with 488, so it is not usable for plain incoming-call tests; 1012/1013 are WebRTC/TLS).
* `qa-desk-a`: ubuntu:24.04, 172.30.0.31, image `spc-qa-desk:arm64`. `qa-desk-b`: debian:12, 172.30.0.32, image `spc-qa-desk:debian12` (Dockerfile in `image/`).
* Each run: Xvfb :99 1280x900x24 + openbox + PulseAudio null sink + private `dbus-run-session`, non-root user `qa`. gnome-keyring 46 (Ubuntu) / 42 (Debian) with gcr-prompter. Fake services written for this pass: `lib/fake_sni_watcher.py`, `lib/fake_notifyd.py`, `lib/fake_secrets_hang.py`.
* `/.dockerenv` was removed in the containers: tray_manager treats it as a sandbox and then publishes a relative icon path (not an app bug).
* Wayland (W) was not tested.
* Scripts: `desktop_checks.sh` (host driver for the automatable checks, re-run and green), `lib/*` helpers.

## Results

| ID | Check | Result | Evidence |
|---|---|---|---|
| K1 | No Secret Service, first run: marker `secrets/backend`=`file`, password persists, registers after restart | PASS | App dir `~/.local/share/softphonepro/secrets/` holds `backend`=`file`, `secrets.enc`, `secrets.key` (0600). Log `secrets: first run, backend = file`. After kill and relaunch 1011 is `registered`. `k1_file_backend.png` |
| K2 | First run with unlocked gnome-keyring: marker `keyring`, secret in keyring | PASS | `secret-tool lookup account com.softphonepro.softphonepro.secureStorage` returns `{"account.<uuid>.password":"pass1011"}`; no `secrets.enc` written; registers after restart. Same on debian:12. |
| K3 | Locked keyring (marker `keyring`): unlock prompt, then keyring used, account registers | PASS | gcr-prompter "Unlock Login Keyring" appears (`k3_locked_prompt.png`), app window not shown and API closed meanwhile. Typing the password + Enter: API up 0.43 s later, `Locked=0`, account registered (`k3_after_unlock.png`). Startup delay = time the user takes at the prompt (wait up to 120 s) + ~0.4 s. |
| K4 | Prompt dismissed: file fallback, notice, marker stays; next start migrates | PASS | Escape: API up 0.23 s later, log `keyring still locked; using the file store for this session only`, marker still `keyring`, notice "Your keyring is locked, so saved passwords couldn't be read. Unlock it and restart SoftphonePro." (`k4_fallback_notice.png`). 1011 shows `failed` (its password is only in the keyring), as designed. Account 1012 added in that session (second `--provision`) registers and lands in `secrets.enc` (208 B). Next start with unlocked keyring: both keys in the keyring item, `secrets.enc` shrinks to 40 B (empty), both accounts register. |
| K5 | Hanging Secret Service: usable within ~4 s | PASS | Fake service owning `org.freedesktop.secrets` that never replies: API answers after 3.2 s (first run, marker -> `file`) and 3.2 s (marker `keyring` -> file fallback this session); API round trip 0.01 s afterwards. `k5_hang_marker_keyring.png`. See bug 6 (wording). |
| T1a | No StatusNotifierWatcher: closing the window quits | PASS | Click on the title-bar close button: process gone within 4 s; log `tray unavailable: no StatusNotifierWatcher on the session bus`. |
| T1b | `softphonepro --minimized` without watcher | PASS | `WM_STATE: Iconic`, not in `--onlyvisible`, process alive, account registered. |
| T2a | With watcher: item registered, properties | PASS | `Status=Active`, `Category=ApplicationStatus`, `IconName=/opt/softphonepro/data/flutter_assets/assets/branding/tray_linux.png`, `Title=softphonepro`, `Menu=/org/ayatana/NotificationItem/<id>/Menu`; no ToolTip property (see bug 5). Same on debian:12. |
| T2b | DBusMenu Hide/Show via `Event(id,"clicked")` | PASS | Menu: Hide SoftphonePro / Status (Available, Away, Do not disturb) / Accounts (qa1011 checked) / Quit SoftphonePro. Clicking Hide: no visible window, label becomes "Show SoftphonePro"; clicking Show: window visible again (also on debian:12). `t2_show_after_menu.png` |
| T2c | Close hides to tray, process stays | PASS | Close button: window gone, process alive, menu says Show. |
| T2d | Second `softphonepro` launch shows the window | PASS | Exit after 0.02 s, window visible 1.5 s later, menu back to Hide. `t2_second_launch.png` |
| T2e | Incoming call changes the tray icon | PASS | While ringing `IconName` alternates `tray_linux.png` / `tray_linux_alert.png` every ~0.7 s. `Status` stays `Active` (the code never uses NeedsAttention; only the icon flashes). |
| M1 | Idle: no MPRIS name | PASS | `playerctl -l` -> "No players found"; no `org.mpris.*` on the bus. |
| M2 | Ringing: name exists, Playing, play-pause answers | PASS | `playerctl -l` = `softphonepro`, status `Playing`, `Identity=SoftphonePro`, `DesktopEntry=com.softphonepro.softphonepro`; `play-pause` -> `/v1/calls` state `ringing_in` -> `active` (Ubuntu and debian:12). |
| M3 | Second play-pause | PASS | Setting `mediaKeyActive` default is "Hangs up" (Settings > Shortcuts, `h_shortcuts.png`): call ended. (`mute` variant not exercised.) |
| M4 | After the call the name is gone | PASS | `No players found` / empty name list. |
| N1 | Incoming call Notify with Answer/Decline | PASS | Fake notifyd logged `Notify app=SoftphonePro summary="Anonymous" body="Incoming call on qa1014" actions=[Answer,Answer,Decline,Decline]` (only when the window is not focused/in front, by design; with the window in front no notification). |
| N2 | ActionInvoked Answer answers; Decline rejects | PASS | `ActionInvoked(id,"Answer")` -> call `active` and window raised; `ActionInvoked(id,"Decline")` -> call gone, history `rejected`. `CloseNotification` is sent afterwards. (The action key is the label text, so it is localised.) |
| N3 | Missed call notification with Show action | PARTIAL | `Notify summary="Missed call" actions=["Show SoftphonePro",...]` appears. `ActionInvoked(id,"Show SoftphonePro")` restores the minimised window, but does not open Recents. See bug 3. `n_missed_show2.png`, `n_missed_show3.png` |
| L1 | `xdg-mime query default x-scheme-handler/sip` | PASS | `com.softphonepro.softphonepro.desktop` (also sips, tel, callto, softphonepro); `desktop-file-validate` clean. |
| L2 | `xdg-open sip:` / `tel:` while running | PASS | With `callLinksImmediately`: from A to a registered 1015, B shows `ringing_in` from 1014 in both cases. Without the setting the keypad is filled with the number (`l_sip_default.png`). |
| L3 | Cold `xdg-open sip:` | PASS | App launches (API 0.2 s), registers, exactly one history entry for the dialed number (14 -> 15). |
| L4 | `softphonepro --dial 1015` while running | PASS | B rings from 1014. |
| L5 | Bare second launch | PASS | Exits in 0.02 s, minimised window restored (Iconic -> Normal). |
| S1 | Start at login on: autostart file | PASS | `~/.config/autostart/SoftphonePro.desktop`: `Exec=/opt/softphonepro/softphonepro --minimized`, `desktop-file-validate` OK. With a bundle in `/home/qa/my apps/sp dir/`: `Exec="/home/qa/my apps/sp dir/softphonepro" --minimized`, valid. UI toggle driven with xdotool. `s_settings_adv.png` |
| S2 | Toggle off removes it | PASS | `~/.config/autostart/` empty afterwards. |
| H1 | Global hotkeys while another window has focus | PASS | With `display` window focused: Ctrl+Alt+A answers a ringing call, Ctrl+Alt+H hangs up, Ctrl+Alt+D restores the minimised window. |
| H2 | Rebind through the UI | PASS | Pencil on "Answer call", press Ctrl+Alt+K: label updated (`h_rebound.png`); old Ctrl+Alt+A no longer answers, Ctrl+Alt+K does. |
| LAN1 | Both devices see each other | PASS (after retry) | Nearby list with name, "Available", IP on both (`lan_b_nearby.png`). First start FAILED, see bug 2. |
| LAN2 | Pair with 6-digit SAS, confirm on both | PASS | Both dialogs show `301 729` (`lan_a_pair.png`, `lan_b_pair.png`), "Codes match" on both -> "Paired" (`lan_a_paired.png`). Pairing survives restart. |
| LAN3 | Chat both ways | PASS | A -> B "Hello from Ubuntu A", B -> A "Reply from Debian B", LAN badge, delivered ticks (`lan_a_got_reply.png`). |
| LAN4 | 1 MB file | PASS | Receiver gets an "Incoming file" dialog, Accept; `sha256` identical (`d0aa0cef...2087`), file in `~/Downloads/SoftphonePro/`. Listed on the LAN page "Files". |
| LAN5 | Call hand-off A -> B | PASS | Transfer > LAN: B asks "Transfer a call here?", Take call: B has the call (`172.30.0.31`), A shows "Relayed to Desk-B-Debian12" with Take back / End (`lan_a_handoff_relayed.png`). See bug 4 (layout). Not tried: pull, intercom, REFER mode. |
| W | Wayland | NOT TESTED | |

Counts: 32 PASS, 1 PARTIAL (N3), 1 not tested (W), 0 outright FAIL; 6 bugs below.

## Bugs (most severe first)

1. **App version is hard-coded to 1.0.0 in the 1.1.0 build.** `app/lib/services/engine_controller.dart:17` `const String kAppVersion = '1.0.0';`. Effects seen: `GET /v1/status` returns `"version":"1.0.0"`, Settings > Advanced shows `running, 1.0.0`, SIP `User-Agent: SoftphonePro/1.0.0` in the PBX registrar, and the same constant goes into the LAN hello and the update checker (a 1.1.0 install will keep offering/comparing as 1.0.0). `dpkg` and `flutter_assets/version.json` say 1.1.0. Repro: install the .deb, `softphonepro --provision cfg.json`, `curl -H "Authorization: Bearer $T" 127.0.0.1:7771/v1/status`.
2. **LAN Link fails to start when `xdg-user-dirs` is missing, and the recovery is half broken.** Repro: Debian 12/Ubuntu 24.04 minimal desktop-less install of the .deb (no `xdg-user-dir`, no `~/.config/user-dirs.dirs`; the .deb neither depends on nor recommends `xdg-user-dirs`), enable LAN Link: banner "LAN Link could not start: MissingPlatformDirectoryException(Unable to get application documents directory)" (`lan_a_discover.png`). After `apt install xdg-user-dirs` and **Retry**, discovery/pairing/chat/files work, but the LAN SIP listener is not started (no "SIP <port>" chip, call and intercom buttons greyed, handing a call over says "cannot take calls over the network (LAN calling is off there)"); only an app restart fixes it. The same `getApplicationDocumentsDirectory()` call is used for the recordings folder (`providers.dart:97`), so recordings would fail the same way. Suggested: fall back to `$HOME/Documents`/app data dir, add `xdg-user-dirs` to Recommends, make Retry start the whole LAN stack.
3. **Missed-call notification "Show SoftphonePro" action restores the window but does not open Recents.** Repro: minimise the window, let a call to your account ring and be cancelled by the caller, emit `ActionInvoked(<id>,"Show SoftphonePro")` on `org.freedesktop.Notifications` (or click the button): window comes back on the Keypad page, Recents badge stays. Code path `DesktopPlatformServices.showMissedCallNotification` adds `/recents` to `_routes`; `/v1/ui/show {"route":"/recents"}` navigates fine, so the stream-to-router hop does not take effect. The message notification uses the same path (`/messages`; not verified).
4. **Layout: the "Active calls" card is cut off by the Audio mixer card** on the Keypad page at the default 1200x780 window when a call card carries an extra banner (LAN "Relayed to ...", "Transferred call from ..."): the End call / Take back buttons are partly hidden (`lan_a_handoff_relayed.png`, `lan_b_handoff_taken.png`). (Mixer area belongs to the other QA pass; reported for completeness.)
5. **Tray quality issues on Linux.** (a) `trayManager.setToolTip` has no Linux implementation: every tooltip update logs `tray tooltip failed: MissingPluginException(... setToolTip ...)`, so the account/missed-call summary tooltip never shows. (b) Item `Title` is `softphonepro` (lower case), not "SoftphonePro". (c) Ringing only swaps the icon; `Status` never becomes `NeedsAttention`, so hosts that special-case attention (GNOME extension, KDE) will not highlight it. (d) My watcher saw 6 `RegisterStatusNotifierItem` calls for the same item in one start (a real watcher de-duplicates; unverified whether a real host is affected).
6. **Wrong wording when the Secret Service is hung/unreachable.** With a hung service and marker `keyring` the snackbar says "Your keyring is locked, so saved passwords couldn't be read. Unlock it and restart", although the keyring is unreachable, not locked (`k5_hang_marker_keyring.png`). Minor.

Other observations (not bugs): the Enter key in the LAN chat box inserts a newline (send button needed); the GTK file chooser is titled "Unnamed Window"; Linux `Close to tray` shows as ON in settings even when no tray host exists; a killed app leaves stale registrar contacts on the PBX (the app does not unregister on SIGTERM), which made incoming calls fork to dead ports until cleaned (`lib/pbx_clean.sh`).

## Not covered

Wayland (W); KWallet; real GNOME Shell/KDE tray hosts and notification daemons (fake servers only); `mediaKeyActive=mute`; LAN pull-call, intercom, REFER-mode hand-off; install over 1.0.0; audio (other agent).

## Final retest (merged main)

Image `spc-qa-desk:final` (`.deb` from merged main, Depends now include `xdg-user-dirs`), containers `qa-desk-a` .54 (acct 1014) and `qa-desk-b` .55 (1015), ubuntu:24.04, same session helpers as before (`/.dockerenv` moved away). Fake SNI watcher and fake notification server from `lib/`. New helper: `lib/hold_port.py` (occupies a TCP+UDP port). Containers removed afterwards.

| ID | Check | Result | Evidence |
|---|---|---|---|
| R2 | LAN Retry brings up the whole LAN stack | PASS | The old trigger no longer fails: with `xdg-user-dirs` removed (`dpkg --force-depends -r`) and no `user-dirs.dirs`, LAN Link starts cleanly (SIP chip `SIP 50763`, `r2_a_lan_start.png`). To force a start failure another way: app started with `lanEnabled:false`, `lanLinkPort:47001`, a process holding TCP+UDP 47001, then "Turn on LAN Link" in the UI -> banner "LAN Link could not start: Network error: Failed to create server socket" + Retry. Freed the port, clicked Retry: "Visible on your network", `172.30.0.54`, **`SIP 56771` chip present**, Desk-B discovered. Pair: both show 502 979, Codes match -> Paired, chat A->B ("Hello from A after Retry", delivered ticks, B badge) and B->A both work, call and intercom buttons enabled on the paired card, A called PBX 600 (echo), Transfer > LAN > Desk-B: B "Transfer a call here?" -> Take call: B has the call (`172.30.0.54`, active), A shows "Relayed to Desk-B" with Take back / End (`r2_handoff_a/b.png`). Not covered: the exact old failing path (documents-dir exception) because the app no longer throws there. |
| R3 | Missed-call "Show" brings the window up and shows Recents | PASS | B called A and cancelled: `Notify summary="Missed call" actions=["Show SoftphonePro",...]`. With the window minimised on Keypad (`Iconic`), `ActionInvoked(2,"Show SoftphonePro")` -> `Normal`, visible, **Recents page with the "1015 Missed" entry** (`r3_missed_show_after.png`). |
| R4a | item registrations per start | PARTIAL | 3 `RegisterStatusNotifierItem` calls in the first ~2.5 s of a start (was 6), all for the same path. Each tray menu rebuild (status change, Hide, Show) adds one more (6 after four clicks). Item still registered repeatedly; a real watcher probably de-duplicates (unverified). |
| R4b | no `MissingPluginException` from `setToolTip` | PASS | 0 occurrences in the log (`SOFTPHONEPRO_DEBUG_DESKTOP=1`) across start, status changes and Hide/Show. |
| R4c | Show/Hide menu | PASS | Menu: Hide SoftphonePro / Status / Accounts / Quit. Click Hide -> no visible window, label "Show SoftphonePro"; click Show -> visible, `Normal`, label "Hide SoftphonePro". |

Not re-checked in this pass: everything else from the first pass (keyring, MPRIS, notifications Answer/Decline, hotkeys, autostart), Wayland.
