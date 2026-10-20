#!/bin/bash
# Starts a fresh desktop session inside a qa-desk-* container (run as user qa, detached):
#   Xvfb :99 (1280x900x24), optional openbox (WM=1), PulseAudio null sink, then a private D-Bus session.
# The environment needed by later `docker exec` calls is written to /tmp/session.env (source it).
# Usage: session.sh [--wm]   (HOME is wiped by reset.sh, not here)
WM=0; [ "$1" = "--wm" ] && WM=1
export DISPLAY=:99
rm -f /tmp/.X99-lock /tmp/session.env
Xvfb :99 -screen 0 1280x900x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
for i in $(seq 50); do xdpyinfo >/dev/null 2>&1 && break; sleep 0.2; done
exec dbus-run-session -- bash -c '
  echo "export DISPLAY=:99 DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS XDG_SESSION_TYPE=x11 LANG=C.UTF-8" > /tmp/session.env
  if [ "'$WM'" = 1 ]; then openbox >/tmp/openbox.log 2>&1 & fi
  pulseaudio --start --exit-idle-time=-1 --load="module-null-sink" >/tmp/pa.log 2>&1
  exec sleep infinity'
