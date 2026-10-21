#!/usr/bin/env python3
"""Runs in a container: cap.py <source> <secs> -> JSON {rms_dbfs, peak_hz, hz1000_db, hz880_db, hz440_db}. Records with parec."""
import sys, subprocess, json, numpy as np
src, secs = sys.argv[1], float(sys.argv[2])
try:
    raw = subprocess.run(['timeout', str(secs), 'parec', '-d', src, '--rate=48000', '--channels=1', '--format=s16le', '--latency-msec=50'], capture_output=True).stdout
except Exception as e:
    print(json.dumps({'err': str(e)})); sys.exit()
x = np.frombuffer(raw[:len(raw)//2*2], dtype=np.int16).astype(float) / 32768
if len(x) < 4800: print(json.dumps({'err': 'no samples', 'n': len(x)})); sys.exit()
db = lambda a: round(20*np.log10(max(a, 1e-9)), 1)
w = np.hanning(len(x)); X = np.abs(np.fft.rfft(x*w))/(w.sum()/2); fr = np.fft.rfftfreq(len(x), 1/48000)
o = {'n': len(x), 'rms_dbfs': db(np.sqrt((x**2).mean())), 'peak_hz': round(float(fr[X.argmax()])), 'peak_db': db(X.max()/np.sqrt(2))}
for f in (440, 880, 1000):
    m = (fr > f-25) & (fr < f+25); o[f'hz{f}_db'] = db(X[m].max()/np.sqrt(2))
print(json.dumps(o))
