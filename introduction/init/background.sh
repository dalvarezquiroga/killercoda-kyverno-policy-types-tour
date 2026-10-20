#!/bin/bash
# Runs in the background, hidden from the user.
# Do NOT put setup logic here; edit assets/init.sh instead.

FILE=/ks/init.sh; while ! test -f ${FILE}; do clear; sleep 0.1; done; bash ${FILE} > /ks/init.log 2>&1
