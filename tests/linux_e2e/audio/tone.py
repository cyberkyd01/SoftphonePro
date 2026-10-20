#!/usr/bin/env python3
"""tone.py wav t0 t1 chan f1 f2 ... -> JSON {freq: dBFS-RMS of that tone (+-25 Hz band), 'total': dBFS, 'dur': s}
t0/t1 seconds (-1 = whole file); chan -1 = mean of channels."""
import sys, json, wave, numpy as np
w = wave.open(sys.argv[1]); n = w.getnframes(); ch = w.getnchannels(); sr = w.getframerate()
d = np.frombuffer(w.readframes(n), dtype=np.int16).astype(float) / 32768
d = d.reshape(-1, ch)
c = int(sys.argv[4]); x = d.mean(1) if c < 0 else d[:, c]
t0, t1 = float(sys.argv[2]), float(sys.argv[3])
x = x[int(max(t0, 0) * sr): int(t1 * sr) if t1 > 0 else None]
out = {"dur": len(x) / sr}
if len(x) < 256: out["err"] = "too short"; print(json.dumps(out)); sys.exit()
win = np.hanning(len(x)); X = np.abs(np.fft.rfft(x * win)) / (win.sum() / 2)
fr = np.fft.rfftfreq(len(x), 1 / sr)
def db(a): return round(20 * np.log10(max(a, 1e-9)), 1)
for f in [a for a in sys.argv[5:] if a != "peaks"]:
    m = (fr > float(f) - 25) & (fr < float(f) + 25)
    out[f] = db(X[m].max() / np.sqrt(2)) if m.any() else None   # peak amp -> RMS
if "peaks" in sys.argv[5:]:
    idx = np.argsort(X)[::-1]; pk = []
    for i in idx:
        if all(abs(fr[i] - q) > 60 for q, _ in pk): pk.append((round(float(fr[i])), db(X[i] / np.sqrt(2))))
        if len(pk) >= 5: break
    out["peaks"] = pk
out["total"] = db(np.sqrt((x ** 2).mean()))
print(json.dumps(out))
