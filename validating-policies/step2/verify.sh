#!/bin/bash
# The policy is now in Audit mode and a PolicyReport has been recorded.
[ "$(kubectl get validatingpolicy require-team-label -o jsonpath='{.spec.validationActions[0]}' 2>/dev/null)" = "Audit" ] || exit 1
for i in $(seq 1 15); do
  [ -n "$(kubectl get policyreport -n default --no-headers 2>/dev/null)" ] && exit 0
  sleep 2
done
exit 1
