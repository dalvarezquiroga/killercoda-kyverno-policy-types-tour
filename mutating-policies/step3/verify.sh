#!/bin/bash
# The MutatingPolicy must inject spec.securityContext.runAsNonRoot=true.
# Server dry-run runs the mutating webhook without creating a Pod.
val=$(kubectl run mp-check --image=nginx --dry-run=server -o jsonpath='{.spec.securityContext.runAsNonRoot}' 2>/dev/null)
[ "$val" = "true" ] || exit 1
