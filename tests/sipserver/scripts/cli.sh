#!/bin/bash
# Asterisk CLI. With args runs one command: cli.sh "pjsip show contacts"
if [ $# -gt 0 ]; then exec docker exec softphonepro-pbx asterisk -rx "$*"; fi
exec docker exec -it softphonepro-pbx asterisk -rvvv
