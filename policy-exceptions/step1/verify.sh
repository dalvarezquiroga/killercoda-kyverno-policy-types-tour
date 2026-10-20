#!/bin/bash
# The policy must block an unlabeled Pod. Server dry-run runs admission
# (incl. Kyverno) without creating it.
kubectl get validatingpolicy require-team-label >/dev/null 2>&1 || exit 1
kubectl get pod web >/dev/null 2>&1 || exit 1
kubectl run pe-check --image=nginx --dry-run=server >/dev/null 2>&1 && exit 1
exit 0
