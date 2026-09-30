#!/bin/bash
# Runs in the visible intro terminal and blocks until setup finishes.

FILE=/ks/wait-init.sh; while ! test -f ${FILE}; do clear; sleep 0.1; done; bash ${FILE}
