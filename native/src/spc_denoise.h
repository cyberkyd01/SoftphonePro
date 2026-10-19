/* spc_denoise: RNNoise based voice isolation, as conference-bridge "processor" ports (see docs/ENGINE_API.md 9.1). */
#ifndef SPC_DENOISE_H
#define SPC_DENOISE_H

#include <pjsua-lib/pjsua.h>
#include "cJSON.h"

/* core.start: validate media.voiceIsolation before anything is started (0 ok, -1 invalid with message in err). */
int  spc_denoise_validate(const cJSON* vi, char* err, size_t en);
void spc_denoise_configure(const cJSON* vi);       /* stash validated config (may be NULL = defaults, all off) */
void spc_denoise_start(void);                      /* after pjsua_start: creates the atomics, warms RNNoise */
void spc_denoise_shutdown(void);                   /* before pjsua_destroy: removes the mic port */

/* Topology helpers (spc_call.c). Safe from any thread; no lock is held across pjsua calls. */
int  spc_denoise_mic_wanted(void);                 /* mic isolation enabled */
int  spc_denoise_mic_slot(void);                   /* conf slot of the mic processor (creates it lazily), -1 if disabled/unavailable */
int  spc_denoise_mic_slot_peek(void);              /* existing slot or -1; never creates */
int  spc_denoise_in_wanted(void);                  /* incoming isolation enabled */
void* spc_denoise_in_create(int* slot);            /* per-call incoming processor, NULL on failure */
void spc_denoise_in_destroy(void* h, int slot);    /* removes from the bridge and frees */

#endif
