#!/bin/bash
# Renders config and runs Asterisk in the foreground.
# PBX_EXTERNAL_ADDR: address clients use to reach this PBX (goes in SDP / Contact / ICE).
#   host-based clients: 127.0.0.1 (default) or colima VM IP; Android emulator: 10.0.2.2
set -e
EXT="${PBX_EXTERNAL_ADDR:-127.0.0.1}"
cp -a /opt/asterisk-conf/. /etc/asterisk/
sed -i "s/@EXT_ADDR@/${EXT}/g" /etc/asterisk/pjsip.conf /etc/asterisk/extensions.conf
# ICE host candidates: advertise the external address instead of the container IP
CIP="$(hostname -i | awk '{print $1}')"
if [ -n "$CIP" ]; then printf '\n[ice_host_candidates]\n%s => %s,include_local\n' "$CIP" "$EXT" >> /etc/asterisk/rtp.conf; fi
rm -f /var/log/asterisk/dtmf_*.txt
echo "SoftphonePro test PBX: external address ${EXT}, container IP ${CIP}"
exec asterisk -f -U root -G root -vvv
