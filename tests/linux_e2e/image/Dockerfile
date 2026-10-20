# QA image for the SoftphonePro 1.1.0 Linux desktop-integration pass.
# Build: docker build --platform linux/arm64 --build-arg BASE=ubuntu:24.04 -t spc-qa-desk:arm64 .
#        docker build --platform linux/arm64 --build-arg BASE=debian:12   -t spc-qa-desk:debian12 .
# NOTE: copy dist/linux/SoftphonePro-1.1.0-linux-arm64.deb to image/softphonepro.deb before building (not committed).
ARG BASE=ubuntu:24.04
FROM ${BASE}
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb dbus-x11 dbus xdotool imagemagick x11-utils python3 python3-dbus python3-gi gir1.2-glib-2.0 \
    gnome-keyring libsecret-tools gcr playerctl xdg-utils desktop-file-utils \
    pulseaudio libasound2-plugins jq curl ca-certificates openbox procps iproute2 iputils-ping \
    libnotify-bin psmisc sudo coreutils xauth \
 && (apt-get install -y --no-install-recommends gcr-ui gcr4 2>/dev/null || true) \
 && rm -rf /var/lib/apt/lists/*
COPY softphonepro.deb /tmp/softphonepro.deb
RUN apt-get update && apt-get install -y /tmp/softphonepro.deb && rm -rf /var/lib/apt/lists/* /tmp/softphonepro.deb
RUN useradd -m -s /bin/bash qa && echo "qa ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/qa
