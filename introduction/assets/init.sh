#!/bin/bash
# Real scenario setup. Uploaded to /ks and run hidden by init/background.sh.
# Prepares the cluster only. Kyverno itself is NOT installed here — the
# learner installs it in Step 1.

helm repo add kyverno https://kyverno.github.io/kyverno/ || true
helm repo update

kubectl wait --for=condition=Ready nodes --all --timeout=5m

# Signal the foreground spinner that setup is complete.
touch /ks/.initfinished
