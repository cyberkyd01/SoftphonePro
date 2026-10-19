# SoftphonePro test PBX (Asterisk 20)

Self-contained Asterisk 20.6 (Ubuntu 24.04) in Docker for integration-testing SIP/IAX2 softphone features.

## Build / run

```bash
tests/sipserver/scripts/up.sh              # build image + start + wait for full boot; exports CA to certs/ca.crt
tests/sipserver/scripts/up.sh --emulator   # same, but advertise 10.0.2.2 (Android emulator clients)
tests/sipserver/scripts/verify.sh          # sanity checks inside the container
tests/sipserver/scripts/cli.sh             # Asterisk CLI (cli.sh "pjsip show contacts" for one-shot)
tests/sipserver/scripts/logs.sh | down.sh
```

`up.sh` runs `docker build` first and then `docker compose up --no-build` (compose's own build step fails on
machines without the `docker-credential-desktop` helper, e.g. colima setups).
Stage `base` of the Dockerfile is `softphonepro-pbx:base` (`docker build --target base -t softphonepro-pbx:base .`).

### IMPORTANT: colima needs the gRPC port forwarder for UDP

Colima's default `portForwarder: ssh` forwards TCP only, so UDP SIP/RTP/IAX2 from the Mac never reaches the container
(REGISTER over UDP times out with 503, TCP works). Fix (already applied on this machine, persisted in `~/.colima/default/colima.yaml`):

```bash
colima stop && colima start --port-forwarder grpc
```
With the gRPC forwarder UDP/TCP/TLS/WS/WSS/IAX2/RTP all work via `127.0.0.1`. Verified.

## Where clients connect

| Client | Host | Notes |
|---|---|---|
| Mac host (pjsua, desktop app, tests) | `127.0.0.1` (`export PBX_HOST=127.0.0.1`) | default mode |
| Android emulator | `10.0.2.2` | run `up.sh --emulator` |

Ports: UDP/TCP **5060**, TLS **5061**, WS **8088** (`/ws`), WSS **8089** (`/ws`), IAX2 **4569/udp**, RTP **10000-10099/udp**, AMI **5038** (`test`/`test`).

**Why one mode at a time:** behind Docker port-forwarding the PBX cannot know which address the client used to reach it, so
it puts one configured address (`PBX_EXTERNAL_ADDR`, default `127.0.0.1`) into SDP `c=`, Contact and ICE candidates.
Media is then latched symmetrically (`rtp_symmetric`, `force_rport`, `rewrite_contact`, `strictrtp=no`). For emulator runs restart
with `up.sh --emulator` (or `PBX_EXTERNAL_ADDR=10.0.2.2 docker compose up -d`). Host and emulator clients cannot do media simultaneously
(signaling would work for both). A real LAN device could use `PBX_EXTERNAL_ADDR=<Mac LAN IP>`.

TLS/WSS: self-signed CA exported to `tests/sipserver/certs/ca.crt` (also `docker cp softphonepro-pbx:/etc/asterisk/keys/ca.crt .`).
Server cert SANs: `localhost, softphonepro-pbx, pbx.test, 127.0.0.1, 10.0.2.2, ::1`. TLS method is `sslv23` (negotiates TLS1.2/1.3).
Realm is the default (`asterisk`); pjsua needs `--realm '*'`.

## Accounts

SIP password = `pass` + extension (1001 -> `pass1001`). All registrations: `max_contacts=5`, `remove_existing=yes`, min expiry 10 s.
Codecs: ulaw, alaw, g722, opus, gsm, ilbc, speex, g729 (opus/ilbc/g729 are passthrough only - Asterisk has no transcoder for them; speex/gsm/g722/ulaw/alaw transcode).

| Ext | Auth | Transport / media | Notes |
|---|---|---|---|
| 1001-1010 | pass100x | UDP/TCP/TLS/WS/WSS, RTP | mailbox `100x@default` (MWI + voicemail on no-answer/busy), BLF/presence subscribe, pickup group `sales`, `message_context=messages` |
| 1011 | pass1011 | SRTP required (SDES, no fallback) | plain-RTP offers get 488 (verified) |
| 1012 | pass1012 | WebRTC: DTLS-SRTP, ICE, rtcp-mux, AVPF; opus/g722/ulaw | register over WSS (`wss://HOST:8089/ws`) |
| 1013 | pass1013 | TLS: endpoint `transport=transport-tls` | Asterisk does not hard-reject non-TLS registers; outbound calls to it use TLS |
| 1014, 1016-1020 | pass10xx | normal | |
| 1015 | pass1015 | normal | `dtmf_mode=info` (SIP INFO) |
| 2001-2005 | pass200x | IAX2 `type=friend`, host=dynamic, ulaw/alaw/gsm | `requirecalltoken=no`; SIP<->IAX2 dialing works |

## Test extensions (context `default`)

