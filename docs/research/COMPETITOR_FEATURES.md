# SoftphonePro - Competitor Feature Research

Date: 2026-10-19. Method: vendor pages fetched this session (cited) plus general SIP-standards knowledge. Anything not confirmed on a fetched page is marked **(unverified)**. Several vendor pages omit pricing/details; those gaps are stated rather than guessed. 3CX's site returned HTTP 403, so 3CX is entirely unverified.

## 1. Per-competitor summaries

### Zoiper 5 (desktop + Android/iOS)
Source: https://www.zoiper.com/en/voip-softphone/download/current
- Pricing (as shown): Free (EUR 0, non-commercial, "basic functionality"); Premium $11.11 (desktop; page does not say whether this equals "Zoiper 5 PRO"); Custom/white-label on demand. Mobile Premium: Android EUR 7.99, iOS $4.99.
- Premium desktop: auto provisioning; contacts integration (Outlook, LDAP, Thunderbird, macOS, Windows); browser integration (click to dial, open URL); G.729 and H.264; transfer and conferencing.
- Mobile Premium: IM, presence, call waiting, transfer, conferencing, RTCP, TLS/SRTP/ZRTP.
- USPs (partly unverified, from general knowledge): IAX2 protocol, Zoiper push proxy service (server-side, paid), very broad codec list, white-label "Custom" build, wizard-based provider setup.

### Bria Solo / Teams / Enterprise (CounterPath, now Alianza)
Sources: https://www.counterpath.com/bria-solo/ , https://www.counterpath.com/bria-enterprise/
- Solo: individuals; up to 5 VoIP accounts on paid plan; cloud management portal; contacts from Google, Outlook, iOS, Android; Bria Desktop API (paid). Price not listed on page; free trial.
- Teams: SMB (<100 users per Enterprise page); features not listed on fetched page.
- Enterprise: UC with real-time presence, workplace messaging, Stretto cloud provisioning (deploy/configure/update), call analytics, security and MDM.
- Not confirmed on fetched pages: BLF, CRM, recording, codec list (all unverified; generally known: BLF, call recording, video, SRTP/TLS, Stretto, MDM/AppConfig).
- USPs: centralized provisioning (Stretto), desktop API, call analytics, enterprise MDM, polished UX.

### Groundwire / Acrobits Softphone
Source: https://www.acrobits.net/groundwire/
- One-time purchase, lifetime updates (price not on page). iOS + Android.
- Transfer, conferencing, voicemail, recording, advanced per-account SIP options, multiple accounts, 80+ providers listed.
- Shares SIP core with Acrobits "SIPIS" cloud registration to reduce battery drain (push-like, server side).
- TLS + SRTP, optional ZRTP; wideband codecs; Wi-Fi to cellular handover.
- USPs: per-account control depth, push via Acrobits cloud (server dependent), one-time price. Acrobits Softphone (the lighter app) lacks transfer/conference per the page.

### MicroSIP (Windows)
Source: https://www.microsip.org/
- Free, open source, PJSIP-based. 12 MB footprint, portable INI config.
- H.264/H.263+/VP8/VP9; DTMF in-band/RFC2833/SIP INFO; SIMPLE messaging (RFC 3428); presence; TLS, SRTP, DTLS-SRTP.
- Codecs: Opus, G.711, G.722, G.722.1, G.723, G.729, GSM, AMR, AMR-WB, iLBC, Speex, SILK, PCM.
- WebRTC echo cancellation and VAD; NVDA screen reader compatible; RTL languages.
- Windows only (Wine elsewhere). USP: tiny, free, full codec set, portable.

### Linphone (Belledonne)
Source: https://www.linphone.org/en/features/
- Open source (GPL, with commercial licence), all platforms.
- Opus; AV1/H.265/H.264; echo cancellation, FEC; up to 1080p; network handoff; quality stats; G.729.
- Group video up to 50 via SFU (server); simple audio conference by merging; blind/attended transfer; recording with playback; multiple calls, hold, MOH; auto-answer; MWI; Bluetooth.
- IM: 1:1 and group, files, voice messages, reactions, receipts, ephemeral; E2E (Double Ratchet), post-quantum Kyber.
- Security: TLS, SRTP, DTLS, ZRTP with SAS; OIDC/OAuth SSO; mandatory encryption by remote config.
- Push (Firebase/APNs, Linphone accounts), CarPlay/Android Auto; remote config via QR/link; CardDAV + LDAP; themes.
- USP: most complete open-source feature set; E2E IM; QR provisioning.

