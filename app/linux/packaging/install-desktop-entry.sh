#!/bin/sh
# Registers SoftphonePro for the current user (no root needed): application menu entry, icons and
# the sip:/sips:/tel:/callto:/softphonepro: link handlers, all pointing at this extracted folder.
# Undo with ./uninstall-desktop-entry.sh. If you move the folder, run this script again.
set -eu
APP_ID=com.softphonepro.softphonepro
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HERE/softphonepro"
[ -x "$BIN" ] || { echo "softphonepro not found next to this script ($HERE)" >&2; exit 1; }

DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
APPS="$DATA/applications"
mkdir -p "$APPS"

# Exec must be one quoted path followed by %u. Inside the quotes the Desktop Entry spec wants
# \ " ` $ escaped with a backslash, and the file format then doubles every backslash.
ESC="$(printf '%s' "$BIN" | awk '{ gsub(/\\/, "\\\\\\\\"); gsub(/"/, "\\\\\""); gsub(/`/, "\\\\`"); gsub(/\$/, "\\\\$"); print }')"
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    Exec=*) printf 'Exec="%s" %%u\n' "$ESC" ;;
    *) printf '%s\n' "$line" ;;
  esac
done < "$HERE/share/applications/$APP_ID.desktop" > "$APPS/$APP_ID.desktop"

for f in "$HERE"/share/icons/hicolor/*/apps/$APP_ID.png; do
  [ -f "$f" ] || continue
  size="$(basename "$(dirname "$(dirname "$f")")")"
  mkdir -p "$DATA/icons/hicolor/$size/apps"
  cp "$f" "$DATA/icons/hicolor/$size/apps/$APP_ID.png"
done

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" >/dev/null 2>&1 || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t "$DATA/icons/hicolor" >/dev/null 2>&1 || true

if command -v xdg-mime >/dev/null 2>&1; then
  for scheme in sip sips tel callto softphonepro; do
    xdg-mime default "$APP_ID.desktop" "x-scheme-handler/$scheme" || true
  done
else
  echo "xdg-mime not found: install xdg-utils to make SoftphonePro the handler for sip:/tel: links." >&2
fi
echo "Installed $APPS/$APP_ID.desktop"
