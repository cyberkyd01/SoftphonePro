# Local test PBX for SoftphonePro integration tests (Asterisk 20 on Ubuntu 24.04)
# Stage "base" == image softphonepro-pbx:base (build: docker build --target base -t softphonepro-pbx:base .)
FROM ubuntu:24.04 AS base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends asterisk asterisk-modules asterisk-core-sounds-en-gsm sox ca-certificates openssl \
    && rm -rf /var/lib/apt/lists/*

FROM base AS pbx
# --- Self-signed CA + server cert (TLS 5061, WSS 8089, DTLS-SRTP) ---
RUN mkdir -p /etc/asterisk/keys && cd /etc/asterisk/keys \
 && openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -subj "/O=SoftphonePro Test/CN=SoftphonePro Test CA" -addext "basicConstraints=critical,CA:TRUE" -addext "keyUsage=critical,keyCertSign,cRLSign" -addext "subjectKeyIdentifier=hash" -keyout ca.key -out ca.crt \
 && openssl req -newkey rsa:2048 -nodes -subj "/O=SoftphonePro Test/CN=softphonepro-pbx" -keyout asterisk.key -out asterisk.csr \
 && printf 'subjectAltName=DNS:localhost,DNS:softphonepro-pbx,DNS:pbx.test,IP:127.0.0.1,IP:10.0.2.2,IP:::1\nbasicConstraints=CA:FALSE\nauthorityKeyIdentifier=keyid\nsubjectKeyIdentifier=hash\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth,clientAuth\n' > ext.cnf \
 && openssl x509 -req -in asterisk.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -extfile ext.cnf -out asterisk.crt \
 && cat asterisk.crt asterisk.key > asterisk.pem && rm -f asterisk.csr ext.cnf ca.srl && chmod 644 *

# --- Test audio (sox): long tone for ext 601/604, short prompt for 1999, MOH ---
RUN mkdir -p /usr/share/asterisk/sounds/custom /var/lib/asterisk/moh-test \
 && sox -n -r 8000 -c 1 -b 16 /usr/share/asterisk/sounds/custom/tone-long.wav synth 30 sine 440 vol 0.5 \
 && sox -n -r 8000 -c 1 -b 16 /usr/share/asterisk/sounds/custom/tone-short.wav synth 2 sine 880 vol 0.5 \
 && sox -n -r 8000 -c 1 -b 16 /var/lib/asterisk/moh-test/moh-tone.wav synth 10 sine 300-600 vol 0.4

# --- Pre-seeded voicemail: 2 new messages each for 1001 and 1002 ---
RUN for m in 1001 1002; do d=/var/spool/asterisk/voicemail/default/$m/INBOX; mkdir -p $d; \
      for n in 0 1; do f=$d/msg000$n; \
        sox -n -r 8000 -c 1 -b 16 $f.wav synth 3 sine $((500+n*200)) vol 0.5; \
        printf '[message]\norigmailbox=%s\ncontext=default\nmacrocontext=\nexten=s\nrdnis=unknown\npriority=1\ncallerchan=PJSIP/1010-00000000\ncallerid="Seeded Caller" <1010>\noriginate=\norigdate=Mon Jan  1 00:00:00 AM UTC 2024\norigtime=17040672%02d\nflag=\ncategory=\nduration=3\n' "$m" "$n" > $f.txt; \
      done; done

COPY config/ /opt/asterisk-conf/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && mkdir -p /var/log/asterisk /var/run/asterisk
EXPOSE 5060/udp 5060/tcp 5061/tcp 8088/tcp 8089/tcp 4569/udp 5038/tcp 10000-10099/udp
ENTRYPOINT ["/entrypoint.sh"]
