#!/usr/bin/env python3
"""cpu.py [secs=20]: % of one core used by the softphonepro process (all threads) over secs."""
import os, time, sys
secs = float(sys.argv[1]) if len(sys.argv) > 1 else 20
pid = int(os.popen('pgrep -x softphonepro | head -1').read().split()[0])
def t():
    s = 0
    for d in os.listdir(f'/proc/{pid}/task'):
        try:
            p = open(f'/proc/{pid}/task/{d}/stat').read().rsplit(')', 1)[1].split(); s += int(p[11]) + int(p[12])
        except Exception: pass
    return s
a = t(); t0 = time.time(); time.sleep(secs); b = t()
print(round((b - a) / os.sysconf('SC_CLK_TCK') / (time.time() - t0) * 100, 1))