### Others
- Sipnetic (Android) https://www.sipnetic.com/ : free, no tracking; Opus/G.722/G.711/G.729/Speex/GSM; H.264/VP8; STUN/TURN/ICE; OTRv3 E2E IM; TLS/SRTP/ZRTP; SIMPLE presence; QR account setup; auto account selection; number rewriting; MWI; attended transfer; walkie-talkie mode; 8 themes.
- PortSIP softphone (legacy) https://www.portsip.com/portsip-softphone/ : free; AMR-WB, G.722.1, Opus; H.264/VP8 up to 4K; presence/IM; push; white-label rebranding; pairs with PortSIP PBX.
- 3CX app: **(unverified, site blocked)**. Known generally: tied to 3CX PBX, provisioning by QR/welcome email, BLF/presence, CRM integrations, push via 3CX, video conference.
- Telephone (macOS, open source, Apple-silicon native): **(unverified)** simple, free, system-contacts integration, multi-account, no frills; not heavily maintained.
- Onesip: **(unverified)** hosted VoIP provider with web/mobile softphone; not researched.
- Zoiper/Bria CRM: Zoiper Premium lists Outlook/LDAP contacts and browser click-to-dial. Bria: contact sources and API; named CRM integrations not confirmed.

## 2. Feature matrix
Legend: Y = yes, N = no, P = partial/depends, ? = unverified. Zoiper = Premium, Bria = Solo/Teams/Enterprise.

| Category / Feature | Zoiper Premium | Bria | Groundwire | MicroSIP | Linphone |
|---|---|---|---|---|---|
| **Accounts & Registration** | | | | | |
| Multiple accounts | Y | P (5 on Solo) | Y | Y | Y |
| Per-account settings depth | Y | Y | Y | Y | P |
| IAX2 | Y | N | N | N | N |
| Digest + TLS client cert auth | ? | ? | ? | P | Y |
| SSO (OIDC/OAuth) | N | ? | N | N | Y |
| **Transports & Network** | | | | | |
| UDP/TCP/TLS | Y | Y | Y | Y | Y |
| STUN/ICE/TURN | Y | Y | Y | Y | Y |
| IPv6 | ? | ? | ? | P | Y |
| Wi-Fi/cell handover | Y? | Y? | Y | N/A | Y |
| Push (needs server) | Y (Zoiper proxy) | Y (CounterPath/Stretto) | Y (Acrobits cloud) | N/A | Y (Linphone accts) |
| **Security** | | | | | |
| SRTP (SDES) | Y | Y | Y | Y | Y |
| DTLS-SRTP | ? | ? | ? | Y | Y |
| ZRTP | Y (mobile Premium) | ? | Y (optional) | N? | Y |
| E2E encrypted IM | N | ? | N | N | Y |
| **Codecs & Media** | | | | | |
| Opus / G.722 / G.711 | Y | Y | Y | Y | Y |
| G.729 | Y | Y? | ? | Y | Y |
| GSM/iLBC/Speex | Y | P? | P? | Y | Y |
| AMR/AMR-WB | ? | ? | ? | Y | P |
| H.264 | Y | Y | ? | Y | Y |
| VP8/VP9 | ? | ? | ? | Y | P (VP8) |
| H.265/AV1 | N | N | N | N | Y |
| AEC / noise suppression | Y | Y | Y | Y (WebRTC AEC) | Y |
| **Call Handling** | | | | | |
| Hold / call waiting | Y | Y | Y | Y | Y |
| Blind / attended transfer | Y | Y | Y | Y | Y |
| DTMF RFC2833/INFO/in-band | Y | Y | Y | Y | Y |
| Call recording | ? | Y? | Y | Y? | Y |
| Auto-answer / intercom | Y? | Y? | ? | Y | Y |
| Call forwarding / DND | Y | Y | Y | Y | P |
| Call park / pickup | ? | ? | ? | N | N |
| **Conferencing** | | | | | |
| Local 3-way | Y | Y | Y | Y | Y |
| N-way local mix | Y? | Y? | Y? | P | Y |
| Server video conference | N | Y (enterprise) | N | N | Y (SFU, 50) |
| **Messaging & Presence** | | | | | |
| SIP MESSAGE IM | Y (mobile) | Y | ? | Y | Y |
| Presence (SIMPLE) | Y | Y | ? | Y | P |
| BLF (RFC 4235) | ? | Y? | ? | P (BLF-like presence) | N |
| MWI | Y | Y | Y | Y | Y |
| Group chat / files | N | Y (Enterprise) | N | N | Y |
| **Contacts & History** | | | | | |
| System contacts | Y | Y | Y | N (local) | Y |
| LDAP / Outlook | Y | Y | N? | N | Y (LDAP, CardDAV) |
| Call history | Y | Y | Y | Y | Y |
| **UI/UX** | | | | | |
| Video | Y | Y | Y? | Y | Y |
| Themes | P | P | P | N | Y |
| Speed dial | Y | Y | Y? | Y | N |
| **Platform Integration** | | | | | |
| Platforms | Win/mac/Linux/iOS/Android | Win/mac/iOS/Android | iOS/Android | Windows | All incl. Linux |
| CallKit / ConnectionService | Y? | Y? | Y | N/A | Y |
| URL handlers sip:/tel: | Y | Y | Y | Y | Y |
| Browser click-to-call | Y | ? | N | N | N |
| CarPlay / Android Auto | ? | ? | ? | N | Y |
| Headset HID | Y? | Y | N/A | P | P |
| **Provisioning & Admin** | | | | | |
| Auto-provisioning | Y | Y (Stretto) | Y? | P (INI) | Y |
| QR provisioning | ? | ? | Y? | N | Y |
| MDM / managed config | ? | Y | ? | N | P |
| White-label | Y (Custom) | Y? | Y? | N | P |
| **Diagnostics** | | | | | |
| Call stats (MOS/jitter/loss) | Y? | Y | P | P | Y |
| SIP log viewer | P | P | P | P (log file) | P |
| **Accessibility/Localization** | | | | | |
| Screen reader | ? | ? | iOS VoiceOver ? | Y (NVDA) | ? |
| RTL | ? | ? | ? | Y | ? |
| Languages | many | many | many | many | many |

