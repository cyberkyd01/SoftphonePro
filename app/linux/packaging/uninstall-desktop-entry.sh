#!/bin/sh
# Removes what install-desktop-entry.sh added to the current user's profile.
set -eu
APP_ID=com.softphonepro.softphonepro
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
rm -f "$DATA/applications/$APP_ID.desktop"
for f in "$DATA"/icons/hicolor/*/apps/$APP_ID.png; do [ -f "$f" ] && rm -f "$f"; done
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DATA/applications" >/dev/null 2>&1 || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t "$DATA/icons/hicolor" >/dev/null 2>&1 || true
# Link-handler defaults live in ~/.config/mimeapps.list; drop the ones that point at us.
MIMEAPPS="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
if [ -f "$MIMEAPPS" ]; then
  sed -i "/^x-scheme-handler\/[a-z]*=$APP_ID\.desktop;\{0,1\}$/d" "$MIMEAPPS"
fi
echo "Removed the SoftphonePro menu entry, icons and link handlers."
