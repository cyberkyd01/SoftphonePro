#!/usr/bin/env python3
"""Synthesises the built-in hold music and the notice chime (stdlib only).

Output (16 kHz, mono, PCM16) goes to app/assets/sounds/:
  hold_calm.wav    ~32 s, slow warm pads with soft plucks (loopable)
  hold_breeze.wav  ~36 s, gentle 3/4 arpeggios (loopable)
  chime.wav        ~1.2 s two-note notice chime

Everything is generated from sine waves, so the files are royalty free.
Loops are click free: every note envelope is zero at both ends of the file.

Run:  python3 app/tool/gen_hold_music.py
"""
import math
import os
import struct
import wave

RATE = 16000
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'sounds')


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12.0)


def add_note(buf, start, dur, freq, amp, attack=0.05, release=0.4, harmonics=((1, 1.0), (2, 0.25), (3, 0.08)), vib=0.0):
    n0 = int(start * RATE)
    total = int((dur + release) * RATE)
    for i in range(total):
        j = n0 + i
        if j >= len(buf):
            break
        t = i / RATE
        if t < attack:
            env = t / attack
        elif t < dur:
            env = 1.0
        else:
            env = max(0.0, 1.0 - (t - dur) / release)
        env = env * env * (3 - 2 * env) if env < 1.0 else 1.0  # smoothstep
        f = freq * (1 + vib * math.sin(2 * math.pi * 4.5 * t))
        v = 0.0
        for h, a in harmonics:
            v += a * math.sin(2 * math.pi * f * h * t)
        buf[j] += amp * env * v


def pluck(buf, start, freq, amp, decay=1.6):
    n0 = int(start * RATE)
    total = int(decay * 2.2 * RATE)
    for i in range(total):
        j = n0 + i
        if j >= len(buf):
            break
        t = i / RATE
        env = math.exp(-t / (decay * 0.45)) * min(1.0, t / 0.004)
        v = math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(2 * math.pi * 2 * freq * t) * math.exp(-t * 3)
        buf[j] += amp * env * v


def finish(buf, name, peak=0.55, fade=0.02):
    m = max(abs(x) for x in buf) or 1.0
    k = peak / m
    n = len(buf)
    fn = int(fade * RATE)
    path = os.path.join(OUT, name)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = bytearray()
        for i, x in enumerate(buf):
            g = 1.0
            if i < fn:
                g = i / fn
            elif i > n - fn:
                g = (n - i) / fn
            frames += struct.pack('<h', int(max(-1, min(1, x * k * g)) * 32767))
        w.writeframes(bytes(frames))
    print(name, n / RATE, 's', os.path.getsize(path), 'bytes')


def reverb(buf, mix=0.28):
    # Cheap feedback comb "room": soft and airy, wraps around so loops stay seamless.
    out = list(buf)
    n = len(buf)
    for delay, g in ((0.071, 0.5), (0.113, 0.42), (0.173, 0.33)):
        d = int(delay * RATE)
        for i in range(n):
            out[i] += mix * g * buf[(i - d) % n]
    return out


def calm():
    bpm = 60.0
    beat = 60.0 / bpm
    bar = 4 * beat
    # Cmaj7 - Am7 - Fmaj7 - G6, twice, 4 bars each pass -> 8 bars * 4 s = 32 s
    chords = [[48, 55, 59, 64], [45, 52, 60, 64], [41, 48, 57, 64], [43, 50, 59, 64]]
    length = bar * 8
    buf = [0.0] * int(length * RATE)
    for b in range(8):
        for k, nn in enumerate(chords[b % 4]):
            add_note(buf, b * bar, bar - 0.2, midi(nn), 0.13, attack=0.9, release=1.4, vib=0.002)
    scale = [72, 74, 76, 79, 81, 84]
    seq = [0, 2, 3, 2, 4, 3, 1, 2, 5, 4, 3, 2, 1, 0, 2, 3]
    for i, s in enumerate(seq * 2):
        t = 0.5 + i * (bar / 4) * 1.0
        if t < length - 3:
            pluck(buf, t, midi(scale[s]), 0.09)
    return reverb(buf)


def breeze():
    beat = 0.6
    bar = 3 * beat
    chords = [[50, 57, 61, 66], [47, 54, 59, 62], [43, 50, 59, 62], [45, 52, 61, 64]]
    bars = 20
    length = bar * bars  # 36 s
    buf = [0.0] * int(length * RATE)
    for b in range(bars):
        ch = chords[(b // 1) % 4]
        add_note(buf, b * bar, bar, midi(ch[0] - 12), 0.12, attack=0.4, release=1.0, harmonics=((1, 1.0), (2, 0.15)))
        arp = [ch[1], ch[2], ch[3] + 12]
        for k, nn in enumerate(arp):
            if b * bar + k * beat < length - 3:
                pluck(buf, b * bar + k * beat, midi(nn), 0.11, decay=1.2)
    return reverb(buf, 0.3)


def chime():
    buf = [0.0] * int(1.2 * RATE)
    pluck(buf, 0.0, midi(79), 0.5, decay=0.5)
    pluck(buf, 0.22, midi(84), 0.5, decay=0.6)
    return buf


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    finish(calm(), 'hold_calm.wav')
    finish(breeze(), 'hold_breeze.wav')
    finish(chime(), 'chime.wav', peak=0.6)
