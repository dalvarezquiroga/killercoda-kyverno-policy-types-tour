#!/bin/bash
# The time-boxed exception must live in the allowed namespace and let
# batch-runner in. Server dry-run runs admission without creating the Pod.
[ -n "$(kubectl get policyexceptions.policies.kyverno.io allow-batch-runner -n exceptions \
  -o jsonpath='{.spec.expiresAt}' 2>/dev/null)" ] || exit 1
for i in $(seq 1 10); do
  kubectl run batch-runner --image=nginx --dry-run=server >/dev/null 2>&1 && exit 0
  sleep 2
done
exit 1
