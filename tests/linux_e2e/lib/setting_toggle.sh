#!/bin/bash
# Inside a desk container as qa: setting_toggle.sh <key> <json value>
# Applies one setting to the running app through a second `softphonepro --provision` and prints the engine state transitions (poll 0.2 s, 20 s).
. /e2e/lib/h.sh
echo "{\"settings\":{\"$1\":$2}}" > /tmp/p2.json
t0=$(date +%s.%N); last=""
(softphonepro --provision /tmp/p2.json >/dev/null 2>&1 &)
for i in $(seq 100); do
  s=$(api GET /v1/status 2>/dev/null | grep -o '"engine":{[^}]*}' | grep -o '"state":"[a-z]*"\|"error":"[^"]*"' | tr '\n' ' ')
  if [ "$s" != "$last" ]; then echo "$(python3 -c "import time;print(round(time.time()-$t0,1))")s $s"; last="$s"; fi
  sleep 0.2
done
