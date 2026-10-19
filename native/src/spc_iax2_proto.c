/* spc_iax2_proto.c: IAX2 parse/build helpers. Every parser is bounds checked (hostile input). */
#include <string.h>
#include <stdio.h>
#include <pjlib.h>
#include <pjlib-util/md5.h>
#include "spc_iax2_proto.h"

int iax_parse_hdr(const uint8_t* p, size_t len, iax_hdr* h)
{
    memset(h, 0, sizeof(*h));
    if (!p || len < IAX_MINI_HDR) return -1;
    if (p[0] & 0x80) {
        uint8_t cs;
        if (len < IAX_FULL_HDR) return -1;
        h->full = 1;
        h->scall = (uint16_t)(((p[0] & 0x7f) << 8) | p[1]);
        h->retrans = (p[2] & 0x80) != 0;
        h->dcall = (uint16_t)(((p[2] & 0x7f) << 8) | p[3]);
        h->ts = ((uint32_t)p[4] << 24) | ((uint32_t)p[5] << 16) | ((uint32_t)p[6] << 8) | p[7];
        h->oseq = p[8];
        h->iseq = p[9];
        h->type = p[10];
        cs = p[11];
        h->sub_raw = cs;
        h->sub = (cs & 0x80) ? (1u << (cs & 0x1f)) : cs;
        h->payload = p + IAX_FULL_HDR;
        h->plen = len - IAX_FULL_HDR;
        return 0;
    }
    if (p[0] == 0 && p[1] == 0) return -1;      /* meta (trunk) frame: unsupported, dropped */
    h->full = 0;
    h->scall = (uint16_t)(((p[0] & 0x7f) << 8) | p[1]);
    h->ts = ((uint32_t)p[2] << 8) | p[3];
    h->payload = p + IAX_MINI_HDR;
    h->plen = len - IAX_MINI_HDR;
    return 0;
}

static void cpstr(char* dst, size_t n, const uint8_t* s, size_t l)
{
    size_t i, o = 0;
    for (i = 0; i < l && o + 1 < n; i++) {
        unsigned char c = s[i];
        if (c == 0) break;
        dst[o++] = (c < 0x20 || c == 0x7f) ? '?' : (char)c;      /* no control characters leak into logs/JSON */
    }
    dst[o] = 0;
}

int iax_parse_ies(const uint8_t* p, size_t len, iax_ies* o)
{
    size_t off = 0;
    int bad = 0;
    memset(o, 0, sizeof(*o));
    while (off < len) {
        int ie;
        size_t l;
        const uint8_t* d;
        if (len - off < 2) { bad++; break; }
        ie = p[off];
        l = p[off + 1];
        off += 2;
        if (l > len - off) { bad++; break; }
        d = p + off;
        off += l;
        switch (ie) {
        case IAXIE_CALLED_NUMBER: cpstr(o->called_number, sizeof(o->called_number), d, l); break;
        case IAXIE_CALLING_NUMBER: cpstr(o->calling_number, sizeof(o->calling_number), d, l); break;
        case IAXIE_CALLING_NAME: cpstr(o->calling_name, sizeof(o->calling_name), d, l); break;
        case IAXIE_CALLED_CONTEXT: cpstr(o->called_context, sizeof(o->called_context), d, l); break;
        case IAXIE_USERNAME: cpstr(o->username, sizeof(o->username), d, l); break;
        case IAXIE_PASSWORD: cpstr(o->password, sizeof(o->password), d, l); break;
        case IAXIE_DNID: cpstr(o->dnid, sizeof(o->dnid), d, l); break;
        case IAXIE_CHALLENGE: cpstr(o->challenge, sizeof(o->challenge), d, l); o->has |= IAXH_CHALLENGE; break;
        case IAXIE_MD5_RESULT: cpstr(o->md5_result, sizeof(o->md5_result), d, l); o->has |= IAXH_MD5; break;
        case IAXIE_CAUSE: cpstr(o->cause, sizeof(o->cause), d, l); break;
        case IAXIE_CAUSECODE: if (l >= 1) { o->causecode = d[0]; o->has |= IAXH_CAUSECODE; } break;
        case IAXIE_CAPABILITY:
            if (l >= 4 && !(o->has & IAXH_CAP)) { o->capability = ((uint64_t)d[0] << 24) | ((uint64_t)d[1] << 16) | ((uint64_t)d[2] << 8) | d[3]; o->has |= IAXH_CAP; }
            break;
        case IAXIE_FORMAT:
            if (l >= 4 && !(o->has & IAXH_FORMAT)) { o->format = ((uint64_t)d[0] << 24) | ((uint64_t)d[1] << 16) | ((uint64_t)d[2] << 8) | d[3]; o->has |= IAXH_FORMAT; }
            break;
        case IAXIE_CAPABILITY2:        /* version byte + 64 bit */
            if (l >= 9 && d[0] == 0) {
                int i; uint64_t v = 0;
                for (i = 1; i < 9; i++) v = (v << 8) | d[i];
                o->capability = v; o->has |= IAXH_CAP;
            }
            break;
        case IAXIE_FORMAT2:
            if (l >= 9 && d[0] == 0) {
                int i; uint64_t v = 0;
                for (i = 1; i < 9; i++) v = (v << 8) | d[i];
                o->format = v; o->has |= IAXH_FORMAT;
            }
            break;
        case IAXIE_VERSION: if (l >= 2) { o->version = (uint16_t)((d[0] << 8) | d[1]); o->has |= IAXH_VERSION; } break;
        case IAXIE_AUTHMETHODS: if (l >= 2) { o->authmethods = (uint16_t)((d[0] << 8) | d[1]); o->has |= IAXH_AUTHM; } break;
        case IAXIE_REFRESH: if (l >= 2) { o->refresh = (uint16_t)((d[0] << 8) | d[1]); o->has |= IAXH_REFRESH; } break;
        case IAXIE_MSGCOUNT: if (l >= 2) { o->msgcount = (uint16_t)((d[0] << 8) | d[1]); o->has |= IAXH_MSGCOUNT; } break;
        case IAXIE_TRANSFERID: if (l >= 4) { o->transferid = ((uint32_t)d[0] << 24) | ((uint32_t)d[1] << 16) | ((uint32_t)d[2] << 8) | d[3]; o->has |= IAXH_TRANSFER; } break;
        case IAXIE_CALLTOKEN:
            o->calltoken_len = (unsigned)(l > sizeof(o->calltoken) ? sizeof(o->calltoken) : l);
            memcpy(o->calltoken, d, o->calltoken_len);
            o->has |= IAXH_CALLTOKEN;
            break;
        default: break;
        }
    }
    return bad;
}

