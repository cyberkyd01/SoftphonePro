# spcore code review — 2026-10-19

* **Reviewer:** principal-engineer review pass with Fable 5.1, checked against
  the pjproject 2.17 sources.
* **Scope:** native/src at commit 9f14346, before IAX2 and WebSocket were
  added.
* **Status:** every item is tracked to a fix plus a regression test, either
  in native/tests or in CI.

## Critical
| ID | Where | Defect | Fix |
|---|---|---|---|
| C1 | spc_diag.c (diag.resolve SRV) | The SRV query is never cancelled. After the 5 s wait the callback writes to a dead stack frame and the resolver uses a freed pool. | Pass `&q`, call `pj_dns_srv_cancel_query` on timeout before releasing the pool, or use a heap waiter with an abandoned flag. Return TIMEOUT. |
| C2 | spc_call.c `slot_lookup` | A raw `spc_call*` is used after `reg_mtx` is released. The RFC 2833 DTMF callback runs on the media thread without the dialog lock, so a concurrent hangup can free it. | Replace with `slot_snapshot(slot,&cid,&acc)`. Never dereference `spc_call*` outside the registry lock. |
| C3 | spc_callreq.c `do_make` | `pjsua_call_make_call` returns success before CALLING when ICE/TURN init is async (PJ_EPENDING), so `call.make` returns cid 0. | Create the registry entry right after a successful make (race-safe double check), or pre-assign the cid via user_data. Never return `ok` with cid 0. |
| C4 | spc_callreq.c `inband_dtmf` | The tonegen port is used after the lock is released while terminal cleanup destroys it. | Call `pjmedia_port_add_ref` under the lock and `dec_ref` after playing. |

## Major
| ID | Where | Defect | Fix |
|---|---|---|---|
| M1 | spc_diag.c | OPTIONS ping timeout is 10 ms (the parameter is in ms). | Use 5000. |
| M2 | spc_tls.c | iOS, Android and Windows have no default CA paths, so verifyServer fails everything. An empty or invalid pin, or a cert SHA that can't be computed, matches a "" pin. | Android: use /system/etc/security/cacerts. iOS/Windows: require caFile, and fail start if verifyServer is set with no CA. Pins must be 64 hex characters, and an empty SHA never matches. Move the policy to `on_verify_cb`. |
| M3 | spc_trace.c | The trace module stays marked installed after a failed core.start, so the trace is dead afterwards. | Always re-register, or shut down on every failure path. |
| M4 | spc_callreq.c call.sendRequest | INVITE, BYE, ACK, CANCEL, PRACK and UPDATE are allowed, which desynchronises the invite session. | Whitelist INFO, MESSAGE, NOTIFY and OPTIONS. |
| M5 | spc_json.c / account / callreq headers | CRLF header injection is possible, and core header names can be overridden. | Validate names as tokens, reject CR/LF/NUL in values, and deny core headers. |
| M6 | spc_diag.c / spc_core.c DNS | `pj_getaddrinfo` blocks the worker, so the 5 s watchdog restarts the engine. IPv6 nameservers are ignored, and nameservers are not refreshed on IP change. | Resolve on a helper thread, parse IPv6 nameservers, and re-detect DNS in handleIpChange. Check the apply_nameservers return value. |
| M7 | spc_presence.c | Any NOTIFY flips BLF state, with no subscription check, so BLF can be spoofed. | Require `pjsip_ua_find_dialog` to match. Use bounded XML search and accept namespace prefixes. |
| M8 | account / core numeric fields | Negative and out-of-range values are cast to unsigned. | Validate ranges and return INVALID_PARAM. |
| M9 | spc_json.c etc. | A float-to-int cast of 1e300 is UB. | Clamp, and reject non-integral ids. |
| M10 | CMakeLists.txt | iphlpapi and ws2_32 are not linked on Windows (GetNetworkParams), and m is not linked on Linux. | Add the libraries. |
| M11 | spc_callreq.c | `ok:true` with cid 0 is returned after a synchronous failure. | Covered by the C3 fix. |

## Minor
| ID | Defect |
|---|---|
| m1 | `spc_shutdown` or a sync request on the worker thread self-joins or deadlocks. Fail fast with BUSY. |
| m2 | The event ring is not byte-bounded while detached. Don't buffer trace/log events, or cap the ring at 4 MB. |
| m3 | `core.setLogLevel` without `forward` turns forwarding off. Keep the current setting. |
| m4 | A non-graceful stop still waits for unregistration. Use PJSUA_DESTROY_NO_RX_MSG. |
| m5 | pjsua `console_level` writes logs to stdout, which is the CLI protocol channel. Set it to 0. |
| m6 | The reject and redirect waits are 1500 ms, but the contract says 2 s. |
| m7 | Topology re-apply in the media callback calls get_info for other calls under the dialog lock. Defer it via `pjsua_schedule_timer2`. |
| m8 | `mix:both` recording includes a muted mic. |
| m9 | IM and OPTIONS user_data tokens leak on failure or destroy. |
| m10 | `account.remove` emits no final unregistered event. |
| m11 | `transferRequest.referredBy` is always empty. |
| m12 | `isDefault` marks the first device instead of the OS default. |
| m13 | `spc_media_ensure_clock` ignores the selected devices. |
| m14 | Non-boolean flag values are treated as true. Add strict booleans for required flags. |
| m15 | Headers longer than 1023 bytes are dropped in headers_from_rdata. |
| m16 | An unknown method should return UNSUPPORTED. |
| m17 | The TLS "not trusted" attribution is global, not per host. |
| m18 | Tag writes are made without `reg_mtx`. |
| m19 | `ensure_locks` is not thread-safe. Use once-init. |
| m20 | `spc_cond_timedwait` uses CLOCK_REALTIME. Use CLOCK_MONOTONIC. |

## Required regression tests
| # | Test | Covers |
|---|---|---|
| 1 | SRV lookup against a blackholed nameserver, run under ASan for 15 s | C1 |
| 2 | DTMF flood during hangup under ASan, 50 times | C2 |
| 3 | In-band DTMF while the remote hangs up | C4 |
| 4 | ICE `call.make` returns cid > 0 and the call can be hung up | C3 |
| 5 | OPTIONS ping with latency | M1 |
| 6 | Pin validation | M2 |
| 7 | Failed start then a good start, and the trace still works | M3 |
| 8 | `sendRequest` BYE is rejected | M4 |
| 9 | Header injection is rejected | M5 |
| 10 | Spoofed NOTIFY is ignored | M7 |
| 11 | Hostile numbers return INVALID_PARAM with no UBSan reports | M8, M9 |
| 12 | Windows CI build | M10 |
| 13 | Non-graceful stop finishes in under 1 s | m4 |
| 14 | Shutdown from the callback | m1 |
