#!/bin/bash
# Removes stale PJSIP contacts of one AOR from the QA PBX (killed apps do not unregister).
# Usage: pbx_clean.sh <aor> [keep-port]    (needs DOCKER_HOST/DOCKER_CONFIG env for the colima VM)
aor=$1; keep=$2
docker exec spc-qa-pbx asterisk -rx "database show registrar/contact" | grep "^/registrar/contact/${aor};@" | while read -r line; do
  key=$(echo "$line" | sed -E 's#^/registrar/contact/([^ :]*):.*#\1#')
  if [ -n "$keep" ] && echo "$line" | grep -q "\"via_port\":\"$keep\""; then continue; fi
  docker exec spc-qa-pbx asterisk -rx "database del registrar/contact $key" >/dev/null
done
docker exec spc-qa-pbx asterisk -rx "pjsip show contacts" | grep -E "Contact:  ${aor}/"
