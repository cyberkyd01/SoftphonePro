/* spc_iax2_proto.h: IAX2 (RFC 5456) wire constants and pure parse/build helpers (no pjsua, no locks). */
#ifndef SPC_IAX2_PROTO_H
#define SPC_IAX2_PROTO_H

#include <stdint.h>
#include <stddef.h>

/* frame types */
#define IAXF_DTMF_END   1
#define IAXF_VOICE      2
#define IAXF_VIDEO      3
#define IAXF_CONTROL    4
#define IAXF_NULL       5
#define IAXF_IAX        6
#define IAXF_TEXT       7
#define IAXF_IMAGE      8
#define IAXF_HTML       9
#define IAXF_CNG        10
#define IAXF_MODEM      11
#define IAXF_DTMF_BEGIN 12

/* IAX command subclasses */
enum {
    IAXC_NEW = 1, IAXC_PING, IAXC_PONG, IAXC_ACK, IAXC_HANGUP, IAXC_REJECT, IAXC_ACCEPT, IAXC_AUTHREQ,
    IAXC_AUTHREP, IAXC_INVAL, IAXC_LAGRQ, IAXC_LAGRP, IAXC_REGREQ, IAXC_REGAUTH, IAXC_REGACK, IAXC_REGREJ,
    IAXC_REGREL, IAXC_VNAK, IAXC_DPREQ, IAXC_DPREP, IAXC_DIAL, IAXC_TXREQ, IAXC_TXCNT, IAXC_TXACC,
    IAXC_TXREADY, IAXC_TXREL, IAXC_TXREJ, IAXC_QUELCH, IAXC_UNQUELCH, IAXC_POKE, IAXC_PAGE, IAXC_MWI,
    IAXC_UNSUPPORT, IAXC_TRANSFER, IAXC_PROVISION, IAXC_FWDOWNL, IAXC_FWDATA, IAXC_TXMEDIA, IAXC_RTKEY,
    IAXC_CALLTOKEN
};

/* control subclasses */
#define IAXCTL_HANGUP     1
#define IAXCTL_RING       2
#define IAXCTL_RINGING    3
#define IAXCTL_ANSWER     4
#define IAXCTL_BUSY       5
#define IAXCTL_CONGESTION 8
#define IAXCTL_PROGRESS   14
#define IAXCTL_PROCEEDING 15
#define IAXCTL_HOLD       16
#define IAXCTL_UNHOLD     17

/* information elements */
enum {
    IAXIE_CALLED_NUMBER = 1, IAXIE_CALLING_NUMBER, IAXIE_CALLING_ANI, IAXIE_CALLING_NAME, IAXIE_CALLED_CONTEXT,
    IAXIE_USERNAME, IAXIE_PASSWORD, IAXIE_CAPABILITY, IAXIE_FORMAT, IAXIE_LANGUAGE, IAXIE_VERSION,
    IAXIE_ADSICPE, IAXIE_DNID, IAXIE_AUTHMETHODS, IAXIE_CHALLENGE, IAXIE_MD5_RESULT, IAXIE_RSA_RESULT,
    IAXIE_APPARENT_ADDR, IAXIE_REFRESH, IAXIE_DPSTATUS, IAXIE_CALLNO, IAXIE_CAUSE, IAXIE_IAX_UNKNOWN,
    IAXIE_MSGCOUNT, IAXIE_AUTOANSWER, IAXIE_MUSICONHOLD, IAXIE_TRANSFERID, IAXIE_RDNIS,
    IAXIE_CALLINGPRES = 38, IAXIE_CALLINGTON, IAXIE_CALLINGTNS, IAXIE_SAMPLINGRATE, IAXIE_CAUSECODE,
    IAXIE_CODEC_PREFS = 45, IAXIE_CALLTOKEN = 54, IAXIE_CAPABILITY2, IAXIE_FORMAT2
};

#define IAX_AUTH_PLAINTEXT 1
#define IAX_AUTH_MD5       2
#define IAX_AUTH_RSA       4

/* format bit masks (wire values) */
#define IAXFMT_GSM   (1u << 1)
#define IAXFMT_ULAW  (1u << 2)
#define IAXFMT_ALAW  (1u << 3)

#define IAX_FULL_HDR 12
#define IAX_MINI_HDR 4
#define IAX_MAX_PKT  2048

/* parsed IEs (strings are always NUL terminated, truncated copies) */
typedef struct {
    char called_number[64], calling_number[64], calling_name[64], called_context[64], username[64], password[64];
    char challenge[80], md5_result[48], cause[128], dnid[64];
    char apparent_addr_dummy;
    uint64_t capability, format;
    uint16_t version, authmethods, refresh, msgcount;
    uint8_t causecode;
    uint32_t transferid;
    uint8_t calltoken[256];
    unsigned calltoken_len;
    unsigned has;                 /* bitmask of IAXH_* */
} iax_ies;
#define IAXH_CAP       0x0001
#define IAXH_FORMAT    0x0002
#define IAXH_VERSION   0x0004
#define IAXH_AUTHM     0x0008
#define IAXH_REFRESH   0x0010
#define IAXH_CAUSECODE 0x0020
#define IAXH_CALLTOKEN 0x0040
#define IAXH_TRANSFER  0x0080
#define IAXH_CHALLENGE 0x0100
#define IAXH_MD5       0x0200
#define IAXH_MSGCOUNT  0x0400

typedef struct {
    int full;                     /* full frame */
    uint16_t scall, dcall;        /* full: both; mini: scall only */
    int retrans;
    uint32_t ts;                  /* full: 32 bit; mini: 16 bit */
    uint8_t oseq, iseq;
    uint8_t type;
    uint32_t sub;                 /* decoded subclass (C bit applied) */
    uint8_t sub_raw;
    const uint8_t* payload;       /* after header */
    size_t plen;
} iax_hdr;

/* returns 0 on success, -1 malformed or unsupported (meta frames) */
int  iax_parse_hdr(const uint8_t* p, size_t len, iax_hdr* h);
/* returns number of malformed bytes skipped (0 = clean); never reads past len */
int  iax_parse_ies(const uint8_t* p, size_t len, iax_ies* out);

/* IE writers: return new offset or 0 on overflow */
size_t iax_put_str(uint8_t* b, size_t off, size_t cap, int ie, const char* s);
size_t iax_put_u8(uint8_t* b, size_t off, size_t cap, int ie, uint8_t v);
size_t iax_put_u16(uint8_t* b, size_t off, size_t cap, int ie, uint16_t v);
size_t iax_put_u32(uint8_t* b, size_t off, size_t cap, int ie, uint32_t v);
size_t iax_put_raw(uint8_t* b, size_t off, size_t cap, int ie, const void* d, size_t n);

/* full frame header writer (12 bytes) */
void iax_put_full_hdr(uint8_t* b, uint16_t scall, uint16_t dcall, int retrans, uint32_t ts,
                      uint8_t oseq, uint8_t iseq, uint8_t type, uint32_t sub_raw_byte);
/* subclass byte for a format bitmask (C bit encoding); 0 if not a single bit */
uint8_t iax_fmt_to_sub(uint32_t fmt);

/* lowercase hex md5(a || b) -> out[33] */
void iax_md5_hex(const char* a, const char* b, char out[33]);
/* constant time compare-free helper not needed (client side) */

#endif
