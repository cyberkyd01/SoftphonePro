/*
 * Smoke test for the native dependency prefix (native/out/<target>).
 * Creates pjsua with a null sound device, starts it, prints the enabled codec
 * list (pjsua_enum_codecs) and the build's feature flags, then shuts down.
 * Exit code 0 = OK. Optional: SMOKE_EXPECT="opus,G722,..." (comma list; each
 * must appear in the codec list or the test fails).
 */
#include <pjsua-lib/pjsua.h>
#include <pjmedia/echo.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHECK(expr) do { pj_status_t _s = (expr); if (_s != PJ_SUCCESS) { \
    char _e[128]; pj_strerror(_s, _e, sizeof(_e)); \
    fprintf(stderr, "FAIL %s:%d %s -> %s\n", __FILE__, __LINE__, #expr, _e); return 1; } } while (0)

int main(void)
{
    pjsua_config cfg;
    pjsua_logging_config log_cfg;
    pjsua_media_config media_cfg;
    pjsua_codec_info codecs[64];
    unsigned i, count = 64;
    char all[4096] = "";

    CHECK(pjsua_create());
    pjsua_config_default(&cfg);
    pjsua_logging_config_default(&log_cfg);
    log_cfg.console_level = 1;
    log_cfg.level = 1;
    pjsua_media_config_default(&media_cfg);
    media_cfg.thread_cnt = 0;           /* no media worker thread needed */
    cfg.thread_cnt = 0;                 /* no pjsip worker threads, no polling needed */
    CHECK(pjsua_init(&cfg, &log_cfg, &media_cfg));
    CHECK(pjsua_set_null_snd_dev());
    CHECK(pjsua_start());

    CHECK(pjsua_enum_codecs(codecs, &count));
    printf("pjproject %s, %u codecs:\n", pj_get_version(), count);
    for (i = 0; i < count; ++i) {
        printf("  %-28.*s prio=%u\n", (int)codecs[i].codec_id.slen,
               codecs[i].codec_id.ptr, (unsigned)codecs[i].priority);
        strncat(all, codecs[i].codec_id.ptr, codecs[i].codec_id.slen < 40 ? codecs[i].codec_id.slen : 40);
        strcat(all, "\n");
    }
    printf("features: tls=%d srtp=%d dtls_srtp=%d video=%d\n",
           PJ_HAS_SSL_SOCK, PJMEDIA_HAS_SRTP, PJMEDIA_SRTP_HAS_DTLS, PJMEDIA_HAS_VIDEO);
    {
        /* Probe which echo canceller implementations were really compiled in. */
        static const struct { const char *name; unsigned opt; } algo[] = {
            { "speex",       PJMEDIA_ECHO_SPEEX },
            { "webrtc",      PJMEDIA_ECHO_WEBRTC },
            { "webrtc_aec3", PJMEDIA_ECHO_WEBRTC_AEC3 },
        };
        pj_pool_t *pool = pjsua_pool_create("smoke", 4000, 4000);
        unsigned k;
        printf("echo cancellers:");
        for (k = 0; k < sizeof(algo)/sizeof(algo[0]); ++k) {
            pjmedia_echo_state *ec = NULL;
            pj_status_t st = pjmedia_echo_create2(pool, 16000, 1, 320, 200, 0, algo[k].opt, &ec);
            printf(" %s=%s", algo[k].name, st == PJ_SUCCESS ? "yes" : "no");
            if (st == PJ_SUCCESS) pjmedia_echo_destroy(ec);
        }
        printf("\n");
        pj_pool_release(pool);
        printf("audio devices: %u\n", (unsigned)pjmedia_aud_dev_count());
    }

    if (getenv("SMOKE_EXPECT")) {
        char *e = strdup(getenv("SMOKE_EXPECT")), *tok, *save = NULL;
        int missing = 0;
        for (tok = strtok_r(e, ",", &save); tok; tok = strtok_r(NULL, ",", &save)) {
            if (!strstr(all, tok)) { fprintf(stderr, "MISSING codec: %s\n", tok); missing++; }
        }
        free(e);
        if (missing) return 2;
    }

    CHECK(pjsua_destroy());
    printf("SMOKE OK\n");
    return 0;
}
