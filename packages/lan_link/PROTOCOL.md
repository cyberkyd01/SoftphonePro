# SoftphonePro LAN Link protocol (SPP v1)

Status: implemented by `package:lan_link`. All integers are big-endian. All JSON
is UTF-8. Binary values inside JSON are unpadded base64url ("b64").

## 1. Identity

Each device has, generated once and persisted through `KeyStore`:

* Ed25519 signing key pair (authenticates the device).
* X25519 static key pair.

`deviceId` = first 16 lowercase hex chars of SHA-256(ed25519 public key, 32 B).
Anything that carries both a deviceId and a key is rejected unless they match.

`DeviceInfo` (public, unauthenticated; used in beacons, `/info` and `peer.info`):

```json
{"deviceId":"…","name":"…≤64","platform":"≤16","linkPort":0-65535,"sipPort":0-65535,
 "ed25519Pub":"b64(32)","x25519Pub":"b64(32)","status":"available|busy|dnd|onCall",
 "appVersion":"≤32","aors":["≤8 entries, ≤128 chars; only if the user opted in"],
 "capabilities":["chat","files","handoff","intercom"]}
```

Control characters are replaced with spaces; unknown capabilities/statuses are
dropped/defaulted. Trust never derives from this data - only from the handshake.

## 2. Discovery

### 2.1 Multicast beacons (fallback; mDNS `_softphonepro._tcp` is preferred where available)

UDP, group `239.255.77.77`, port `47777` (configurable), TTL 1, loopback on.
Socket bound to `0.0.0.0:port` with `reuseAddress` (+ `reusePort` where supported),
group joined on every IPv4 interface (per-interface failures tolerated).

Datagrams (max 2048 B, JSON):

* `{"spp":1,"t":"beacon","info":<DeviceInfo>}` - every 3 s, and immediately when our
  info changes.
* `{"spp":1,"t":"probe","id":"<senderId>"}` - sent once on start; every receiver
  (other than the sender) answers with a unicast beacon to the datagram's source
  address:port after 0-300 ms of jitter.

Receivers ignore their own beacons, drop anything malformed (never throw), keep at
most 256 peers, and expire a peer after 12 s without a beacon. The datagram's source
address is the peer's address; its TCP port is `info.linkPort`.

### 2.2 Manual

`GET http://host:port/spp/v1/info` (e.g. host/port from a QR code) returns the
`DeviceInfo` JSON (≤ 8 KiB, validated like a beacon). The peer is re-polled every
10 s and dropped after 3 failures.

### 2.3 Composite

Providers are merged by deviceId; a device is "lost" only when every provider lost it.

## 3. Transport

`HttpServer` on `linkPort` (0 = random) on all IPv4 interfaces:

* `GET /spp/v1/info` - public `DeviceInfo` (rate limited per IP).
* `GET /spp/v1/ws` - WebSocket upgrade (no compression). Max 32 concurrent sockets,
  max 8 simultaneous handshakes, 30 connection attempts / minute / IP.
* Ping/pong keep-alive every 10 s (dart:io `pingInterval`; dead peers are closed).
* Handshake step timeout 10 s.

Note: `dart:io` WebSocket offers no per-message size cap before reassembly. Frames
that exceed our limits are rejected and the connection closed after receipt; an
attacker on the LAN can still make us buffer one oversized message. Run behind
the LAN only (the server is not meant to be port-forwarded).

## 4. Secure channel handshake

Text frames (JSON, ≤ 4 KiB) before the channel is encrypted.

```
Initiator                                   Responder
 Hello_i ────────────────────────────────▶   policy check (unknown device /
                                             rate limit / busy) → error frame
 ◀──────────────────────────────── Hello_r
 Auth_i ─────────────────────────────────▶
 ◀───────────────────────────────── Auth_r
 (both derive keys; all further frames are binary + encrypted)
```

`Hello` = `{"t":"hello","v":1,"deviceId","ed25519Pub","x25519StaticPub",
"ephX25519Pub","nonce"(32 B),"mode":"pair"|"connect"}` (all keys b64 32 B).
Responder's mode must equal the initiator's.

