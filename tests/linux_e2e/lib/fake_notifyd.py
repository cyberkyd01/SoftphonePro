#!/usr/bin/env python3
"""Fake org.freedesktop.Notifications server. Logs every Notify / CloseNotification call as a JSON line to
/tmp/notif.log. Control by writing lines to /tmp/notif.ctl (a FIFO):
    action <id> <action_key>     -> emits ActionInvoked(id, key)
    close <id> [reason]          -> emits NotificationClosed(id, reason)   (reason default 2 = dismissed)
Run inside the session bus: python3 fake_notifyd.py &"""
import json, os, time
import dbus, dbus.service, dbus.mainloop.glib
from gi.repository import GLib
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
name = dbus.service.BusName("org.freedesktop.Notifications", bus)
IF = "org.freedesktop.Notifications"
LOG = "/tmp/notif.log"
nid = [0]

def log(d):
    d["t"] = time.time()
    open(LOG, "a").write(json.dumps(d) + "\n")

class N(dbus.service.Object):
    @dbus.service.method(IF, out_signature="as")
    def GetCapabilities(self): return ["actions", "body", "persistence"]
    @dbus.service.method(IF, out_signature="ssss")
    def GetServerInformation(self): return ("fake-notifyd", "qa", "1.0", "1.2")
    @dbus.service.method(IF, in_signature="susssasa{sv}i", out_signature="u")
    def Notify(self, app, replaces, icon, summary, body, actions, hints, timeout):
        nid[0] += 1
        i = replaces or nid[0]
        log({"m": "Notify", "id": int(i), "app": str(app), "summary": str(summary), "body": str(body),
             "actions": [str(a) for a in actions], "timeout": int(timeout)})
        return dbus.UInt32(i)
    @dbus.service.method(IF, in_signature="u")
    def CloseNotification(self, i): log({"m": "CloseNotification", "id": int(i)})
    @dbus.service.signal(IF, signature="uu")
    def NotificationClosed(self, i, r): pass
    @dbus.service.signal(IF, signature="us")
    def ActionInvoked(self, i, k): pass

n = N(bus, "/org/freedesktop/Notifications")
CTL = "/tmp/notif.ctl"
if not os.path.exists(CTL): os.mkfifo(CTL)
fd = os.open(CTL, os.O_RDWR | os.O_NONBLOCK)
buf = [b""]
def ctl(*_):
    try: buf[0] += os.read(fd, 4096)
    except BlockingIOError: return True
    while b"\n" in buf[0]:
        line, buf[0] = buf[0].split(b"\n", 1)
        p = line.decode().strip().split(None, 2)
        if p[0] == "action": n.ActionInvoked(dbus.UInt32(int(p[1])), p[2]); log({"m": "emit ActionInvoked", "id": int(p[1]), "key": p[2]})
        elif p[0] == "close": n.NotificationClosed(dbus.UInt32(int(p[1])), dbus.UInt32(int(p[2]) if len(p) > 2 else 2))
    return True
GLib.io_add_watch(fd, GLib.IO_IN, ctl)
GLib.MainLoop().run()
