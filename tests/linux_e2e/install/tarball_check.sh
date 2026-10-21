#!/bin/bash
# Inside a fresh ubuntu:24.04 arm64 container (root). Pulls in the .deb's dependencies by installing then removing
# the .deb (libs stay), then extracts the tarball as user qa, runs it and install-desktop-entry.sh.
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq --no-install-recommends ca-certificates curl xvfb openbox xauth procps xdg-utils desktop-file-utils /rel/SoftphonePro-1.1.2-linux-arm64.deb >/dev/null 2>&1
dpkg -r softphonepro >/dev/null; rm -rf /opt/softphonepro /usr/bin/softphonepro; echo "deb removed: $(which softphonepro || echo gone)"
useradd -m qa
cat > /tmp/prov.json <<J
{"accounts":[],"settings":{"automationEnabled":true,"automationPort":7771,"automationToken":"abababababababababababababababababababababababababababababababab"}}
J
chmod 644 /tmp/prov.json
su qa -c '
export HOME=/home/qa DISPLAY=:99 XDG_RUNTIME_DIR=/tmp/xdg; mkdir -p $XDG_RUNTIME_DIR; chmod 700 $XDG_RUNTIME_DIR
mkdir -p ~/tb && cd ~/tb && tar xzf /rel/SoftphonePro-1.1.2-linux-arm64.tar.gz && ls
D=$(ls -d */ 2>/dev/null | head -1); [ -n "$D" ] && cd "$D"; pwd; ls
echo "-- ldd not found:"; for f in softphonepro $(find lib -name "*.so*" 2>/dev/null); do ldd $f 2>&1 | grep "not found"; done; echo "-- end"
(Xvfb :99 -screen 0 1280x800x24 >/dev/null 2>&1 &); sleep 1; (openbox >/dev/null 2>&1 &)
(nohup ./softphonepro --provision /tmp/prov.json >/tmp/app.out 2>/tmp/app.err &)
for i in $(seq 30); do s=$(curl -s -m 2 -H "Authorization: Bearer $(printf "ab%.0s" $(seq 32))" http://127.0.0.1:7771/v1/status) && [ -n "$s" ] && break; sleep 1; done
echo "STATUS($i s): $s"; id -u
./install-desktop-entry.sh; echo "rc=$?"
ls -la ~/.local/share/applications/; desktop-file-validate ~/.local/share/applications/com.softphonepro.softphonepro.desktop && echo VALID; grep ^Exec ~/.local/share/applications/*.desktop
xdg-mime query default x-scheme-handler/sip; xdg-mime query default x-scheme-handler/tel
ls ~/.local/share/icons/hicolor/*/apps | head
[ -x ./uninstall-desktop-entry.sh ] && ./uninstall-desktop-entry.sh && ls ~/.local/share/applications/ && echo UNINSTALL_OK
'
