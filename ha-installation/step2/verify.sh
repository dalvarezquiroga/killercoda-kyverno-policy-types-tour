#!/bin/bash
# Every controller must have elected a leader (a Lease with a holder).
for lease in kyverno kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  [ -n "$(kubectl get lease "$lease" -n kyverno -o jsonpath='{.spec.holderIdentity}' 2>/dev/null)" ] || exit 1
done
