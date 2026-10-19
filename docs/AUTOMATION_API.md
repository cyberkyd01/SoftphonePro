# Local automation API

A small HTTP/JSON API built into the desktop app so a CRM, helpdesk or script on the
same computer can place and control calls, watch call events and send SIP messages.
It is the free equivalent of the paid "Desktop API" of other softphones.

* Off by default. Turn it on in **Settings > Advanced > Local automation API**.
* Listens on `127.0.0.1` only (never on a network interface). Default port `7771`.
* Every request needs `Authorization: Bearer <token>`. The 32-byte token is created
  when you enable the API; copy or regenerate it in the same settings group.
* Browsers can call it only from origins you list in **Allowed browser origins**.
  curl and scripts do not need that.
* Requests must be addressed to `127.0.0.1`, `localhost` or `[::1]` (DNS rebinding
  protection), bodies are limited to 64 KiB and at most 16 event streams are open at once.

```sh
export SPT=http://127.0.0.1:7771
export TOKEN=<token from Settings>
alias api='curl -sS -H "Authorization: Bearer $TOKEN"'
```

## Errors

Every error is JSON with the HTTP status that fits:

```json
{ "error": { "code": "account_not_ready", "message": "Account 1016@pbx.test is still registering after 5 s; the call was not placed" } }
```

| Status | Meaning |
|---|---|
| 400 | malformed JSON or invalid field (`invalid_json`, `invalid_to`, `invalid_digits`, ...) |
| 401 | missing or wrong token (`unauthorized`), with `WWW-Authenticate: Bearer` |
| 403 | wrong `Host` (`bad_host`) or an `Origin` that is not allowed (`origin_not_allowed`) |
| 404 | unknown path, call or account (`not_found`, `call_not_found`, `account_not_found`) |
| 405 | wrong HTTP method for the path |
| 409 | the request is valid but not possible now (`invalid_state`, `account_not_ready`, `engine_not_running`, `dial_failed`, `transfer_failed`, `call_ended`) |
| 413 | body larger than 64 KiB |
| 429 | too many open event streams |
| 502 | the far end or engine refused a message (`send_failed`) |

## Endpoints

### GET /v1/status

```sh
api $SPT/v1/status
```

```json
{ "app": "SoftphonePro", "version": "1.0.0",
  "engine": { "state": "running", "version": "...", "demo": false },
  "dnd": false, "calls": 0,
  "accounts": [ { "id": "...", "name": "1016@pbx.test", "regState": "registered", ... } ] }
```

`engine.state` is `idle`, `starting`, `running` or `failed` (with `error`).
`regState` is `registered`, `registering`, `offline`, `failed` or `disabled`.

### GET /v1/accounts

Same account objects as in `/v1/status`: `id`, `name`, `username`, `domain`, `address`,
`enabled`, `default`, `regState`, `regCode`, `error`, `transport`, `dnd`, `mwi`
(`{waiting,new,old}` or null).

### GET /v1/calls and GET /v1/calls/{cid}

Live calls (the second form also returns an ended call that is still known).

```json
{ "cid": 3, "state": "active", "engineState": "confirmed", "direction": "outgoing",
  "number": "600", "display": "", "remoteUri": "sip:600@pbx.test", "dialed": "600",
  "accountId": "...", "held": false, "remoteHeld": false, "muted": false,
  "recording": false, "answered": true, "startedAt": "2026-01-01T10:00:00Z",
  "connectedAt": "2026-01-01T10:00:02Z", "durationMs": 5400, "sipCode": 200, "reason": "OK" }
```

`state`: `ringing_in`, `dialing`, `ringing_out`, `connecting`, `active`, `held`, `ended`.

### POST /v1/calls

```sh
api -d '{"to":"600"}' $SPT/v1/calls
api -d '{"to":"+441234567890","accountId":"1016","waitSeconds":10}' $SPT/v1/calls
```

`to` is dialled through the app's dial rules. `accountId` is an account id, or its
username / `user@domain` when that is unique. If the account is still registering the
request waits up to `waitSeconds` (default 5, 0 to 30) and then answers `409
account_not_ready` naming the account state. Success: `201 {"cid": 3, "call": {...}}`.

### POST /v1/calls/{cid}/{action}

