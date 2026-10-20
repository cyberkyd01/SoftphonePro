#!/usr/bin/env python3
"""Inspect / drive the StatusNotifierItem registered with fake_sni_watcher.py (reads /tmp/sni_items.json).
  sni_client.py props            -> Status, IconName, IconThemePath, Title, ToolTip, Menu
  sni_client.py menu             -> dbusmenu layout (id: label [props])
  sni_client.py click <label>    -> Event(id,"clicked") on the first menu item whose label contains <label> (case-insens.)
  sni_client.py activate         -> Activate(0,0) on the item (left click)
"""
import json, sys
import dbus
bus = dbus.SessionBus()
it = json.load(open("/tmp/sni_items.json"))[-1]
obj = bus.get_object(it["service"], it["path"])
P = dbus.Interface(obj, "org.freedesktop.DBus.Properties")
def props():
    for ifn in ("org.kde.StatusNotifierItem", "org.ayatana.StatusNotifierItem"):
        try:
            return ifn, P.GetAll(ifn)
        except dbus.DBusException:
            pass
    return None, {}
ifn, pr = props()
def menu_obj():
    m = pr.get("Menu")
    return dbus.Interface(bus.get_object(it["service"], str(m)), "com.canonical.dbusmenu")
def walk(node, depth=0, out=None):
    out = [] if out is None else out
    i, p, ch = node
    out.append((int(i), depth, dict(p)))
    for c in ch: walk(c, depth + 1, out)
    return out
cmd = sys.argv[1]
if cmd == "props":
    print("item:", it)
    for k in ("Status", "IconName", "IconThemePath", "Title", "Category", "Id", "Menu", "ToolTip", "IconPixmap", "AttentionIconName"):
        if k in pr:
            v = pr[k]
            print(k, "=", (str(v)[:120]))
elif cmd == "menu":
    rev, layout = menu_obj().GetLayout(0, -1, [])
    for i, d, p in walk(layout):
        print("  " * d + "%d: %s %s" % (i, p.get("label"), {k: str(v) for k, v in p.items() if k != "label"}))
elif cmd == "click":
    m = menu_obj()
    rev, layout = m.GetLayout(0, -1, [])
    for i, d, p in walk(layout):
        if sys.argv[2].lower() in str(p.get("label", "")).lower():
            m.Event(i, "clicked", dbus.Int32(0), dbus.UInt32(0)); print("clicked", i, p.get("label")); break
    else:
        print("no such item"); sys.exit(1)
elif cmd == "activate":
    dbus.Interface(obj, ifn).Activate(0, 0)
