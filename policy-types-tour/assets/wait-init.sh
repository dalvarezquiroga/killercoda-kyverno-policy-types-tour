#!/bin/bash
# Runs in the intro terminal and blocks until init.sh has finished.

rm "$0"

clear

echo -n "Preparing Kyverno, this takes a moment"
while [ ! -f /ks/.initfinished ]; do
    echo -n '.'
    sleep 1
done
echo " ready!"
echo
echo "Kyverno is installed and the CEL policy CRDs are registered."
echo "Open Step 1 to start the tour."
