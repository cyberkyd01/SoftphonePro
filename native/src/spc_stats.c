/* spc_stats.c: E-model MOS (ITU-T G.107, simplified). */
#include "spc_internal.h"
#include <math.h>

double spc_emodel_mos(const char* codec, double lossPct, double jitterMs, double rttMs, double jbDelayMs, double ptimeMs)
{
    double ie = 10, bpl = 20, ta, id, ieff, r, mos;
    char name[32];
    size_t i;
    for (i = 0; codec && codec[i] && codec[i] != '/' && i < sizeof(name) - 1; i++) name[i] = codec[i];
    name[i] = 0;
    if (spc_strieq(name, "PCMU") || spc_strieq(name, "PCMA")) { ie = 0; bpl = 25.1; }
    else if (spc_strieq(name, "G722")) { ie = 7; bpl = 22; }
    else if (spc_strieq(name, "GSM")) { ie = 20; bpl = 10; }
    else if (spc_strieq(name, "iLBC")) { ie = 11; bpl = 32; }
    else if (spc_strieq(name, "G729")) { ie = 11; bpl = 19; }
    else if (spc_strieq(name, "opus")) { ie = 2; bpl = 18; }
    else if (spc_strieq(name, "speex")) { ie = 10; bpl = 20; }
    if (lossPct < 0) lossPct = 0;
    if (lossPct > 100) lossPct = 100;
    ta = (rttMs > 0 ? rttMs / 2.0 : 0) + jbDelayMs + 2.0 * jitterMs + ptimeMs + 10.0;
    id = 0.024 * ta + (ta > 177.3 ? 0.11 * (ta - 177.3) : 0);
    ieff = ie + (95.0 - ie) * lossPct / (lossPct + bpl);
    r = 93.2 - id - ieff;
    if (r < 0) r = 0;
    if (r > 100) r = 100;
    mos = 1.0 + 0.035 * r + 7e-6 * r * (r - 60.0) * (100.0 - r);
    if (mos < 1) mos = 1;
    if (mos > 4.5) mos = 4.5;
    return floor(mos * 100.0 + 0.5) / 100.0;
}
