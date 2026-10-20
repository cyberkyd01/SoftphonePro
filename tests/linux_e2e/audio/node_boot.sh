#!/bin/bash
# Boots one QA node inside a container, as user qa: PulseAudio (null sink "out" as default output,
# null sink "micfeed" whose monitor is the default microphone), Xvfb :99 (1280x900x24), then the app under
# dbus-run-session. Usage (as qa): node_boot.sh <provision.json> <logdir> [LANG]
# Stop the app only (keep Pulse/X): pkill -x softphonepro   (app is started by app_start.sh)
set -u
PROV=${1:?provision.json}; LOGDIR=${2:?logdir}; LANGV=${3:-C.UTF-8}
export XDG_RUNTIME_DIR=/tmp/xdg-qa; mkdir -p "$XDG_RUNTIME_DIR" "$LOGDIR"; chmod 700 "$XDG_RUNTIME_DIR"
if ! pactl info >/dev/null 2>&1; then
  pulseaudio --start --exit-idle-time=-1 --log-target=file:$LOGDIR/pulse.log
  sleep 1
  pactl load-module module-null-sink sink_name=out sink_properties=device.description=Out >/dev/null
  pactl load-module module-null-sink sink_name=micfeed sink_properties=device.description=MicFeed >/dev/null
  pactl set-default-sink out
  pactl set-default-source micfeed.monitor
fi
if ! pgrep -x Xvfb >/dev/null; then
  nohup Xvfb :99 -screen 0 1280x900x24 >$LOGDIR/xvfb.log 2>&1 &
  sleep 1
fi
if command -v openbox >/dev/null && ! pgrep -x openbox >/dev/null; then DISPLAY=:99 nohup openbox >$LOGDIR/openbox.log 2>&1 & sleep 1; fi
exec /e2e/app_start.sh "$PROV" "$LOGDIR" "$LANGV"
