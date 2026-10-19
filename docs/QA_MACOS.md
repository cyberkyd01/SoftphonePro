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
