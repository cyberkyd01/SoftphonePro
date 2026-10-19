/* spc_lan.c: LAN UDP transport + local account, incoming account routing. */
#include "spc_internal.h"

int spc_lan_start(int port, cJSON* res)
{
    pjsua_transport_config tc;
    pjsua_transport_id id = -1;
    pjsua_transport_info ti;
    int acc = -1;
    if (port < 0 || port > 65535) return -1;
    pjsua_transport_config_default(&tc);
    tc.port = (unsigned)port;
    if (G.qos) tc.qos_type = PJ_QOS_TYPE_CONTROL;
    if (pjsua_transport_create(PJSIP_TRANSPORT_UDP, &tc, &id) != PJ_SUCCESS) {
        tc.port = 0;
        if (pjsua_transport_create(PJSIP_TRANSPORT_UDP, &tc, &id) != PJ_SUCCESS) return -1;
    }
    if (spc_lan_register_account(id, &acc) != 0) { pjsua_transport_close(id, PJ_FALSE); return -1; }
    G.lan_tp = id;
    G.lan_acc = acc;
    pjsua_transport_get_info(id, &ti);
    cJSON_AddNumberToObject(res, "acc", acc);
    cJSON_AddNumberToObject(res, "port", ti.local_name.port);
    cJSON_AddStringToObject(res, "transport", "udp");
    return 0;
}

void spc_lan_stop(void)
{
    G.lan_tp = -1;
    G.lan_acc = -1;
}

void spc_lan_on_find(const pjsip_rx_data* rdata, pjsua_acc_id* acc_id)
{
    if (!rdata || !acc_id) return;
    if (G.lan_tp >= 0 && G.lan_acc >= 0 && rdata->tp_info.transport) {
        pjsua_transport_info ti;
        if (pjsua_transport_get_info(G.lan_tp, &ti) == PJ_SUCCESS &&
            rdata->tp_info.transport->local_name.port == ti.local_name.port &&
            (rdata->tp_info.transport->key.type & ~PJSIP_TRANSPORT_IPV6) == PJSIP_TRANSPORT_UDP) {
            *acc_id = G.lan_acc;
            return;
        }
    }
    if (G.direct_acc >= 0 && rdata->msg_info.msg && rdata->msg_info.msg->type == PJSIP_REQUEST_MSG) {
        const pjsip_uri* u = rdata->msg_info.msg->line.req.uri;
        if (u && (PJSIP_URI_SCHEME_IS_SIP(u) || PJSIP_URI_SCHEME_IS_SIPS(u))) {
            const pjsip_sip_uri* su = (const pjsip_sip_uri*)pjsip_uri_get_uri((void*)u);
            if (su->user.slen == 0) *acc_id = G.direct_acc;
        }
    }
}