Matrix cells with "?" or "Y?" come from general knowledge, not fetched pages; verify before external claims.

## 3. Prioritized requirements for SoftphonePro

### P0 - core parity
- Unlimited SIP accounts; UDP/TCP/TLS; rport; STUN/ICE/TURN; session timers; 100rel; outbound proxy; keep-alive.
- SRTP (SDES) and DTLS-SRTP; TLS with cert validation; ZRTP (PJSIP lacks native ZRTP; needs a ZRTP lib such as libzrtpcpp/bzrtp integration).
- Codecs: Opus, G.722, G.711, GSM, iLBC, Speex; AEC, noise suppression, AGC, jitter buffer. G.729 and AMR(-WB): licensing/patent check (G.729 patents expired; AMR may need a codec library licence).
- DTMF RFC 2833/4733, SIP INFO, in-band.
- Hold, call waiting, blind and attended transfer (REFER/Replaces), DND, forwarding, 3-way conference, call history, MWI, SIP MESSAGE IM, presence (SIMPLE), BLF (dialog event).
- Auto-answer/intercom (Call-Info / Alert-Info answer-after), speed dial, dial rules, URL handlers (sip:, tel:, callto:), system contacts, headset buttons, CallKit (iOS) and ConnectionService (Android).
- Provisioning from URL (HTTP(S) config, variables).

### P1 - premium parity
- Video H.264/VP8, N-way local conference, call recording (local, with consent beep option), call park/pickup (feature codes + BLF), QR/link provisioning, LDAP/CardDAV/Outlook contacts, browser extension for click-to-call, call stats (MOS/jitter/loss), SIP log export, AMR/AMR-WB, G.729, Bluetooth/HID, themes, localization incl. RTL, screen-reader support, IAX2 (optional; low priority, needs separate stack), CarPlay/Android Auto.

### P2 - differentiators (client-only unless flagged)
| Idea | Server needed? |
|---|---|
| Live call quality dashboard (MOS, jitter, loss, RTT graphs, per-call history) | No |
| Built-in SIP trace/ladder-diagram viewer with export and redaction | No |
| Network diagnostics wizard (NAT type, STUN/TURN reachability, port/TLS test, SIP ALG detection) | No (public STUN) |
| Smart dial rules (regex rewrite, per-account routing, least-cost account select, E.164 normalization) | No |
| Per-account / per-contact ringtones, themes, caller-ID overrides | No |
| Encrypted local history and recordings (SQLCipher/OS keystore) | No |
| Local call transcription and voicemail transcription (on-device Whisper-class model) | No (model download) |
| Local noise suppression (RNNoise) and optional voice effects | No |
| Local AI call summary / search (on-device) | No |
| Config profile import/export, signed provisioning, diff view | No |
| Scripting/automation hooks (webhooks, local REST/CLI, call events) | No |
| Open desktop API and plugin system (competitor Bria's API is paid) | No |
| Per-call codec/SRTP security indicator and ZRTP SAS UI | No |
| Auto account failover and registration health monitoring | No |
| Privacy mode: no telemetry, ad-free, reproducible builds | No |
| Accessibility-first UI (full screen reader, high contrast, keyboard shortcuts) | No |
| Push notifications for incoming calls on iOS/Android | **Yes**: needs a push gateway (APNs/FCM) and PBX/proxy cooperation. Mitigate: ship self-hostable open-source push gateway, document Asterisk/Kamailio/FreeSWITCH setup; background-socket fallback on Android. |
| Cloud registration to save battery (Acrobits SIPIS style) | **Yes** |
| Group video conference (SFU) | **Yes** (e.g., Jitsi/LiveKit integration) |
| E2E encrypted group chat | **Yes** (or peer-only OTR/OMEMO style) |
| Voicemail transcription from PBX | Partial: client downloads audio, transcribes locally |
| Account sync across devices | **Yes** (or file/QR export only) |

### Limitations to document
- iOS background incoming calls require push (PushKit + CallKit) and a server component; without it, calls arrive only while the app is foreground or kept alive.
- BLF, park, pickup, forwarding, DND sync depend on PBX support.
- Codec licensing (G.729 historically, AMR, H.264) and App Store/Play policies need review.

## 4. Sources
- https://www.zoiper.com/en/voip-softphone/download/current
- https://www.counterpath.com/bria-solo/
- https://www.counterpath.com/bria-enterprise/
- https://www.acrobits.net/groundwire/
- https://www.microsip.org/
- https://www.linphone.org/en/features/
- https://www.sipnetic.com/
- https://www.portsip.com/portsip-softphone/