| Dial | What |
|---|---|
| 1001-1020 / 2001-2005 | dial the endpoint (30 s), hints for BLF. 1001-1010 fall to voicemail |
| 600 | Echo |
| 601 | plays a 440 Hz tone (3 x 30 s) after 1 s - measure received level (verified RMS ~10700/32767 at 16 kHz) |
| 602 | Answer, `Read` 4 digits (or `#`-terminated), logs them, `SayDigits`, hangup |
| 603 | Answer, wait 2 s, hang up |
| 604 | Answer + endless music-on-hold tone (hold tests) |
| 700 | park (slots 701-720 via `res_parking`; dial 701... to retrieve) |
| `*8` | group pickup (named group `sales`, endpoints 1001-1010); `**XXXX` directed pickup of ringing ext XXXX (verified) |
| 800 | ConfBridge room 800 |
| `*97` | VoiceMailMain for caller's own mailbox (no PIN); `*98` asks for mailbox + PIN |
| 1999 | plays a tone, then Asterisk sends **REFER** (`Refer-To: sip:600@<PBX addr>`) to the caller -> tests incoming REFER (verified; pjsua follows it) |
| 1998XXXX | intercom to XXXX; callee INVITE gets `Call-Info: <sip:pbx>;answer-after=0` and `Alert-Info: <http://www.notused>;info=alert-autoanswer` (verified) |

Voicemail: mailboxes 1001-1010, PIN `1234`. 1001 and 1002 are pre-seeded with 2 new messages (MWI `Messages-Waiting: yes`, `Voice-Message: 2/0` is sent on REGISTER).

## Reading DTMF received on 602

```bash
docker exec softphonepro-pbx cat /var/log/asterisk/dtmf_1002.txt     # last digits from ext 1002
docker exec softphonepro-pbx cat /var/log/asterisk/dtmf_all.log      # timestamped history (all callers)
docker exec softphonepro-pbx grep DTMF_RECEIVED /var/log/asterisk/full
```
Also an AMI `UserEvent` (`UserEvent: DTMFReceived`, `Caller`, `Digits`, `Status`) and per-digit `DTMF` lines in `/var/log/asterisk/full`.
Files are cleared on container start.

## AMI

`test`/`test`, port 5038, all permissions. Example (inject events / send a SIP MESSAGE / reload):
```bash
printf 'Action: Login\r\nUsername: test\r\nSecret: test\r\n\r\nAction: MessageSend\r\nTo: pjsip:1002\r\nFrom: sip:pbx@127.0.0.1\r\nBody: hi\r\n\r\nAction: Logoff\r\n\r\n' | nc 127.0.0.1 5038
```
(`To: pjsip:1002` requires 1002 to be registered; an AMI client can subscribe to `UserEvent` for 602 results.)

## Sending NOTIFY / MESSAGE / calls from the Asterisk CLI

```bash
scripts/cli.sh "pjsip show contacts"
scripts/cli.sh "pjsip send notify mwi-on endpoint 1001"      # types from pjsip_notify.conf
scripts/cli.sh "originate PJSIP/1001 extension 603@default"  # ring 1001 from the PBX
```
- MWI: seeded messages cause an unsolicited NOTIFY on registration. Force one any time (verified): `scripts/cli.sh "pjsip send notify mwi-on endpoint 1005"` / `mwi-off` (types in `config/pjsip_notify.conf`, also `check-sync`).
- SIP MESSAGE: a MESSAGE from any endpoint to `sip:1002@host` is routed in context `messages` via `MessageSend` (verified 1001 -> 1002). From outside use the AMI `MessageSend` action above (there is no `messagesend` CLI command in Asterisk 20).
- Log all SIP: `scripts/cli.sh "pjsip set logger on"` then `scripts/logs.sh`.

## Verified from the Mac host (pjsua 2.17, colima gRPC forwarder)

REGISTER 200 + echo call (600) with ~350+ RTP packets received in 7 s for UDP, TCP and TLS (CA verified); WS and WSS REGISTER
(`scripts/ws_register_check.py HOST ws|wss EXT`) -> 401 then 200; IAX2 peer 2001 registered from a second Asterisk and PBX->IAX2 call answered; 601 tone received;
602 DTMF logged; 1011 SRTP/SDES; 1998 headers; 1999 REFER; MESSAGE; MWI NOTIFY; directed pickup; 800/604/`*97`/700/603 answer.

## Known limitations

- UDP from the Mac needs colima `--port-forwarder grpc` (see above); plain Docker Desktop/Linux Docker work out of the box.
- Single advertised address per run (`PBX_EXTERNAL_ADDR`): host-based XOR emulator media.
- Docker/gRPC forwarding makes the PBX see all clients as the docker gateway (`172.18.0.1`) with differing ports; fine for tests, not for IP-based identification.
- Opus, iLBC, G.729 are passthrough only (no transcoding), so calls between an opus-only and a g711-only endpoint have no common codec (488). No G.729 license/codec.
- 1013 "TLS-only" is not enforced for inbound REGISTER on other transports.
- DTLS-SRTP/ICE (1012) was verified at registration level only (no browser/WebRTC media test); ICE host candidates are rewritten to `PBX_EXTERNAL_ADDR`.
- Siren7/14 "bps" warnings in the log come from pjsua offers and are harmless. Voicemail/parking state is lost when the container is recreated.
- Android-emulator mode (`--emulator`) was configured but not exercised with a real emulator.
