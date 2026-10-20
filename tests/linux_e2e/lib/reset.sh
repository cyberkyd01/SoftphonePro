#!/bin/bash
# Kills the session of user qa in this container, wipes the profile and starts a new one.
# Usage (as root): reset.sh [--wm]
pkill -9 -u qa 2>/dev/null; sleep 0.5
rm -rf /home/qa/.local /home/qa/.config /home/qa/.cache /home/qa/.dbus /tmp/session.env /tmp/*.log
mkdir -p /home/qa; chown qa:qa /home/qa
su qa -c "setsid nohup /e2e/lib/session.sh $1 >/dev/null 2>&1 &"
for i in $(seq 60); do [ -s /tmp/session.env ] && break; sleep 0.2; done
cat /tmp/session.env
