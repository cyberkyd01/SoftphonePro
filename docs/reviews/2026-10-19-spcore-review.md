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


## Status (2026-10-19, spcore author)

| ID | Status |
|---|---|
| C1 | **Fixed.** `diag.resolve` is now an asynchronous, ref-counted heap job (`spc_defer_response`): the SRV query handle is kept and cancelled by the timeout timer before its pool is released, the address lookup runs on a detached helper thread, and an unfinished lookup answers `TIMEOUT` after 5 s. Tests: `TestC1ResolveTimeout`. |
| C2 | **Fixed.** `slot_lookup` replaced by `slot_snapshot` (copies cid/acc under `reg_mtx`); every callback (media state, DTMF, transfer, replaced, redirected) works with the cid and re-finds the call under the lock. Tests: `TestC2C4Dtmf` (50 x DTMF flood during hangup). |
| C3 | **Fixed.** `call.make` calls `spc_call_ensure_slot()` which creates the registry entry itself (race-safe) and never returns `ok` with cid 0 (error `PJ_ERROR` if the call is already gone). Tests: `TestC3IceMake`. |
| C4 | **Fixed.** `pjmedia_port_add_ref` is not usable here (the tonegen has no group lock), so playing and destroying the tone port are serialised with `G.tg_mtx`; cleanup clears `c->tg_port` under `reg_mtx` first. Tests: `TestC2C4Dtmf.test_inband_dtmf_while_remote_hangs_up`. |
| M1 | **Fixed, differently from the review.** In pjsip 2.17 `pjsip_endpt_send_request()` ignores its `timeout` argument entirely (`PJ_UNUSED_ARG`), so the ping took 32 s rather than 10 ms. The ping now carries its own 5 s timer that reports `408`. Tests: `TestM1OptionsPing`. |
| M2 | **Fixed, policy kept in the state callback.** Pins must be exactly 64 hex digits (`INVALID_PARAM`), an empty/uncomputable SHA never matches, a missing certificate is rejected when verification is on, Android uses `/system/etc/security/cacerts`, and `core.start` fails with `INVALID_PARAM` when `verifyServer` is on and no readable CA exists (iOS/Windows need `caFile`). Not moved into `on_verify_cb`: the hostname/identity check needs the transport's remote name, which the verify callback does not receive. The verdict is still applied before any SIP byte is sent (pjsip/WS queue pending requests until the state callback returns and drop them on shutdown). Same code path serves WSS. Tests: `TestM2TlsPolicy`, `test_tls_verification_and_pins`. |
| M3 | **Fixed.** The trace module is re-registered on every start (the `g_installed` guard is gone). Tests: `TestM3TraceAfterFailedStart`. |
| M4 | **Fixed.** `call.sendRequest` allows INFO, MESSAGE, NOTIFY, OPTIONS only. Tests: `TestM4M5Requests`. |
| M5 | **Fixed.** Header names must be tokens and not core headers, values may not contain CR/LF/NUL (`spc_validate_headers`), applied to call.make/answer/reject/pickup/sendRequest and account headers; `userAgent`, `displayName`, `username`, `domain`, `registrar`, `authUser`, `callerId` reject control characters. IAX2/WS take no headers. Tests: `TestM4M5Requests`. |
| M6 | **Fixed.** `diag.resolve` no longer blocks; IPv6 nameservers are detected (`res_getservers` / glibc `_ext.nsaddrs`); `core.handleIpChange` re-detects (or re-applies explicit) nameservers; explicit nameservers are validated and an `apply` failure fails `core.start`. IAX2 DNS (`resolve_host`) is bounded to 3 s on a helper thread (`spc_resolve_ipv4`). Tests: `TestM6Dns`. |
| M7 | **Fixed.** The dialog-info sniffer requires `pjsip_ua_find_dialog()` to match the NOTIFY's Call-ID/tags, the XML scan is bounded to the body and accepts namespace prefixes. Tests: `TestM7SpoofedDialogInfo` (raw UDP spoof). |
| M8 | **Fixed.** Range checks via `spc_jint_range` for all listed fields (SIP and IAX2 accounts, `core.start`). Tests: `TestM8M9Numbers`. |
| M9 | **Fixed.** `spc_ju64`/`spc_jnum_to_id` accept only integers in 1..2^53; `acc` and `cids[]` and fmtp casts are range-checked. Tests: `TestM8M9Numbers` (zero UBSan reports under the ASan/UBSan run). |
| M10 | **Fixed.** `iphlpapi ws2_32` were already added on main (verified); `m` is now linked on Linux. Windows CI build is the CI job. |
| M11 | **Fixed** with C3. |
| m1 | **Fixed.** Thread-local worker / in-callback flags: `spc_request_sync` answers `BUSY`, `spc_shutdown` returns. Tests: `TestMinor.test_shutdown_and_sync_request_from_event_callback` (`__shutdown_from_cb` in the CLI). |
| m2 | **Fixed.** `log` and `sip.trace` are not buffered (and burn no seq) while detached; the ring is also capped at 4 MB. |
| m3 | **Fixed.** `forward` is optional in `core.setLogLevel`; also `pjsua_reconfigure_logging` so the level really changes. |
| m4 | **Fixed.** `core.stop {graceful:false}` uses `PJSUA_DESTROY_NO_RX_MSG` and a 500 ms call wait. Test: `TestM4Stop` (5 accounts < 1 s). |
| m5 | **Won't fix (not applicable).** pjsua only calls `logging_config.cb` when `level <= console_level`; with the callback installed nothing is written to stdout at all, whereas `console_level = 0` would silence the forwarded `log` events. The early (pre-init) pjlib output is dropped by `pj_log_early`. |
| m6 | **Fixed.** reject / redirect / hangup wait up to 2000 ms. |
| m7 | **Fixed.** The media-state callback only reads its own call; the full topology re-apply is deferred with `pjsua_schedule_timer2(0)`. |
| m8 | **Fixed.** The local mic is not connected to the recorder while muted or detached. |
| m9 | **Fixed.** IM / OPTIONS tokens are tracked (`spc_token_new/free`) and freed on failure and at `core.stop`. |
| m10 | **Fixed.** Test: `TestMinor.test_remove_account_emits_final_unregistered`. |
| m11 | **Fixed (kept, not dropped).** Referred-By is captured from the REFER in `on_call_tsx_state`, which fires before `on_call_transfer_request2`. |
| m12 | **Fixed.** `isDefault` uses `pjmedia_aud_dev_default_param` (falls back to the first capable device). |
| m13 | **Fixed.** `spc_media_ensure_clock` opens the devices selected with `media.setDevices`. |
| m14 | **Fixed.** `mute`, `detached`, `register`, `enabled` (loopback, sipTrace), `typing`, `bridge` must be booleans. |
| m15 | **Fixed.** 4 KB header buffer. |
| m16 | **Fixed.** Unknown method gives `UNSUPPORTED`. |
| m17 | **Partially fixed.** Failures are recorded per remote host; an account with an IP-literal domain is matched exactly, a name falls back to 'any TLS failure in the last 8 s' because the transport only knows the resolved address. |
| m18 | **Fixed.** Tag writes happen under `reg_mtx`. |
| m19 | **Fixed.** Lock initialisation uses `spc_once`. |
| m20 | **Fixed.** Monotonic condvar clock on Linux/Android (`pthread_condattr_setclock`) and `pthread_cond_timedwait_relative_np` on Apple. |

### Additional finding: `test_iax2.TestIaxWire.test_incoming_call_and_voice_with_ts_wrap`

Not an IAX2 playout bug. The test pushed 160 mini frames (3.2 s) and only then read `call.stats.rxLevel`. `rxLevel`
is the instantaneous level of the bridge port and is 0 once the jitter buffer has drained after the burst. The failing
stats (`rx.packets 160`, `jb.discard 0`, `jb.size 0`, `jb.empty 654`) prove that every frame crossed the 16-bit
timestamp wrap and was played out. Reproduced with the old test (2 of 4 runs fail on an unloaded machine); the test now
samples `rxLevel` while the burst is running and passes 3/3.
