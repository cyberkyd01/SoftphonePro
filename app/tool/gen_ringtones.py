#!/usr/bin/env python3
"""Synthesises the bundled ringtones and the record beep (stdlib only).

Usage:  python3 tool/gen_ringtones.py   (run from the app/ directory)

Output: assets/sounds/{classic,soft,digital}.wav (16-bit mono 16 kHz,
~3.6 s, loop-safe: they start and end in silence) and record_beep.wav.
"""
import math
import os
import struct
import wave

RATE = 16000
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "sounds")


def silence(sec):
    return [0.0] * int(RATE * sec)


def env_ad(n, attack, release):
    """Linear attack / release envelope for n samples."""
    a = max(1, int(attack * RATE))
    r = max(1, int(release * RATE))
    out = []
    for i in range(n):
        e = 1.0
        if i < a:
            e = i / a
        if i > n - r:
            e = min(e, (n - i) / r)
        out.append(max(0.0, e))
    return out


def tone(freqs, sec, amp=0.4, attack=0.01, release=0.03, am=None):
    n = int(RATE * sec)
    env = env_ad(n, attack, release)
    out = []
    for i in range(n):
        t = i / RATE
        s = sum(math.sin(2 * math.pi * f * t) for f in freqs) / len(freqs)
        if am:
            s *= 0.5 * (1 + math.sin(2 * math.pi * am * t))
        out.append(s * env[i] * amp)
    return out


def bell(freq, sec, amp=0.5, decay=6.0):
    """Marimba-like struck tone: fundamental + 4x partial, exponential decay."""
    n = int(RATE * sec)
    out = []
    for i in range(n):
        t = i / RATE
        s = math.sin(2 * math.pi * freq * t) + 0.25 * math.sin(2 * math.pi * freq * 4 * t) * math.exp(-t * 18)
        s *= math.exp(-t * decay) * min(1.0, t / 0.004)
        out.append(s * amp)
    return out


def mix_into(buf, sig, at):
    start = int(at * RATE)
    for i, v in enumerate(sig):
        if start + i < len(buf):
            buf[start + i] += v


def classic():
    # 2 x (400+450 Hz, 0.8 s with 25 Hz AM) rings with gaps, then a long pause.
    buf = silence(3.6)
    ring = tone([440, 480], 0.8, amp=0.55, am=20)
    mix_into(buf, ring, 0.05)
    mix_into(buf, ring, 1.05)
    return buf


def soft():
    buf = silence(3.6)
    notes = [(0.00, 659.25), (0.28, 783.99), (0.56, 987.77), (0.84, 783.99),
             (1.80, 659.25), (2.08, 783.99), (2.36, 987.77), (2.64, 783.99)]
    for at, f in notes:
        mix_into(buf, bell(f, 0.9, amp=0.45), at)
    return buf


def digital():
    buf = silence(3.6)
    for base in (0.0, 1.8):
        for k in range(4):
            f0 = 900 + 250 * k
            n = int(0.09 * RATE)
            env = env_ad(n, 0.005, 0.02)
            chirp = []
            for i in range(n):
                t = i / RATE
                f = f0 + 2500 * t
                chirp.append(math.sin(2 * math.pi * f * t) * env[i] * 0.4)
            mix_into(buf, chirp, base + 0.05 + k * 0.14)
    return buf


def record_beep():
    return tone([1400], 0.35, amp=0.35, attack=0.01, release=0.05)


def write(name, samples):
    path = os.path.join(OUT, name)
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = min(1.0, 0.9 / peak)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples))
    print("wrote", os.path.normpath(path))


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    write("classic.wav", classic())
    write("soft.wav", soft())
    write("digital.wav", digital())
    write("record_beep.wav", record_beep())
