#!/bin/bash
# Every controller must have its PDB, the drill policy must exist, and all
# replicas must be ready again after the drill (pods may still be restarting).
kubectl get validatingpolicy require-team-label >/dev/null 2>&1 || exit 1
for pdb in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl get pdb "$pdb" -n kyverno >/dev/null 2>&1 || exit 1
done
ready() {
  local want got
  want=$(kubectl get deploy "$1" -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
  got=$(kubectl get deploy "$1" -n kyverno -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
  [ -n "$want" ] && [ "${got:-0}" -eq "$want" ]
}
for i in $(seq 1 30); do
  if ready kyverno-admission-controller && ready kyverno-background-controller &&
     ready kyverno-cleanup-controller && ready kyverno-reports-controller; then
    exit 0
  fi
  sleep 2
done
exit 1
