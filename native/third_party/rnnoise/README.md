# RNNoise (vendored)

* Upstream: https://github.com/xiph/rnnoise, tag **v0.1.1**, commit
  `6cbfd53eb348a8d394e0757b4025c6ded34eb2b6`.
* Licence: BSD-3-Clause (Xiph.Org / Mozilla / Jean-Marc Valin), see `COPYING`.
* Release tarball (GitHub, v0.1.1.tar.gz) SHA-256: 1641712c9ae31f3b364e8b2f2e0ec3ce24330e76055c151f695941b0ea5d3987
* Why v0.1.1 and not v0.2: v0.2 does not ship its weights in git. They come from
  `download_model.sh` (model `rnnoise_data-0b50c45.tar.gz`, SHA-256
  `4ac81c5c0884ec4bd5907026aaae16209b7b76cd9d7f71af582094a2f98f4b43`; the
  upstream `model_version` file only holds the id `0b50c45`, there is no separate sha
  file). The generated `rnnoise_data.c` is 29 MB (15 MB for the "little" variant), above
  the 8 MB budget for a compiled-in model. v0.1.1 ships a compact compiled-in model
  (`src/rnn_data.c`, 425 KB, SHA-256 `7b90ed18f065a34597d80b4c00e140a7c5eb6380ef8c9c6bf265384c944ae708`),
  which is what we use. Upgrading to v0.2 is a drop-in future option if the size budget changes.
* Only the files needed by the library are vendored (no autotools, no training code, no
  `rnn_reader.c`/custom model loading). `config.h` is an empty stub.

## spcore portability changes
See `spcore-portability.patch` (diff against pristine v0.1.1 `src/`):
* C99 VLAs in `celt_lpc.c` and `pitch.c` replaced by fixed arrays bounded by
  `SPC_RNN_MAXN` (MSVC has no VLAs). Real call sizes are far below the bound.
* Two deliberate `*(int*)0=0` null writes (unreachable activation fallbacks) removed.
* `CommonState common` made `static` (avoid symbol clashes).

Note: RNNoise lazily initialises its global tables on first use, which is not thread-safe.
spcore forces that initialisation once under a lock (`spc_denoise.c`) before any concurrent use.

## Upstream file SHA-256 (pristine v0.1.1)
```
3ad2508b5110e2a2633977a6577a87862ad8f15df88edba36b1f4f2fabf9ff6a  src/celt_lpc.c
b56b222b3db7533e0d844531b80c4f9c62f2c3a534a59e2d83e447b722bb6231  src/denoise.c
0db4a5555a6b9cf249d44671c07081836dd72a8011b908b8701abd37de703b5a  src/kiss_fft.c
72523f1c918146a2b4fd0db906ebefd280c04d64d4a3fba991aa64f686315c68  src/pitch.c
c6c343a607490996501fad948a7ef651b9a0c570a9b214b0901c63b226169dbb  src/rnn.c
7b90ed18f065a34597d80b4c00e140a7c5eb6380ef8c9c6bf265384c944ae708  src/rnn_data.c
8e6cbb1e0ecdfcf800765fc5685d4fb1d239f104b6e7be94a4b71a3d5d8f6bd1  src/rnn_reader.c
0214dfe2aabb3b81d88fe814b8253fc2ec6da12bbbc98e08c1011a5bd60e3b29  src/_kiss_fft_guts.h
1686a3ca5817bb7d99049a1801c6ab3a7e91a5d0a6804b1c1cafb36e5eeb62f8  src/arch.h
2190d9bd519c4528770a28fb0e8b599eb195782fb5dcd91378eb92e3ca7d5148  src/celt_lpc.h
fa6069db8f7fd18d79d5bea55cded6f9019570b2886908323270d07225c7c0ce  src/common.h
ab292aa012ca5a78f7550a5b1d653a240adfcec65f943941bd2ee88a334f669f  src/kiss_fft.h
e2c1075e26567b8d57706d2f0042e36d5d440721fc3fd27a6fce9f0fc8a31557  src/opus_types.h
e2f062636f9730343a64accdc8e703be616ddcc22c5c65155f92e4318c0953c0  src/pitch.h
7c2bcf38a81080feeb7b718eed41517afd44e446a44772121e1b156516dcdf28  src/rnn.h
e756aad79f6f0710cd1fa4abfd9db3da693e92ac3a3a90051e2c969578452653  src/rnn_data.h
835fcdf08d5b92e249fbe9ba6cdd9758688a5fdf134efb9da0e42989e8c18b8a  src/tansig_table.h
```
