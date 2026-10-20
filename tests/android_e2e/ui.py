#!/usr/bin/env python3
"""adb UI helper for the SoftphonePro Android QA (emulator-5554).

Usage:
  ui.py dump                      print visible text / content-desc / bounds
  ui.py tap "text"                tap first node whose text or content-desc contains "text" (case-insens.)
  ui.py tapxy X Y
  ui.py type "text"               adb input text (spaces -> %s)
  ui.py shot NAME                 save docs/qa-screenshots/v110_android_NAME.png
  ui.py swipe X1 Y1 X2 Y2 [ms]
  ui.py find "text"               print bounds of matches (exit 1 if none)
"""
import re, subprocess, sys, time, os
import xml.etree.ElementTree as ET

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SHOTS = os.path.join(ROOT, "docs", "qa-screenshots")

def adb(*a, **k):
    return subprocess.run(["adb", *a], capture_output=True, **k)

def nodes():
    for _ in range(3):
        adb("shell", "uiautomator", "dump", "/sdcard/ui.xml")
        r = adb("exec-out", "cat", "/sdcard/ui.xml")
        try:
            tree = ET.fromstring(r.stdout.decode("utf8", "replace"))
            break
        except ET.ParseError:
            time.sleep(1)
    else:
        return []
    out = []
    for n in tree.iter("node"):
        t = n.get("text") or ""
        d = n.get("content-desc") or ""
        b = list(map(int, re.findall(r"\d+", n.get("bounds"))))
        out.append((t, d, b, n.get("clickable") == "true"))
    return out

def center(b):
    return (b[0] + b[2]) // 2, (b[1] + b[3]) // 2

def find(txt):
    txt = txt.lower()
    m = [n for n in nodes() if txt in n[0].lower() or txt in n[1].lower()]
    return sorted(m, key=lambda n: not n[3])

def tap(x, y):
    adb("shell", "input", "tap", str(x), str(y))

if __name__ == "__main__":
    c = sys.argv[1]
    if c == "dump":
        for t, d, b, cl in nodes():
            if t or d:
                print(f"{'*' if cl else ' '} {b} {t!r} {d!r}")
    elif c == "tap":
        m = find(sys.argv[2])
        if not m: print("NOT FOUND", sys.argv[2]); sys.exit(1)
        x, y = center(m[0][2]); tap(x, y); print("tapped", m[0][:2], x, y)
    elif c == "tapxy": tap(sys.argv[2], sys.argv[3])
    elif c == "type": adb("shell", "input", "text", sys.argv[2].replace(" ", "%s"))
    elif c == "swipe":
        adb("shell", "input", "swipe", *sys.argv[2:6], *(sys.argv[6:7] or ["300"]))
    elif c == "find":
        m = find(sys.argv[2])
        for x in m: print(x)
        sys.exit(0 if m else 1)
    elif c == "shot":
        p = os.path.join(SHOTS, f"v110_android_{sys.argv[2]}.png")
        open(p, "wb").write(adb("exec-out", "screencap", "-p").stdout); print(p)