Canonical Hello bytes: `v(1) | mode(1: pair=1, connect=2) | len(deviceId)(1) | deviceId |
ed25519Pub | x25519StaticPub | ephX25519Pub | nonce`.

`transcript = "spp-v1 transcript" | u16(len(H_i)) | H_i | u16(len(H_r)) | H_r`
(initiator first). `th = SHA-256(transcript)`.

`Auth` = `{"t":"auth","sig":b64(64)}` with
`sig = Ed25519(ownEd25519, "spp-v1 auth-i" | th)` (initiator) or `"spp-v1 auth-r" | th`
(responder). Role labels prevent reflection.

Checks (any failure → `{"t":"error","code":…}` text frame, then close):

* version == 1, modes equal, deviceId == hash(ed25519Pub), peer id ≠ own id,
  distinct ephemeral keys, DH results not all-zero.
* **connect** mode: the peer's ed25519Pub must equal the stored trusted key. A
  responder that does not know the peer replies `unknown_device`
  ("Unknown device — pair first"). Unpaired devices can only use **pair** mode.
* **pair** mode: at most 5 attempts / minute / source IP (`rate_limited`), at most 3
  concurrent incoming pairing sessions (`busy`).
* Signature over `th` verifies with the peer's key.

Key schedule:

```
ee  = X25519(ephA, ephB)
ss  = X25519(staticI, staticR)
es  = X25519(ephI, staticR)      (initiator eph × responder static)
se  = X25519(staticI, ephR)      (initiator static × responder eph)
ikm = ee | ss | es | se
keys = HKDF-SHA256(ikm, salt = th, info = "spp-v1 keys", 64 B)
  k_ir = keys[0..32)  initiator → responder
  k_ri = keys[32..64) responder → initiator
SAS  = (u32_be(HKDF-SHA256(ikm, salt = th, info = "spp-v1 sas", 4 B)) mod 10^6),
       zero-padded to 6 digits
```

Record layer (AES-256-GCM), each binary WebSocket frame:

```
counter(8) | ciphertext | tag(16)
nonce = 00 00 00 00 | counter(8)       (per direction, starts at 0)
aad   = 0x01 (initiator→responder) or 0x02 (responder→initiator)
plaintext = type(1) | body
   type 1 = JSON message,  type 2 = file chunk
```

The receiver requires `counter > last accepted` (replays/reordering → connection
closed); the counter only advances after the tag verified. Counter limit 2^48.
Max frame: 64 KiB chunk + headers; JSON ≤ 64 KiB; chat text ≤ 8000 chars; ≤ 2000
JSON messages / s per connection.

### 4.1 Pairing (mode = pair)

Only `peer.info`, `pair.confirm` are processed. Both users see the SAS. When a user
confirms, that device sends `{"t":"pair.confirm","ok":true}`; reject/cancel sends
`ok:false`. Pairing completes only when **both** confirmations are exchanged; then
each side persists `{deviceId, name, ed25519Pub, pairedAt}` in its `TrustStore` and
closes the channel. Timeout: 120 s after the SAS appears. Pair mode is not an
authenticated channel for anything else, and pair-mode sessions are closed after
the outcome.

### 4.2 Connections (mode = connect)

At most one connection per peer. If two exist (both sides dialed), the one whose
initiator has the smaller deviceId wins; the other is closed. Auto-connect
(`keepConnected`) is only initiated by the smaller deviceId, with exponential backoff
(2 s … 30 s). Either side may dial lazily when sending.

Right after the handshake both sides send `peer.info` (their `DeviceInfo`; verified
to match the authenticated key). `pair.revoke` tells the peer we removed our trust;
the receiving side removes its own record too.

## 5. Application messages

JSON object `{"t":<type>,"v":1,…}`. Unknown types and versions > 1 are ignored; malformed
known messages close the connection. A message whose capability is not allowed by the
receiver is dropped (offers are auto-declined with reason `unsupported`).

