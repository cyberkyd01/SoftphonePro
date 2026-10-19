/*
 * SoftphonePro — PJSIP compile-time configuration.
 *
 * Copied to pjlib/include/pj/config_site.h before PJSIP is built and also
 * force-included (-include) when spcore is compiled, so struct layouts that
 * depend on these limits (pjsua_acc_config, pjsua_call_info, ...) always
 * match between PJSIP and spcore.
 */
#ifndef SOFTPHONEPRO_CONFIG_SITE_H
#define SOFTPHONEPRO_CONFIG_SITE_H

#if defined(__APPLE__)
#  include <TargetConditionals.h>
#endif

/* Silence intentional PJ_TODO warnings. */
#define PJ_TODO(id)

/* ---- Capacity: many accounts online at once, many concurrent calls ---- */
#define PJSUA_MAX_ACC                   64
#define PJSUA_MAX_CALLS                 32
#define PJSUA_MAX_BUDDIES               512
#define PJSUA_MAX_PLAYERS               32
#define PJSUA_MAX_RECORDERS             32
#define PJSUA_MAX_CONF_PORTS            254
#define PJSIP_MAX_TSX_COUNT             (16*1024-1)
#define PJSIP_MAX_DIALOG_COUNT          (16*1024-1)
#define PJSUA_ACC_MAX_PROXIES           8

/* Larger packets: TLS, big presence/dialog-info bodies, many codecs in SDP. */
#define PJSIP_MAX_PKT_LEN               8000

/* ---- Security ---- */
#define PJ_HAS_SSL_SOCK                 1
#define PJSIP_HAS_TLS_TRANSPORT         1
#define PJMEDIA_HAS_SRTP                1
#define PJMEDIA_SRTP_HAS_DTLS           1
#define PJMEDIA_SRTP_HAS_AES_GCM_256    1
#define PJMEDIA_SRTP_HAS_AES_GCM_128    1
#define PJMEDIA_SRTP_HAS_AES_CM_256     1

/* ---- Media ---- */
#define PJMEDIA_HAS_VIDEO               0
#define PJMEDIA_RTP_PT_TELEPHONE_EVENTS 101
#define PJSUA_DEFAULT_AUDIO_FRAME_PTIME 20
#define PJMEDIA_CODEC_SPEEX_DEFAULT_QUALITY 8
#define PJSUA_DEFAULT_CODEC_QUALITY     8
/* RTP keep-alive so NAT pinholes survive hold / DTX silence. */
#define PJMEDIA_STREAM_ENABLE_KA        1

/* ---- Misc robustness ---- */
#define PJ_ENABLE_EXTRA_CHECK           1
#define PJSIP_TCP_KEEP_ALIVE_INTERVAL   90
#define PJSIP_TLS_KEEP_ALIVE_INTERVAL   90
#define PJ_DNS_RESOLVER_MAX_NS          16
#define PJSIP_AUTH_AUTO_SEND_NEXT       1
#define PJSIP_REGISTER_CLIENT_ADD_XUID_PARAM 0

/* ---- Audio backends ----
 * pjproject's CMake build passes PJMEDIA_AUDIO_DEV_HAS_* as -D flags; the
 * #ifndef guards below only provide defaults for non-CMake builds
 * (configure-android / Visual Studio .sln). */
#if defined(__ANDROID__)
   /* JNI audio needs pj_jni_jvm from JNI_OnLoad, which dart:ffi never runs. */
#  ifndef PJMEDIA_AUDIO_DEV_HAS_ANDROID_JNI
#    define PJMEDIA_AUDIO_DEV_HAS_ANDROID_JNI 0
#  endif
#endif

#if defined(__APPLE__)
#  ifndef PJMEDIA_AUDIO_DEV_HAS_COREAUDIO
#    define PJMEDIA_AUDIO_DEV_HAS_COREAUDIO 1
#  endif
#  ifndef PJMEDIA_AUDIO_DEV_HAS_PORTAUDIO
#    define PJMEDIA_AUDIO_DEV_HAS_PORTAUDIO 0
#  endif
#endif

#if defined(__APPLE__) && TARGET_OS_IPHONE
   /* iOS: don't use deprecated VoIP background sockets (use CallKit/PushKit). */
#  define PJ_ACTIVESOCK_TCP_IPHONE_OS_BG 0
#  define PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT 1
#endif

#if defined(_WIN32)
   /* Desktop Windows: WMME (pjmedia's WASAPI backend is UWP-only). */
#  ifndef PJMEDIA_AUDIO_DEV_HAS_WMME
#    define PJMEDIA_AUDIO_DEV_HAS_WMME  1
#  endif
   /* select() ioqueue; FD_SETSIZE derives from this. */
#  define PJ_IOQUEUE_MAX_HANDLES        1024
#endif

#endif /* SOFTPHONEPRO_CONFIG_SITE_H */
