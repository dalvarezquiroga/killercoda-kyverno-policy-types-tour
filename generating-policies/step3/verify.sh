#!/bin/bash
# The GeneratingPolicy must create a default-deny NetworkPolicy in a new NS.
# Create the trigger namespace if the user has not yet, then retry (async).
kubectl get ns demo-netpol >/dev/null 2>&1 || kubectl create namespace demo-netpol >/dev/null 2>&1
for i in $(seq 1 15); do
  kubectl get networkpolicy default-deny -n demo-netpol >/dev/null 2>&1 && exit 0
  sleep 2
done
exit 1
