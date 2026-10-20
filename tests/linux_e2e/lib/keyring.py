#!/usr/bin/env python3
"""Small Secret Service helper for the QA scripts (python3-dbus).
  keyring.py state          -> prints Locked flag of the default collection (0/1)
  keyring.py lock|unlock    -> Service.Lock / Service.Unlock (unlock may need a prompt; use the window)
  keyring.py items          -> lists items of the default collection (label, attributes)
"""
import sys
import dbus
b = dbus.SessionBus()
S = "org.freedesktop.secrets"
svc = dbus.Interface(b.get_object(S, "/org/freedesktop/secrets"), "org.freedesktop.Secret.Service")
col = str(svc.ReadAlias("default"))
props = lambda p: dbus.Interface(b.get_object(S, p), "org.freedesktop.DBus.Properties")
cmd = sys.argv[1]
if cmd == "state":
    print(int(props(col).Get("org.freedesktop.Secret.Collection", "Locked")))
elif cmd == "lock":
    print(svc.Lock([col]))
elif cmd == "unlock":
    print(svc.Unlock([col]))
elif cmd == "items":
    for i in props(col).Get("org.freedesktop.Secret.Collection", "Items"):
        print(i, props(i).Get("org.freedesktop.Secret.Item", "Label"), dict(props(i).Get("org.freedesktop.Secret.Item", "Attributes")))
