#!/bin/bash
# Real scenario setup. Uploaded to /ks and run hidden by init/background.sh.
# Prepares the 2-node cluster for an HA install of Kyverno. Kyverno itself is
# NOT installed here — the learner installs it in Step 1.

helm repo add kyverno https://kyverno.github.io/kyverno/ || true
helm repo update

# Wait until both nodes have joined and are Ready.
until [ "$(kubectl get nodes --no-headers 2>/dev/null | wc -l)" -ge 2 ]; do
  sleep 2
done
kubectl wait --for=condition=Ready nodes --all --timeout=5m

# Lab only: let the control-plane node run regular workloads, so Kyverno's
# replicas can spread across both nodes. No-op if it is not tainted.
kubectl taint nodes -l node-role.kubernetes.io/control-plane \
  node-role.kubernetes.io/control-plane:NoSchedule- 2>/dev/null || true

# Signal the foreground spinner that setup is complete.
touch /ks/.initfinished
