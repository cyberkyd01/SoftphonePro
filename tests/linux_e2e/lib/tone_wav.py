#!/usr/bin/env python3
"""tone_wav.py out.wav secs freq [tremolo_hz]: mono 48k s16 sine at -6 dBFS peak (python only, no numpy)."""
import sys, wave, math, struct
out, secs, f = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]); tr = float(sys.argv[4]) if len(sys.argv) > 4 else 0
w = wave.open(out, 'wb'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(48000)
n = int(48000 * secs); buf = bytearray()
for i in range(n):
    a = 0.5 * math.sin(2 * math.pi * f * i / 48000)
    if tr: a *= 0.55 + 0.45 * math.sin(2 * math.pi * tr * i / 48000)
    buf += struct.pack('<h', int(a * 32767))
    if len(buf) > 1 << 20: w.writeframes(bytes(buf)); buf = bytearray()
w.writeframes(bytes(buf)); w.close()
