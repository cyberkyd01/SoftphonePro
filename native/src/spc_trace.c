/* spc_trace.c: pjsip module that captures raw SIP rx/tx as sip.trace events. */
#include "spc_internal.h"

static int g_trace_on;
static int g_installed;

static const char* tp_name(const pjsip_transport* t)
{
    if (!t) return "UDP";
    switch (t->key.type & ~PJSIP_TRANSPORT_IPV6) {
    case PJSIP_TRANSPORT_TCP: return "TCP";
    case PJSIP_TRANSPORT_TLS: return "TLS";
    default:
        if (t->type_name && spc_strieq(t->type_name, "WSS")) return "WSS";
        if (t->type_name && spc_strieq(t->type_name, "WS")) return "WS";
        return "UDP";
    }
}

static void emit_trace(const char* dir, const pjsip_transport* t, const char* local, const char* remote, const char* data, int len)
{
    cJSON* f;
    char* tmp;
    if (len <= 0 || !data) return;
    tmp = (char*)malloc((size_t)len + 1);
    if (!tmp) return;
    memcpy(tmp, data, (size_t)len);
    tmp[len] = 0;
    f = cJSON_CreateObject();
    cJSON_AddStringToObject(f, "dir", dir);
    cJSON_AddStringToObject(f, "transport", tp_name(t));
    cJSON_AddStringToObject(f, "local", local);
    cJSON_AddStringToObject(f, "remote", remote);
    cJSON_AddNumberToObject(f, "len", len);
    cJSON_AddStringToObject(f, "msg", tmp);
    free(tmp);
    spc_emit("sip.trace", f);
}

static pj_bool_t on_rx(pjsip_rx_data* rd)
{
    char local[80], remote[80];
    if (!g_trace_on) return PJ_FALSE;
    snprintf(local, sizeof(local), "%.*s:%d", (int)rd->tp_info.transport->local_name.host.slen,
             rd->tp_info.transport->local_name.host.ptr, rd->tp_info.transport->local_name.port);
    snprintf(remote, sizeof(remote), "%s:%d", rd->pkt_info.src_name, rd->pkt_info.src_port);
    emit_trace("rx", rd->tp_info.transport, local, remote, rd->pkt_info.packet, (int)rd->pkt_info.len);
    return PJ_FALSE;
}

static pj_status_t on_tx(pjsip_tx_data* td)
{
    char local[80], remote[80];
    if (!g_trace_on) return PJ_SUCCESS;
    if (td->tp_info.transport) {
        snprintf(local, sizeof(local), "%.*s:%d", (int)td->tp_info.transport->local_name.host.slen,
                 td->tp_info.transport->local_name.host.ptr, td->tp_info.transport->local_name.port);
    } else local[0] = 0;
    snprintf(remote, sizeof(remote), "%s", td->tp_info.dst_name);
    {
        char tmp[40];
        snprintf(tmp, sizeof(tmp), ":%d", td->tp_info.dst_port);
        strncat(remote, tmp, sizeof(remote) - strlen(remote) - 1);
    }
    emit_trace("tx", td->tp_info.transport, local, remote, td->buf.start, (int)(td->buf.cur - td->buf.start));
    return PJ_SUCCESS;
}

static pjsip_module g_mod = {
    NULL, NULL,
    { "mod-spc-trace", 13 },
    -1,
    PJSIP_MOD_PRIORITY_TRANSPORT_LAYER - 1,
    NULL, NULL, NULL, NULL,
    &on_rx, &on_rx,
    &on_tx, &on_tx, NULL
};

int spc_trace_init(void)
{
    pj_status_t st;
    g_mod.prev = g_mod.next = NULL;
    g_mod.id = -1;
    st = pjsip_endpt_register_module(pjsua_get_pjsip_endpt(), &g_mod);
    if (st == PJ_SUCCESS) g_installed = 1;
    return st == PJ_SUCCESS ? 0 : -1;
}
void spc_trace_set(int en) { g_trace_on = en ? 1 : 0; }
void spc_trace_shutdown(void) { g_trace_on = 0; g_installed = 0; }
