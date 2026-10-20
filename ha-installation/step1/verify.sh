#!/bin/bash
# Every controller must run its HA replica count, with all replicas ready.
check() {
  local deploy=$1 min=$2
  local want ready
  want=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
  ready=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
  [ -n "$want" ] && [ "$want" -ge "$min" ] && [ "${ready:-0}" -eq "$want" ]
}
check kyverno-admission-controller 3 || exit 1
check kyverno-background-controller 2 || exit 1
check kyverno-cleanup-controller 2 || exit 1
check kyverno-reports-controller 2 || exit 1