All return `200 {"ok": true, "call": {...}}`. A state that does not allow the action
gives `409 invalid_state`.

| Action | Body | Needs |
|---|---|---|
| `answer` | | ringing incoming call |
| `hangup` | | any live call (declines a ringing one) |
| `hold` / `unhold` | | connected / held call |
| `mute` / `unmute` | | connected call |
| `dtmf` | `{"digits":"1234#"}` (0-9 A-D * #, up to 64) | connected call |
| `transfer` | `{"target":"600"}` blind, or `{"target":"602","attended":true}` | connected call |
| `complete-transfer` | | the consultation call returned by an attended `transfer` |
| `cancel-transfer` | | the consultation call |

An attended transfer answers with `"consultCid"`; talk to the target, then call
`POST /v1/calls/{consultCid}/complete-transfer` (or `cancel-transfer`).

```sh
api -X POST $SPT/v1/calls/3/hold
api -d '{"digits":"1234"}' $SPT/v1/calls/3/dtmf
api -d '{"target":"600"}' $SPT/v1/calls/3/transfer
api -X POST $SPT/v1/calls/3/hangup
```

### GET /v1/dnd, POST /v1/dnd

```sh
api -d '{"enabled":true}' $SPT/v1/dnd
```

Same switch as Settings > Calls > Do not disturb.

### GET /v1/history?limit=50

Newest first, `limit` 1 to 500. Each record: `id`, `direction` (`incoming`/`outgoing`),
`result` (`answered`, `missed`, `rejected`, `failed`, `busy`, `forwarded`, ...),
`number`, `display`, `accountId`, `start`, `durationMs`, `sipCode`, `reason`, `callId`.

### POST /v1/messages

```sh
api -d '{"to":"1015","body":"Your ticket was updated"}' $SPT/v1/messages
```

Sends a SIP MESSAGE through `accountId` (default account when omitted). `201 {"message": {...}}`.

### POST /v1/ui/show

Brings the window to the front, optionally opening a screen. Handy for "screen pop".

```sh
api -d '{"route":"/settings/advanced"}' $SPT/v1/ui/show
```

Allowed routes: `/keypad /recents /contacts /messages /presence /lan /more /settings`
and `/settings/<section>` (for example `/settings/calls`). Anything else is `400 invalid_route`.

### GET /v1/events (Server-Sent Events)

```sh
curl -N -H "Authorization: Bearer $TOKEN" $SPT/v1/events
```

The stream starts with `: connected`, a `hello` event holding the status snapshot, then
events as they happen. A `: ping` comment is sent every 15 seconds. Each event has an
increasing `id`, an `event:` category and JSON `data` with a `type` and `time`:

| event | types | data |
|---|---|---|
| `call` | `incoming`, `outgoing`, `state`, `ended` | `call` object |
| `account` | `registration` | `account` object |
| `mwi` | `changed` | `accountId`, `waiting`, `new`, `old` |
| `message` | `received`, `sent`, `status` | `message` object |
| `history` | `added` | `record` (also written for calls the app rejected, for example under DND) |
| `dnd` | `changed` | `enabled` |

Browsers: `EventSource` cannot send an Authorization header; use `fetch()` and read
`response.body` as a stream from an allowed origin.

## Configuration and provisioning

Settings keys: `automationEnabled` (bool), `automationPort` (default 7771, 0 = any free
port), `automationToken`, `automationOrigins` (list of `https://host[:port]`).
They can be provisioned for tests and deployments only from a local command line:
`softphonepro --provision ./config.json` applies them; provisioning links
(`softphonepro://provision?...`) and the Settings import ignore every `automation*` key,
so a web page cannot switch the API on or choose its token.

```json
{ "accounts": [ { "username": "1016", "password": "...", "domain": "pbx.test" } ],
  "settings": { "automationEnabled": true, "automationPort": 7771,
                "automationToken": "<64 hex characters>" } }
```

If the port is taken the settings group shows the error; choose another port.

## Security notes

* Anything that knows the token can place calls on your accounts: treat it like a password.
  It is stored in the app's settings in your user profile. Regenerate it if it leaks.
* Authentication compares tokens in constant time; unknown paths also require the token.
* Wildcard origins are not supported on purpose.
