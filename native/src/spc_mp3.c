/* spc_mp3.c: minimp3 implementation unit (third_party/minimp3, CC0). Compiled with warnings off. */
#define MINIMP3_IMPLEMENTATION
#define MINIMP3_NO_STDIO
#include "minimp3_ex.h"
#include "spc_mp3.h"
#include <stdlib.h>
#include <string.h>

struct spc_mp3 { mp3dec_ex_t dec; };

spc_mp3* spc_mp3_open(const uint8_t* buf, size_t n, int* hz, int* channels, uint64_t* samples_total)
{
    spc_mp3* m = (spc_mp3*)calloc(1, sizeof(*m));
    if (!m) return NULL;
    if (mp3dec_ex_open_buf(&m->dec, buf, n, MP3D_SEEK_TO_BYTE) != 0 || m->dec.info.hz <= 0 ||
        m->dec.info.channels <= 0 || m->dec.samples == 0) {
        mp3dec_ex_close(&m->dec);
        free(m);
        return NULL;
    }
    *hz = m->dec.info.hz;
    *channels = m->dec.info.channels;
    *samples_total = m->dec.samples;
    return m;
}

size_t spc_mp3_read(spc_mp3* m, int16_t* out, size_t samples)
{
    return mp3dec_ex_read(&m->dec, (mp3d_sample_t*)out, samples);
}

void spc_mp3_close(spc_mp3* m)
{
    if (!m) return;
    mp3dec_ex_close(&m->dec);
    free(m);
}
