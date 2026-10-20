#!/usr/bin/env python3
"""envelope.py wav chan [frame_ms] -> prints time ranges where the 50ms RMS envelope is >6 dB below the median (dips/gaps), plus level stats."""
import sys, wave, numpy as np
w = wave.open(sys.argv[1]); ch = w.getnchannels(); sr = w.getframerate()
d = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(float) / 32768
x = d.reshape(-1, ch)[:, int(sys.argv[2])]
fm = int(sys.argv[3]) if len(sys.argv) > 3 else 50
n = int(sr * fm / 1000); m = len(x) // n
e = 20 * np.log10(np.sqrt((x[:m * n].reshape(m, n) ** 2).mean(1)) + 1e-9)
print("frames", m, "dur", round(len(x) / sr, 2), "median", round(float(np.median(e)), 1))
med = np.median(e[e > -60]) if (e > -60).any() else -99
runs = []; i = 0
while i < m:
    if -90 < e[i] < med - 3:
        j = i
        while j < m and e[j] < med - 3: j += 1
        runs.append((round(i * fm / 1000, 2), round(j * fm / 1000, 2), round(float(e[i:j].min()), 1))); i = j
    else: i += 1
print("dips(-3dB):", runs[:30])
