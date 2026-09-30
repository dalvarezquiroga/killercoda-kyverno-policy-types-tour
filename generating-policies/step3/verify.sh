#!/bin/bash
# Create a brand-new namespace so the trigger always fires AFTER the policy,
# then wait for the generated default-deny NetworkPolicy (generation is async).
ns="gpol-verify-$$"
kubectl create namespace "$ns" >/dev/null 2>&1
rc=1
for i in $(seq 1 20); do
  if kubectl get networkpolicy default-deny -n "$ns" >/dev/null 2>&1; then rc=0; break; fi
  sleep 2
done
kubectl delete namespace "$ns" --wait=false >/dev/null 2>&1
exit $rc
