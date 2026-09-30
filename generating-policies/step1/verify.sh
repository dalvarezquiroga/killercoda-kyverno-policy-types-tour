#!/bin/bash
# Generation is asynchronous, so retry for a short while.
for i in $(seq 1 15); do
  kubectl get configmap default-config -n demo-app >/dev/null 2>&1 && exit 0
  sleep 2
done
exit 1
