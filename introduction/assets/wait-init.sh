#!/bin/bash
# Runs in the intro terminal and blocks until init.sh has finished.

rm "$0"

clear

echo -n "Preparing the cluster, this takes a moment"
while [ ! -f /ks/.initfinished ]; do
    echo -n '.'
    sleep 1
done
echo " ready!"
echo
echo "The cluster is Ready and the Kyverno Helm repo is configured."
echo "Click the START button to begin."
