#!/bin/bash
# Runs in the intro terminal and blocks until init.sh has finished.

rm "$0"

clear

echo -n "Setting up Kyverno, this takes a moment"
while [ ! -f /ks/.initfinished ]; do
    echo -n '.'
    sleep 1
done
version=$(cat /ks/kyverno-version 2>/dev/null)
echo " ready!"
echo
echo "Kyverno ${version:-v1.19} is installed and ready — CEL policy CRDs registered."
echo "Click the START button to begin."
