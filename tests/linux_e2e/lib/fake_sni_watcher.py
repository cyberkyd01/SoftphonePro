#!/usr/bin/env python3
"""Minimal org.kde.StatusNotifierWatcher for the tray tests. Owns the name, accepts RegisterStatusNotifierItem
and writes the registered item as JSON to /tmp/sni_items.json ([{"service":..., "path":...}]).
Run inside the session bus: python3 fake_sni_watcher.py &"""
import json
import dbus, dbus.service, dbus.mainloop.glib
from gi.repository import GLib
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
name = dbus.service.BusName("org.kde.StatusNotifierWatcher", bus)
IF = "org.kde.StatusNotifierWatcher"
items = []

class W(dbus.service.Object):
    @dbus.service.method(IF, in_signature="s", sender_keyword="sender")
    def RegisterStatusNotifierItem(self, svc, sender=None):
        if svc.startswith("/"):
            entry = {"service": sender, "path": svc}
        else:
            entry = {"service": svc, "path": "/StatusNotifierItem"}
        items.append(entry)
        json.dump(items, open("/tmp/sni_items.json", "w"))
        self.StatusNotifierItemRegistered(entry["service"] + entry["path"])
    @dbus.service.method(IF, in_signature="s")
    def RegisterStatusNotifierHost(self, s): pass
    @dbus.service.signal(IF, signature="s")
    def StatusNotifierItemRegistered(self, s): pass
    @dbus.service.signal(IF, signature="")
    def StatusNotifierHostRegistered(self): pass
    @dbus.service.method("org.freedesktop.DBus.Properties", in_signature="ss", out_signature="v")
    def Get(self, i, p): return self.GetAll(i)[p]
    @dbus.service.method("org.freedesktop.DBus.Properties", in_signature="s", out_signature="a{sv}")
    def GetAll(self, i):
        return {"RegisteredStatusNotifierItems": dbus.Array([e["service"] + e["path"] for e in items], signature="s"),
                "IsStatusNotifierHostRegistered": True, "ProtocolVersion": dbus.Int32(0)}

W(bus, "/StatusNotifierWatcher")
GLib.MainLoop().run()
