#!/bin/bash
# Start the app (detached) under dbus-run-session on DISPLAY :99. Args: provision.json logdir lang
PROV=$1; LOGDIR=$2; LANGV=${3:-C.UTF-8}
export XDG_RUNTIME_DIR=/tmp/xdg-qa DISPLAY=:99 XDG_SESSION_TYPE=x11
if [ "$LANGV" = "C" ]; then export LANG=C LC_ALL=C LANGUAGE=; else export LANG=$LANGV; fi
nohup dbus-run-session -- softphonepro ${PROV:+--provision "$PROV"} >>"$LOGDIR/app.out" 2>>"$LOGDIR/app.err" &
echo started
