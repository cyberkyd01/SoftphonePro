/* spc_rec.h: recorders built on conference-bridge sink ports and a writer thread (wavStereo, Ogg Opus, mic WAV). */
#ifndef SPC_REC_H
#define SPC_REC_H
#include <stdint.h>
#include <stddef.h>

enum { SPC_REC_WAV_MONO = 0, SPC_REC_WAV_STEREO = 1, SPC_REC_OPUS = 2 };

typedef struct { char file[600]; int durationMs; int64_t bytes; char format[12]; } spc_rec_result;

/* cid == 0: microphone recorder (media.recordMicStart). mix: 0 both, 1 remote, 2 local (call recorders, mono formats). */
int  spc_rec_start(int fmt, uint64_t cid, int mix, const char* file, int* id, char* err, size_t en);
int  spc_rec_stop(int id, spc_rec_result* out);                  /* 0 ok; blocks until the file is finalised */
/* Topology hooks. */
/* msrc/dnm: the mic-source arguments the topology passes to conn_mic() (see spc_call.c). */
void spc_rec_apply_call(int id, int cslot, int active, int muted, int detached, int msrc, int dnm);
void spc_rec_apply_global(int msrc, int dnm);                              /* microphone recorder */
int  spc_rec_local_sink(int id);                                  /* slot carrying the local side, -1 if none */
int  spc_rec_mic_id(void);                                       /* active microphone recorder id or 0 */
void spc_rec_shutdown(void);
int  spc_rec_opus_available(void);
/* Duration of a finalised PCM16 WAV file (ms), -1 if the header is not understood. */
int  spc_wav_duration_ms(const char* path);
int64_t spc_file_size(const char* path);
#endif
