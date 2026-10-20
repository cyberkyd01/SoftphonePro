"""Boot nodes A (1001) and B (1002) with auto-record (stereo WAV). Usage: boot_pair.py [A_container B_container]"""
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
import sys; sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = (sys.argv[1:3] + ['qa-audio-a', 'qa-audio-b'])[:2] if len(sys.argv) > 2 else ('qa-audio-a', 'qa-audio-b')
for n, u, p in [(A, '1001', 'pass1001'), (B, '1002', 'pass1002')]:
    pv = provision(n, u, p, {"recordRule": "all", "autoRecord": True, "recordFormat": "wavStereo"})
    st = boot(n, pv)
    print(n, st['version'], wait(lambda: registered(n), 20))
