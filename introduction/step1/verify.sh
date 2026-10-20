#!/bin/bash
# All four Kyverno controllers must be installed with every replica ready.
ready() {
  local want got
  want=$(kubectl get deploy "$1" -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
  got=$(kubectl get deploy "$1" -n kyverno -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
  [ -n "$want" ] && [ "${got:-0}" -eq "$want" ]
}
for i in $(seq 1 15); do
  if ready kyverno-admission-controller && ready kyverno-background-controller &&
     ready kyverno-cleanup-controller && ready kyverno-reports-controller; then
    exit 0
  fi
  sleep 2
done
exit 1
