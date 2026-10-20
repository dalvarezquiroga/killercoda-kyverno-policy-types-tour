#!/bin/bash
# The Job must be deleted together with its Pods (Background propagation).
# Deletion and garbage collection are asynchronous, so retry for a short while.
kubectl get deletingpolicy cleanup-finished-jobs >/dev/null 2>&1 || exit 1
for i in $(seq 1 30); do
  if ! kubectl get job hello-job -n demo >/dev/null 2>&1 &&
     [ -z "$(kubectl get pods -n demo -l job-name=hello-job -o name 2>/dev/null)" ]; then
    exit 0
  fi
  sleep 2
done
exit 1
