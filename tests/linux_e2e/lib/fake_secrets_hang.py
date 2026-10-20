#!/usr/bin/env python3
"""Fake Secret Service that owns org.freedesktop.secrets and NEVER answers any method call (hung daemon).
Run inside the session bus: python3 fake_secrets_hang.py &"""
import dbus, dbus.service, dbus.mainloop.glib
from gi.repository import GLib
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
name = dbus.service.BusName("org.freedesktop.secrets", bus)

class Svc(dbus.service.Object):
    @dbus.service.method("org.freedesktop.Secret.Service", in_signature="s", out_signature="o", async_callbacks=("ok", "err"))
    def ReadAlias(self, a, ok, err): pass          # never replies
    @dbus.service.method("org.freedesktop.Secret.Service", in_signature="sv", out_signature="vo", async_callbacks=("ok", "err"))
    def OpenSession(self, a, i, ok, err): pass
    @dbus.service.method("org.freedesktop.Secret.Service", in_signature="a{ss}", out_signature="aoao", async_callbacks=("ok", "err"))
    def SearchItems(self, a, ok, err): pass
    @dbus.service.method("org.freedesktop.Secret.Service", in_signature="ao", out_signature="aoo", async_callbacks=("ok", "err"))
    def Unlock(self, a, ok, err): pass
    @dbus.service.method("dbus.org.freedesktop.DBus.Properties", in_signature="ss", out_signature="v", async_callbacks=("ok", "err"))
    def Get(self, i, p, ok, err): pass

Svc(bus, "/org/freedesktop/secrets")
GLib.MainLoop().run()