size_t iax_put_raw(uint8_t* b, size_t off, size_t cap, int ie, const void* d, size_t n)
{
    if (n > 255 || off + 2 + n > cap) return 0;
    b[off] = (uint8_t)ie;
    b[off + 1] = (uint8_t)n;
    if (n) memcpy(b + off + 2, d, n);
    return off + 2 + n;
}
size_t iax_put_str(uint8_t* b, size_t off, size_t cap, int ie, const char* s)
{
    size_t n = s ? strlen(s) : 0;
    if (n > 255) n = 255;
    return iax_put_raw(b, off, cap, ie, s, n);
}
size_t iax_put_u8(uint8_t* b, size_t off, size_t cap, int ie, uint8_t v) { return iax_put_raw(b, off, cap, ie, &v, 1); }
size_t iax_put_u16(uint8_t* b, size_t off, size_t cap, int ie, uint16_t v)
{
    uint8_t t[2]; t[0] = (uint8_t)(v >> 8); t[1] = (uint8_t)v;
    return iax_put_raw(b, off, cap, ie, t, 2);
}
size_t iax_put_u32(uint8_t* b, size_t off, size_t cap, int ie, uint32_t v)
{
    uint8_t t[4]; t[0] = (uint8_t)(v >> 24); t[1] = (uint8_t)(v >> 16); t[2] = (uint8_t)(v >> 8); t[3] = (uint8_t)v;
    return iax_put_raw(b, off, cap, ie, t, 4);
}

void iax_put_full_hdr(uint8_t* b, uint16_t scall, uint16_t dcall, int retrans, uint32_t ts,
                      uint8_t oseq, uint8_t iseq, uint8_t type, uint32_t sub_raw_byte)
{
    b[0] = (uint8_t)(0x80 | ((scall >> 8) & 0x7f));
    b[1] = (uint8_t)scall;
    b[2] = (uint8_t)((retrans ? 0x80 : 0) | ((dcall >> 8) & 0x7f));
    b[3] = (uint8_t)dcall;
    b[4] = (uint8_t)(ts >> 24); b[5] = (uint8_t)(ts >> 16); b[6] = (uint8_t)(ts >> 8); b[7] = (uint8_t)ts;
    b[8] = oseq;
    b[9] = iseq;
    b[10] = type;
    b[11] = (uint8_t)sub_raw_byte;
}

uint8_t iax_fmt_to_sub(uint32_t fmt)
{
    int i;
    if (!fmt || (fmt & (fmt - 1))) return 0;
    for (i = 0; i < 32; i++) if (fmt == (1u << i)) return (uint8_t)(0x80 | i);
    return 0;
}

void iax_md5_hex(const char* a, const char* b, char out[33])
{
    pj_md5_context c;
    pj_uint8_t d[16];
    int i;
    pj_md5_init(&c);
    pj_md5_update(&c, (pj_uint8_t*)a, (unsigned)strlen(a));
    pj_md5_update(&c, (pj_uint8_t*)b, (unsigned)strlen(b));
    pj_md5_final(&c, d);
    for (i = 0; i < 16; i++) snprintf(out + i * 2, 3, "%02x", d[i]);
    out[32] = 0;
}
