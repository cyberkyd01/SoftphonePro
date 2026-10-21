#!/bin/bash
# Runs INSIDE a fresh container (root). $1 = arch (arm64|amd64). /rel = release dir mounted ro.
set -u
ARCH=$1
export DEBIAN_FRONTEND=noninteractive
echo "== OS: $(. /etc/os-release; echo $PRETTY_NAME) $(uname -m)"
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq --no-install-recommends ca-certificates curl xvfb openbox xauth procps >/dev/null 2>&1
if apt-get install -y /rel/SoftphonePro-1.1.2-linux-$ARCH.deb >/tmp/apt.log 2>&1; then echo "INSTALL: PASS"; else echo "INSTALL: FAIL"; tail -15 /tmp/apt.log; exit 1; fi
dpkg -l softphonepro | tail -1
echo "-- ldd missing:"; (for f in /opt/softphonepro/softphonepro $(find /opt/softphonepro/lib -name '*.so*' 2>/dev/null); do ldd $f 2>&1 | grep "not found" | sed "s#^#$f: #"; done) | sort -u | head
echo "-- end ldd"
useradd -m qa 2>/dev/null
cat > /tmp/prov.json <<J
{"accounts":[],"settings":{"automationEnabled":true,"automationPort":7771,"automationToken":"abababababababababababababababababababababababababababababababab"}}
J
chmod 644 /tmp/prov.json
su qa -c 'export HOME=/home/qa DISPLAY=:99 XDG_RUNTIME_DIR=/tmp/xdg; mkdir -p $XDG_RUNTIME_DIR; chmod 700 $XDG_RUNTIME_DIR; (Xvfb :99 -screen 0 1280x800x24 >/tmp/xvfb.log 2>&1 &); sleep 1; (openbox >/dev/null 2>&1 &); (nohup softphonepro --provision /tmp/prov.json >/tmp/app.out 2>/tmp/app.err &); sleep 1'
for i in $(seq 40); do
  s=$(curl -s -m 2 -H "Authorization: Bearer $(printf 'ab%.0s' $(seq 32))" http://127.0.0.1:7771/v1/status) && echo "$s" | grep -q "\"state\":\"running\"" && break; sleep 1
done
echo "STATUS($i s): $s"
echo "$s" | grep -o '"version":"[^"]*"' | head -3
pgrep -a softphonepro | head -2
tail -5 /tmp/app.err
