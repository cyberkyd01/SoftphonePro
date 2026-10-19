#!/bin/bash
# Build + start the test PBX and wait until Asterisk is fully booted.
# Usage: up.sh [--emulator]   (--emulator: advertise 10.0.2.2 so Android-emulator clients can send media)
set -e
cd "$(dirname "$0")/.."
if [ "$1" = "--emulator" ]; then export PBX_EXTERNAL_ADDR=10.0.2.2; fi
export PBX_EXTERNAL_ADDR="${PBX_EXTERNAL_ADDR:-127.0.0.1}"
docker build -q --target pbx -t softphonepro-pbx:latest . >/dev/null
docker compose up -d --no-build --force-recreate
echo -n "Waiting for Asterisk"
for i in $(seq 1 60); do
  if docker exec softphonepro-pbx asterisk -rx "core waitfullybooted" >/dev/null 2>&1; then ok=1; break; fi
  echo -n "."; sleep 1
done
echo
[ -n "$ok" ] || { echo "Asterisk did not boot; see scripts/logs.sh"; exit 1; }
mkdir -p certs && docker cp softphonepro-pbx:/etc/asterisk/keys/ca.crt certs/ca.crt
for f in client.crt client.key client-enc.key; do docker cp softphonepro-pbx:/etc/asterisk/keys/$f certs/$f; done
echo "PBX ready."
echo "  From the Mac host:        export PBX_HOST=127.0.0.1   (UDP/TCP 5060, TLS 5061, mTLS 5062, WS 8088, WSS 8089, IAX2 4569, AMI 5038)"
echo "  From the Android emulator: host 10.0.2.2 (start with: $0 --emulator)"
echo "  Advertised media/signaling address: ${PBX_EXTERNAL_ADDR}"
echo "  CA cert for TLS/WSS: $(pwd)/certs/ca.crt"
