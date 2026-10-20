#!/bin/bash
# Run as user qa inside a qa-desk-* container: start_app.sh <ext> [extra-settings-json-fragment] [-- app args...]
# Provisions account <ext> (pass<ext>@172.30.0.10, UDP), enables the automation API (port 7771) and waits for registration.
. /tmp/session.env; . /e2e/lib/h.sh
u=$1; extra=$2; shift 2; [ "$1" = "--" ] && shift
prov "$u" "$extra"
(SOFTPHONEPRO_DEBUG_DESKTOP=1 setsid nohup softphonepro --provision /tmp/prov.json "$@" >/tmp/app.out 2>&1 &)
for i in $(seq 200); do api GET /v1/status 2>/dev/null | grep -q SoftphonePro && break; sleep 0.2; done
for i in $(seq 100); do api GET /v1/status | grep -q '"regState":"registered"' && { echo registered; exit 0; }; sleep 0.3; done
echo "NOT registered"; api GET /v1/status | head -c 400; exit 1
