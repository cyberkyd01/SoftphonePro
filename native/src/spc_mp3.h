/* spc_mp3.h: thin wrapper around minimp3_ex (CC0) so that its implementation is compiled in one file only. */
#ifndef SPC_MP3_H
#define SPC_MP3_H
#include <stdint.h>
#include <stddef.h>

typedef struct spc_mp3 spc_mp3;
/* buf must stay valid until spc_mp3_close. Returns NULL if the data is not decodable MP3. */
spc_mp3* spc_mp3_open(const uint8_t* buf, size_t n, int* hz, int* channels, uint64_t* samples_total /* all channels */);
/* Reads up to `samples` interleaved PCM16 samples; returns the number read (0 at the end). */
size_t   spc_mp3_read(spc_mp3* m, int16_t* out, size_t samples);
void     spc_mp3_close(spc_mp3* m);
#endif