| type | fields | capability |
|---|---|---|
| `peer.info` | `info` | - |
| `pair.confirm` / `pair.revoke` | `ok`, `reason?` / - | - |
| `status.update` | `status` | - |
| `chat.message` | `id`, `text`, `ts`, `replyTo?` | chat |
| `chat.ack` | `id`, `status: delivered\|read` | chat |
| `chat.typing` | `typing` | chat |
| `file.offer` | `transferId`(32 hex), `name`, `size`, `sha256`(64 hex), `mime` | files |
| `file.accept` | `transferId`, `resumeOffset` | files |
| `file.decline` | `transferId`, `reason` | files |
| `file.chunkAck` | `transferId`, `offset` | files |
| `file.complete` / `file.cancel` | `transferId` | files |
| `file.verified` | `transferId`, `ok` | files |
| `handoff.offer` | `handoffId`, `mode: relay\|refer`, `caller{name,number,uri}`, `accountName`, `referTarget?`, `lanSipUri`, `attended` | handoff |
| `handoff.accept/cancel/complete` | `handoffId` | handoff |
| `handoff.decline` | `handoffId`, `reason` | handoff |
| `calls.query` | - | handoff |
| `calls.list` | `calls[≤64]{callId,remoteName,remoteNumber,durationSec,accountName}` | handoff |
| `call.pull` | `callId` | handoff |
| `intercom.request` | `allowed?` | intercom |

Chat: the receiver answers every new message with `chat.ack delivered` (de-duplicated
by id); the user-facing "read" ack is sent explicitly. Messages to unreachable peers
fail fast (`PeerOfflineException`) unless `queue: true` (outbox ≤ 50 / peer, 10 min).

### 5.1 File transfer

1. Sender hashes the file (SHA-256) and sends `file.offer`.
2. Receiver validates: `name` containing `/`, `\`, NUL or equal to `.`/`..` → declined
   (`invalid_name`); other illegal characters replaced, leading dots/trailing dots
   removed, Windows reserved names prefixed, length ≤ 200. `size > maxFileSize`
   (default 4 GiB) → `too_large`. More than 16 pending offers per peer → `too_many_offers`.
   Otherwise the user accepts/declines (offer expires after 5 min).
3. On accept the receiver opens `downloads/.spp-partial/<peer>_<sha32>_<size>.part`.
   If a partial for the same peer/hash/size exists, `resumeOffset` = its length, else 0.
4. Sender streams chunks (binary type 2): `transferId(16 raw bytes) | offset(8) | data(≤ 65536)`
   with a window of 8 unacknowledged chunks; the receiver requires `offset == bytes
   written` and answers each chunk with `file.chunkAck{offset}` after writing.
5. Sender sends `file.complete`; the receiver hashes the partial file, compares with the
   offered SHA-256, renames into the downloads directory with collision-safe naming
   (`name (1).ext`, exclusive-create) and replies `file.verified{ok}`. A mismatch deletes
   the partial file.
6. `file.cancel` from either side deletes partial data. A dropped connection fails
   the transfer but keeps the partial file (7 days) so a new offer resumes.

### 5.2 Handoff

`offerHandoff` sends `handoff.offer` and waits (default 45 s) for `handoff.accept`/
`handoff.decline`; on timeout it sends `handoff.cancel`. After acceptance the apps drive
the SIP side (relay INVITE with `X-SPP-Handoff` headers, or REFER) and use
`handoff.complete` / `handoff.cancel` as signalling. `calls.query` / `calls.list` /
`call.pull` let a peer ask for a call to be handed to it (the owner then makes a normal
handoff offer).

## 6. Threat model notes

* An active LAN attacker can spoof beacons/`/info` (to misdirect connections or cause
  denial of service) but cannot authenticate as a paired device or read/modify traffic.
* MITM during pairing is detected by the SAS (6 digits; ~1 in 10^6 per attempt, and
  attempts are rate limited and need user interaction on both devices).
* Trust revocation is local; `pair.revoke` is only a courtesy notification and is
  authenticated by the channel.
* Private keys are only as safe as the `KeyStore`; `FileKeyStore` is plaintext JSON
  (mode 600) and meant for tests/desktop fallback. The app should use the OS keystore.
