# QA image: SoftphonePro .deb + X/audio tooling. Build with:
#   docker build --platform linux/arm64 --build-arg BASE=ubuntu:24.04 -t spc-qa-audio:arm64 -f Dockerfile <ctx containing SoftphonePro.deb>
ARG BASE=ubuntu:24.04
FROM ${BASE}
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    openbox xvfb dbus-x11 xdotool imagemagick x11-utils python3 python3-numpy sox libsox-fmt-mp3 lame \
    pulseaudio pulseaudio-utils libasound2-plugins zenity jq curl procps sysstat ca-certificates \
    fonts-dejavu fonts-noto-core fonts-noto-ui-core fonts-noto-color-emoji x11-xserver-utils xclip \
    && rm -rf /var/lib/apt/lists/*
COPY SoftphonePro.deb /tmp/SoftphonePro.deb
RUN apt-get update && apt-get install -y /tmp/SoftphonePro.deb && rm -rf /var/lib/apt/lists/* /tmp/SoftphonePro.deb
RUN useradd -m -s /bin/bash qa
# NOT a dependency of the .deb: without xdg-user-dirs, path_provider cannot find ~/Documents and recording fails (see RESULTS_audio.md, bug 2).
# Installed so recording can be tested; set --build-arg XDG=0 to reproduce the bug.
ARG XDG=1
RUN if [ "$XDG" = 1 ]; then apt-get update && apt-get install -y xdg-user-dirs && rm -rf /var/lib/apt/lists/* && su qa -c xdg-user-dirs-update; fi
