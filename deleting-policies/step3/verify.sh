#!/bin/bash
# A DeletingPolicy must target ConfigMaps, delete old-config (expired=true) and
# keep keep-config. The policy runs every minute, so retry for a short while.
kubectl get deletingpolicy -o jsonpath='{.items[*].spec.matchConstraints.resourceRules[*].resources}' 2>/dev/null \
  | grep -q configmaps || exit 1
kubectl get configmap keep-config -n demo >/dev/null 2>&1 || exit 1
for i in $(seq 1 30); do
  kubectl get configmap old-config -n demo >/dev/null 2>&1 || exit 0
  sleep 2
done
exit 1
