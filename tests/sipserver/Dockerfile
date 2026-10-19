# Local test PBX for SoftphonePro integration tests (Asterisk 20 on Ubuntu 24.04)
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends asterisk asterisk-modules asterisk-core-sounds-en-gsm sox ca-certificates openssl \
    && rm -rf /var/lib/apt/lists/*
