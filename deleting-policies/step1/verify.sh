#!/bin/bash
# The policy runs every minute, so give it a short while to remove temp-pod.
kubectl get deletingpolicy cleanup-temp-pods >/dev/null 2>&1 || exit 1
kubectl get pod keep-pod -n demo >/dev/null 2>&1 || exit 1
for i in $(seq 1 30); do
  kubectl get pod temp-pod -n demo >/dev/null 2>&1 || exit 0
  sleep 2
done
exit 1
