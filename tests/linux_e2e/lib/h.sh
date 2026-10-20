#!/bin/bash
# Helper sourced inside a container (as user qa): `. /e2e/lib/h.sh` loads the session env and defines helpers.
. /tmp/session.env
export TOKEN=${TOKEN:-0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef} PORT=${PORT:-7771}
api() { local m=$1 p=$2; shift 2; curl -sS -m 8 -X "$m" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "$@" "http://127.0.0.1:$PORT$p"; }
shot() { mkdir -p /e2e/shots; import -window root "/e2e/shots/$1.png"; }
# prov <user> [extra settings json fragment e.g. '"startAtLogin":false'] -> writes /tmp/prov.json
prov() {
  local u=$1 extra=$2
  cat > /tmp/prov.json <<J
{"accounts":[{"username":"$u","password":"pass$u","domain":"172.30.0.10","transport":"udp","label":"qa$u"}],
 "settings":{"automationEnabled":true,"automationPort":$PORT,"automationToken":"$TOKEN","stunServers":[]${extra:+,$extra}}}
J
}
# st: WM_STATE of the main SoftphonePro window (Normal/Iconic/none); vis: ids of mapped+viewable windows with that title
st() { xprop -id $(xdotool search --name "^SoftphonePro$" | tail -1) WM_STATE 2>/dev/null | grep "window state" | tr -d '\t'; }
vis() { echo "visible: $(xdotool search --onlyvisible --name '^SoftphonePro$' | tr '\n' ' ')"; }
