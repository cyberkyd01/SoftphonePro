#!/bin/bash
# Sanity checks run inside the container.
A() { docker exec softphonepro-pbx asterisk -rx "$1"; }
echo "== pjsip endpoints (expect 20) =="; A "pjsip show endpoints" | grep -c '^ Endpoint: *[0-9]'
echo "== pjsip transports =="; A "pjsip show transports" | grep '^Transport:'
echo "== iax2 peers =="; A "iax2 show peers"
echo "== voicemail users =="; A "voicemail show users" | head -14
echo "== voicemail 1001 messages =="; docker exec softphonepro-pbx ls /var/spool/asterisk/voicemail/default/1001/INBOX
echo "== http status =="; A "http show status"
echo "== hints =="; A "core show hints" | head -40
echo "== codec modules =="; A "module show like codec"
echo "== codecs =="; A "core show codecs audio" | head -30
echo "== key dialplan =="; for x in 600 601 602 603 604 700 '*8' '**1001' 800 '*97' 1999 19981002; do printf "%-9s" "$x"; A "dialplan show $x@default" | grep -E "^ *'.*=>" | head -1; done
echo "== startup warnings/errors =="; docker exec softphonepro-pbx grep -E 'ERROR|WARNING' /var/log/asterisk/full | head -20
