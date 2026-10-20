SoftphonePro for Linux (64-bit: x86_64 and arm64)
=================================================

Run it:        ./softphonepro
Menu entry:    ./install-desktop-entry.sh      (current user only; undo: ./uninstall-desktop-entry.sh)
               This also makes SoftphonePro the handler for sip:, sips:, tel:, callto: and
               softphonepro: links. Run it again if you move this folder.

Needs a desktop session with GTK 3 (X11 or Wayland), and these packages (names for Debian/Ubuntu):
  libgtk-3-0 libasound2 libsecret-1-0 libayatana-appindicator3-1 libnotify4 libkeybinder-3.0-0
  libegl1 libgl1 libgl1-mesa-dri (OpenGL; Flutter loads it at run time)
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good (ringtones and playback of recordings)
Recommended: zenity or kdialog (file dialogs), gnome-keyring or kwalletmanager (stores secrets),
  xdg-utils, and pipewire-alsa or pulseaudio's ALSA plugin (libasound2-plugins) for audio.
The .deb package installs all of this for you.

Audio goes through ALSA; on PulseAudio/PipeWire systems pick the "default" device.
Only one copy runs at a time: starting it again (or opening a sip: link) hands over to the running one.

Source and licence (GPL-3.0-or-later): https://github.com/cyberkyd01/SoftphonePro
