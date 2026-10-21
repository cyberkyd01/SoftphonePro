/* spc_player.h: media file player (WAV/MP3 -> conference-bridge port), music on hold, resampler. */
#ifndef SPC_PLAYER_H
#define SPC_PLAYER_H

#include <stdint.h>
#include <stddef.h>

#define SPC_PLAY_MAX_MS      (30 * 60 * 1000)          /* longest decodable file */
#define SPC_PLAY_MAX_MP3_BYTES (64u * 1024u * 1024u)   /* MP3 input file size cap (held in memory; duration is estimated from headers) */
#define SPC_PLAY_MAX_BYTES   (200u * 1024u * 1024u)    /* decoded PCM16 at the bridge rate / input file size cap */

typedef struct {
    char format[8];           /* "wav" | "mp3" */
    int  durationMs, sampleRate, channels;
} spc_fileinfo;

/* Header-only probe (WAV) or frame scan (MP3). 0 ok, else -1 with a reason in err. Never touches pjsua. */
int  spc_media_file_info(const char* path, spc_fileinfo* fi, char* err, size_t en);

/* ---- streaming windowed-sinc resampler (mono PCM16) ---- */
typedef struct spc_rs spc_rs;
typedef void (*spc_rs_sink)(void* ctx, const int16_t* pcm, size_t n);
spc_rs* spc_rs_new(int in_rate, int out_rate);
void    spc_rs_push(spc_rs* r, const int16_t* in, size_t n, spc_rs_sink sink, void* ctx);
void    spc_rs_flush(spc_rs* r, spc_rs_sink sink, void* ctx);
void    spc_rs_free(spc_rs* r);

/* ---- players ---- */
/* Owner id of plays that belong to no call (media.playLocal): local-only, to the speaker */
#define SPC_LOCAL_CID ((uint64_t)-1)
/* Starts a player on call `cid`. 0 ok (play id in *id) or -1 with err filled. */
int  spc_player_start(uint64_t cid, const char* file, int loop, float volume, int local_monitor, int mute_mic,
                      int moh, int* id, char* err, size_t en);
/* Stops plays of a call. id 0 = every non-MOH play. Emits call.playDone(reason). Returns the number stopped. */
int  spc_player_stop(uint64_t cid, int id, const char* reason);
/* Stops everything (incl. MOH and any pending MOH) of a call. Used at hangup. */
void spc_player_stop_call(uint64_t cid, const char* reason);
/* Topology hook: (re)connects the call's players. */
/* active: media active; lhold: locally held but the conf slot is valid (music on hold connects then). */
void spc_player_apply_call(uint64_t cid, int cslot, int active, int lhold, int held);
/* Number of active plays that asked to mute the microphone towards the call (announcement mute). */
int  spc_player_ann_mute(uint64_t cid);
void spc_player_shutdown(void);

/* Music on hold (client side) */
int  spc_moh_arm(uint64_t cid, const char* file, int loop, float volume);   /* validates nothing; call after spc_media_file_info */
void spc_moh_disarm(uint64_t cid);                                         /* disarm + stop a running MOH */
void spc_moh_start_now(uint64_t cid);                                      /* IAX2: no media-state callback */
void spc_moh_on_media(uint64_t cid, int media_status);                     /* pjsua_call_media_status */

/* ---- musicbed (looping file mixed into the microphone path of every call; docs/ENGINE_API.md 10) ---- */
#define SPC_BED_MAX_CALLS 64
typedef struct {
    int active, monitor, paused, positionMs, durationMs, ncalls;
    double vol, monvol;
    char file[600], format[8];
    uint64_t calls[SPC_BED_MAX_CALLS];
} spc_bed_state;
/* Validates like call.playFile and replaces a running bed. 0 ok; else an SPC_E_* code (INVALID_PARAM only for a bad
 * file, NOT_STARTED / INTERNAL / PJ_ERROR with *pst for engine-side failures) + err, and a running bed is untouched. */
int  spc_musicbed_start(const char* file, double volume, int monitor, double monvol, spc_fileinfo* fi,
                        int* pst, char* err, size_t en);
int  spc_musicbed_stop(const char* reason, const char* msg);     /* 1 if one was running; emits media.musicbed */
int  spc_musicbed_set(double volume, double monvol, int monitor, int paused);   /* <0 = unchanged; -1 if no bed */
int  spc_musicbed_state(spc_bed_state* st);
int  spc_musicbed_level(void);
/* Topology hooks (spc_call_apply_topology): begin, once per call, end. All per-pass state lives in the caller's
 * spc_bed_pass, so concurrent passes cannot corrupt each other; each pass is authoritative for every call it sees. */
typedef struct {
    int bed_id;                                 /* g_bed->id at begin (0: none); the call list is committed only for it */
    int ncid;
    uint64_t cid[SPC_BED_MAX_CALLS];            /* calls this pass connected the bed to */
} spc_bed_pass;
void spc_musicbed_apply_begin(spc_bed_pass* bp);
/* cslot: the call's conference slot (-1: no media); local_ok: the call takes the local microphone path (active
 * media, not locally held, not detached); rec_sink1/2: recorder sinks that carry the call's local side (or -1). */
void spc_musicbed_apply_call(spc_bed_pass* bp, uint64_t cid, int cslot, int local_ok, int rec_sink1, int rec_sink2);
void spc_musicbed_apply_end(spc_bed_pass* bp);

#endif
