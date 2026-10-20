#!/usr/bin/env python3
"""Tone analysis of a call recording (pure python, no numpy).

Usage: analyze_wav.py file.wav [freq=440] [window_s=2]
Prints, per channel and per time window: RMS, level of `freq` (Goertzel, in dBFS) and the tone's share
of the energy. Used by the SoftphonePro Android QA (musicbed 440 Hz).
"""
import array, math, sys, wave

def goertzel(x, fs, f):
    w = 2 * math.pi * f / fs; c = 2 * math.cos(w); s1 = s2 = 0.0
    for v in x:
        s0 = v + c * s1 - s2; s2 = s1; s1 = s0
    p = s1 * s1 + s2 * s2 - c * s1 * s2
    return math.sqrt(max(p, 0)) * 2 / len(x)   # amplitude of the sinusoid

def main():
    path = sys.argv[1]; f = float(sys.argv[2]) if len(sys.argv) > 2 else 440.0
    win = float(sys.argv[3]) if len(sys.argv) > 3 else 2.0
    w = wave.open(path); ch, fs, n = w.getnchannels(), w.getframerate(), w.getnframes()
    print(f"{path}: {ch} ch, {fs} Hz, {n/fs:.1f} s, sampwidth {w.getsampwidth()}")
    a = array.array("h"); a.frombytes(w.readframes(n))
    for c in range(ch):
        x = [v / 32768 for v in a[c::ch]]; step = int(fs * win)
        print(f"channel {c}:")
        for i in range(0, len(x) - step + 1, step):
            seg = x[i:i + step]
            rms = math.sqrt(sum(v * v for v in seg) / len(seg))
            amp = goertzel(seg, fs, f)
            share = (amp * amp / 2) / (rms * rms) if rms > 1e-9 else 0
            db = 20 * math.log10(amp) if amp > 1e-9 else -99
            print(f"  t={i/fs:5.1f}s  rms={rms:.4f}  {f:.0f}Hz amp={amp:.4f} ({db:6.1f} dBFS)  share={share*100:5.1f}%")
main()
